#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..', '..');
const LOOP_PROMPT =
  'Read .agents/skills/agent-loop.md and execute the next run strictly from the repository\'s local markdown state.';

const failures = [];

function ok(message) {
  console.log(`  pass  ${message}`);
}

function fail(message) {
  failures.push(message);
  console.log(`  fail  ${message}`);
}

function read(relativePath) {
  return fs.readFileSync(path.join(ROOT, relativePath), 'utf8');
}

function exists(relativePath) {
  return fs.existsSync(path.join(ROOT, relativePath));
}

console.log('Harness compliance checks\n');

const requiredFiles = [
  'docs/agent-loop/skill.md',
  'docs/agent-loop/outer-loop-playbook.md',
  'docs/agent-loop/standards.md',
  'docs/agent-loop/templates/backlog.md',
  'docs/agent-loop/templates/handover.md',
  'docs/agent-loop/templates/planning.md',
  'docs/agent-loop/templates/progress.md',
  'docs/agent-loop/templates/tbd.md',
  'docs/agent-loop/templates/tbd-response.md',
  'scripts/cli.js',
  'scripts/check-health.ps1',
  'scripts/check-health.sh',
  'scripts/run-loop.ps1',
  'scripts/run-loop.sh',
  'scripts/archive-backlog.ps1',
  'scripts/inject-skill.ps1',
  'init-trial.ps1',
  'init-trial.sh',
  'CHANGELOG.md',
  'package.json',
];

for (const file of requiredFiles) {
  if (exists(file)) {
    ok(`${file} exists`);
  } else {
    fail(`missing required file: ${file}`);
  }
}

const skill = exists('docs/agent-loop/skill.md') ? read('docs/agent-loop/skill.md') : '';
for (const phase of [
  '## Phase 1:',
  '## Phase 2:',
  '## Phase 3:',
  '## Phase 4:',
  '## Phase 5:',
  '## Phase 6:',
]) {
  if (skill.includes(phase)) {
    ok(`skill.md contains ${phase.trim()}`);
  } else {
    fail(`skill.md is missing ${phase.trim()}`);
  }
}

const pkg = JSON.parse(read('package.json'));
if (pkg.bin && pkg.bin['agentic-loop'] === './scripts/cli.js') {
  ok('package.json bin points at scripts/cli.js');
} else {
  fail('package.json bin must point at ./scripts/cli.js');
}

if (exists(String(pkg.bin && pkg.bin['agentic-loop']).replace(/^\.\//, ''))) {
  ok('bin target exists on disk');
} else {
  fail('package.json bin target does not exist');
}

const readme = read('README.md');
const playbook = read('docs/agent-loop/outer-loop-playbook.md');
for (const [label, text] of [
  ['README', readme],
  ['playbook', playbook],
]) {
  if (text.includes(LOOP_PROMPT)) {
    ok(`${label} uses the canonical loop prompt`);
  } else {
    fail(`${label} is missing the canonical loop prompt`);
  }
}

for (const provider of ['grok -p', 'claude -p', 'gemini -m', 'opencode run', 'aider -m', 'codex exec']) {
  if (readme.includes(provider) && playbook.includes(provider.split(' ')[0])) {
    ok(`provider example present: ${provider}`);
  } else if (readme.includes(provider)) {
    ok(`README includes ${provider}`);
  } else {
    fail(`README is missing provider example: ${provider}`);
  }
}

const help = spawnSync(process.execPath, [path.join(ROOT, 'scripts', 'cli.js'), 'help'], {
  encoding: 'utf8',
});
if (help.status === 0 && help.stdout.includes('agentic-loop') && help.stdout.includes(LOOP_PROMPT)) {
  ok('cli.js help exits 0 and prints the canonical prompt');
} else {
  fail('cli.js help did not succeed');
}

const cliSource = read('scripts/cli.js');
if (cliSource.includes('left uncommitted changes') && cliSource.includes('tbdPairReady')) {
  ok('cli.js run loop gates on clean worktree and TBD pair');
} else {
  fail('cli.js run loop is missing the success gate (clean tree + TBD)');
}

const tbd = read('docs/agent-loop/templates/tbd.md');
if (tbd.includes('tbd-response.md')) {
  ok('tbd template names the matching response file');
} else {
  fail('tbd template should mention tbd-response.md');
}

console.log('');
if (failures.length > 0) {
  console.log(`${failures.length} check(s) failed.`);
  process.exit(1);
}

console.log('All compliance checks passed.');
