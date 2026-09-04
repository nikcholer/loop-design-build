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

function writeFakeGrok(binDir) {
  fs.mkdirSync(binDir, { recursive: true });
  const dumpJs = path.join(binDir, 'grok-dump.js');
  fs.writeFileSync(
    dumpJs,
    "require('fs').writeFileSync('provider-argv.json', JSON.stringify(process.argv.slice(2)));\n"
  );

  if (process.platform === 'win32') {
    fs.writeFileSync(
      path.join(binDir, 'grok.cmd'),
      `@echo off\r\n${quote(process.execPath)} ${quote(dumpJs)} %*\r\n`
    );
  } else {
    const grokPath = path.join(binDir, 'grok');
    fs.writeFileSync(
      grokPath,
      `#!/bin/sh\nexec ${quote(process.execPath)} ${quote(dumpJs)} "$@"\n`
    );
    fs.chmodSync(grokPath, 0o755);
  }
}

const LOOP_PROMPT =
  'Read .agents/skills/agent-loop.md and execute the next run strictly from the repository\'s local markdown state.';

function writeUngitScript(repo) {
  fs.writeFileSync(
    path.join(repo, 'ungit.js'),
    "require('fs').rmSync(require('path').join(process.cwd(), '.git'), { recursive: true, force: true });\n"
  );
  git(repo, ['add', 'ungit.js']);
  git(repo, ['commit', '-m', 'add ungit']);
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

const argvRepo = makeRepo();
const fakeBin = fs.mkdtempSync(path.join(os.tmpdir(), 'fake-grok-'));
try {
  writeFakeGrok(fakeBin);
  const result = spawnSync(process.execPath, [
    CLI,
    'run',
    '--cwd',
    argvRepo,
    '--max-runs',
    '1',
    '--provider',
    'grok',
  ], {
    encoding: 'utf8',
    cwd: argvRepo,
    env: {
      ...process.env,
      PATH: `${fakeBin}${path.delimiter}${process.env.PATH}`,
    },
  });
  const argvFile = path.join(argvRepo, 'provider-argv.json');
  if (!fs.existsSync(argvFile)) {
    fail(`--provider grok did not invoke the stand-in (status ${result.status}): ${result.stdout}\n${result.stderr}`);
  } else {
    const argv = JSON.parse(fs.readFileSync(argvFile, 'utf8'));
    if (argv.includes(LOOP_PROMPT) && argv.includes('-p')) {
      ok('--provider grok passes the headless prompt as a single argument');
    } else {
      fail(`--provider grok split or dropped the prompt: ${JSON.stringify(argv)}`);
    }
  }
} finally {
  removeDir(argvRepo);
  removeDir(fakeBin);
}

const goneRepo = makeRepo();
try {
  writeUngitScript(goneRepo);
  const result = runCli(goneRepo, 'ungit.js', 1);
  const output = `${result.stdout}\n${result.stderr}`;
  if (result.status !== 0 && /git status failed|not a git repository/i.test(output)) {
    ok('Node runner fails closed when git status cannot inspect the worktree');
  } else {
    fail(`Node git-gone path should fail (status ${result.status}): ${output}`);
  }
} finally {
  removeDir(goneRepo);
}

const pwshName = ['pwsh', 'powershell'].find((name) => {
  const probe = spawnSync(name, ['-NoProfile', '-Command', 'exit 0'], { encoding: 'utf8' });
  return probe.status === 0;
});

if (pwshName) {
  const psRepo = makeRepo();
  try {
    writeUngitScript(psRepo);
    const command = `${quote(process.execPath)} ${quote(path.join(psRepo, 'ungit.js'))}`;
    const result = spawnSync(pwshName, [
      '-NoProfile',
      '-File',
      path.resolve(__dirname, '..', '..', 'scripts', 'run-loop.ps1'),
      '-RepositoryRoot',
      psRepo,
      '-MaxRuns',
      '1',
      '-Command',
      command,
    ], {
      encoding: 'utf8',
      cwd: psRepo,
    });
    const output = `${result.stdout}\n${result.stderr}`;
    const claimedSuccess = /Completed 1 successful run/i.test(output);
    if (result.status !== 0 && !claimedSuccess && /git status failed|not a git repository/i.test(output)) {
      ok(`PowerShell runner fails closed when git status cannot inspect the worktree (${pwshName})`);
    } else {
      fail(`PowerShell git-gone path should fail (status ${result.status}): ${output}`);
    }
  } finally {
    removeDir(psRepo);
  }
} else {
  ok('skipped PowerShell git-gone test (pwsh/powershell not on PATH)');
}

console.log('');
if (failures.length > 0) {
  console.log(`${failures.length} check(s) failed.`);
  process.exit(1);
}

console.log('All outer-loop tests passed.');
