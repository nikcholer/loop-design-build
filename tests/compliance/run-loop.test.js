#!/usr/bin/env node
'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const CLI = path.resolve(__dirname, '..', '..', 'scripts', 'cli.js');
const failures = [];

function ok(message) {
  console.log(`  pass  ${message}`);
}

function fail(message) {
  failures.push(message);
  console.log(`  fail  ${message}`);
}

function git(cwd, args) {
  const result = spawnSync('git', args, { cwd, encoding: 'utf8' });
  if (result.status !== 0) {
    throw new Error(`git ${args.join(' ')} failed: ${result.stderr || result.stdout}`);
  }
  return result;
}

function makeRepo() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'loop-run-'));
  git(dir, ['init']);
  git(dir, ['config', 'user.email', 'test@example.com']);
  git(dir, ['config', 'user.name', 'Test']);
  fs.writeFileSync(path.join(dir, 'README.md'), 'trial\n');
  git(dir, ['add', '.']);
  git(dir, ['commit', '-m', 'init']);
  return dir;
}

function quote(value) {
  return `"${String(value).replace(/"/g, '\\"')}"`;
}

function runCli(cwd, scriptRelative, maxRuns) {
  const command = `${quote(process.execPath)} ${quote(path.join(cwd, scriptRelative))}`;
  return spawnSync(process.execPath, [
    CLI,
    'run',
    '--cwd',
    cwd,
    '--max-runs',
    String(maxRuns),
    '--command',
    command,
  ], {
    encoding: 'utf8',
    cwd,
  });
}

function removeDir(dir) {
  fs.rmSync(dir, { recursive: true, force: true });
}

console.log('Outer-loop success-gate tests\n');

const successRepo = makeRepo();
try {
  fs.writeFileSync(path.join(successRepo, 'noop.js'), 'process.exit(0);\n');
  git(successRepo, ['add', 'noop.js']);
  git(successRepo, ['commit', '-m', 'add noop']);
  const result = runCli(successRepo, 'noop.js', 2);
  const output = `${result.stdout}\n${result.stderr}`;
  if (result.status === 0 && output.includes('Completed 2 successful run(s)')) {
    ok('presses on through two clean successful runs');
  } else {
    fail(`clean success path should complete 2 runs (status ${result.status}): ${output}`);
  }
} finally {
  removeDir(successRepo);
}

const dirtyRepo = makeRepo();
try {
  fs.writeFileSync(
    path.join(dirtyRepo, 'dirty.js'),
    "require('fs').writeFileSync('leftover.txt', 'x');\n"
  );
  git(dirtyRepo, ['add', 'dirty.js']);
  git(dirtyRepo, ['commit', '-m', 'add dirty']);
  const result = runCli(dirtyRepo, 'dirty.js', 2);
  const output = `${result.stdout}\n${result.stderr}`;
  const ranTwice = (output.match(/=== Loop run /g) || []).length >= 2;
  if (result.status === 1 && output.includes('left uncommitted changes') && !ranTwice) {
    ok('halts when exit 0 leaves a dirty worktree');
  } else {
    fail(`dirty-tree path should stop after one run (status ${result.status}): ${output}`);
  }
} finally {
  removeDir(dirtyRepo);
}

const tbdRepo = makeRepo();
try {
  fs.writeFileSync(
    path.join(tbdRepo, 'tbd.js'),
    "const fs = require('fs');\n" +
      "const path = require('path');\n" +
      "fs.mkdirSync(path.join('docs', 'state'), { recursive: true });\n" +
      "fs.writeFileSync(path.join('docs', 'state', 'tbd.md'), '# TBD\\n');\n"
  );
  git(tbdRepo, ['add', 'tbd.js']);
  git(tbdRepo, ['commit', '-m', 'add tbd writer']);
  const result = runCli(tbdRepo, 'tbd.js', 2);
  const output = `${result.stdout}\n${result.stderr}`;
  const ranTwice = (output.match(/=== Loop run /g) || []).length >= 2;
  if (result.status === 0 && output.includes('agent published docs/state/tbd.md') && !ranTwice) {
    ok('halts on unresolved tbd.md without treating it as a dirty-tree failure');
  } else {
    fail(`TBD path should stop after one run with exit 0 (status ${result.status}): ${output}`);
  }
} finally {
  removeDir(tbdRepo);
}

console.log('');
if (failures.length > 0) {
  console.log(`${failures.length} check(s) failed.`);
  process.exit(1);
}

console.log('All outer-loop tests passed.');
