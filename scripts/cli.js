#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const PACKAGE_ROOT = path.resolve(__dirname, '..');
const LOOP_PROMPT =
  'Read .agents/skills/agent-loop.md and execute the next run strictly from the repository\'s local markdown state.';

const PROVIDER_COMMANDS = {
  grok: ['grok', '-p', LOOP_PROMPT, '--always-approve', '--max-turns', '15'],
  claude: ['claude', '-p', LOOP_PROMPT, '--dangerously-skip-permissions', '--max-turns', '15'],
  gemini: ['gemini', '-m', 'gemini-2.5-pro', '--approval-mode', 'yolo', '-p', LOOP_PROMPT],
  codex: ['codex', 'exec', '--dangerously-bypass-approvals-and-sandbox', LOOP_PROMPT],
  aider: ['aider', '-m', LOOP_PROMPT, '--yes', '--no-gitignore'],
  opencode: ['opencode', 'run', '--dangerously-skip-permissions', '--log-level', 'WARN', LOOP_PROMPT],
};

function usage(exitCode) {
  const text = `agentic-loop — scaffold and operate the Agentic Loop Harness

Usage:
  agentic-loop init [TrialName] [--target <path>]
  agentic-loop health [--cwd <path>] [--verify <command> [args...]]
  agentic-loop run --provider <name> [--max-runs N] [--cwd <path>] [--wait-for-response]
  agentic-loop run --command "<shell command>" [--max-runs N] [--cwd <path>] [--wait-for-response]
  agentic-loop help

  run continues only after a real success: provider exit 0, clean worktree, no unresolved tbd.md.
  --max-runs is a safety cap (default 3). --wait-for-response parks on TBD for attended demos.

Providers: ${Object.keys(PROVIDER_COMMANDS).join(', ')}

The canonical headless prompt is:

  ${LOOP_PROMPT}
`;
  process.stdout.write(text);
  process.exit(exitCode);
}

function fail(message) {
  process.stderr.write(`Error: ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = argv.slice(2);
  const command = args[0] || 'help';
  const rest = args.slice(1);
  const flags = {};
  const positional = [];

  for (let i = 0; i < rest.length; i += 1) {
    const token = rest[i];
    if (token === '--target' || token === '-t') {
      flags.target = rest[i + 1];
      i += 1;
    } else if (token === '--cwd') {
      flags.cwd = rest[i + 1];
      i += 1;
    } else if (token === '--provider') {
      flags.provider = rest[i + 1];
      i += 1;
    } else if (token === '--command') {
      flags.command = rest[i + 1];
      i += 1;
    } else if (token === '--max-runs') {
      flags.maxRuns = rest[i + 1];
      i += 1;
    } else if (token === '--verify') {
      flags.verify = rest.slice(i + 1);
      break;
    } else if (token === '--wait-for-response') {
      flags.waitForResponse = true;
    } else if (token === '--help' || token === '-h') {
      flags.help = true;
    } else if (token.startsWith('-')) {
      fail(`Unknown flag: ${token}`);
    } else {
      positional.push(token);
    }
  }

  return { command, flags, positional };
}

function timestampName() {
  const now = new Date();
  const pad = (value) => String(value).padStart(2, '0');
  return (
    now.getFullYear() +
    pad(now.getMonth() + 1) +
    pad(now.getDate()) +
    pad(now.getHours()) +
    pad(now.getMinutes()) +
    pad(now.getSeconds())
  );
}

function copyFile(source, destination) {
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  fs.copyFileSync(source, destination);
}

function copyDirectoryContents(sourceDir, destinationDir) {
  fs.mkdirSync(destinationDir, { recursive: true });
  for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
    const from = path.join(sourceDir, entry.name);
    const to = path.join(destinationDir, entry.name);
    if (entry.isDirectory()) {
      copyDirectoryContents(from, to);
    } else {
      copyFile(from, to);
    }
  }
}

function git(cwd, gitArgs) {
  return spawnSync('git', gitArgs, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
}

function initTrial(flags, positional) {
  const trialName = positional[0] || `Trial-${timestampName()}`;
  let targetRepo;

  if (flags.target) {
    targetRepo = path.resolve(flags.target);
    if (!fs.existsSync(targetRepo) || !fs.statSync(targetRepo).isDirectory()) {
      fail(`Target path is not a directory: ${targetRepo}`);
    }
    console.log(`-> Injecting into existing repository at: ${targetRepo}`);
    const conflicts = [
      'docs/planning.md',
      '.agents/skills/agent-loop.md',
      'docs/agent-loop/outer-loop-playbook.md',
    ];
    for (const relative of conflicts) {
      if (fs.existsSync(path.join(targetRepo, relative))) {
        fail(`Conflict detected: '${relative}' already exists in the target repository. Scaffolding aborted.`);
      }
    }
  } else {
    targetRepo = path.resolve(process.cwd(), '..', trialName);
    if (fs.existsSync(targetRepo)) {
      fail(`Target directory already exists: ${targetRepo}`);
    }
  }

  console.log('');
  console.log('====================================================');
  console.log('  SCAFFOLDING NEW AGENTIC TRIAL');
  console.log('====================================================');
  console.log(`Location: ${targetRepo}`);

  const docsDir = path.join(targetRepo, 'docs');
  const stateDir = path.join(docsDir, 'state');
  const archiveDir = path.join(stateDir, 'archive');
  const templatesDir = path.join(docsDir, 'templates');
  const agentLoopDir = path.join(docsDir, 'agent-loop');
  const skillsDir = path.join(targetRepo, '.agents', 'skills');
  const scriptsDir = path.join(targetRepo, 'scripts');

  fs.mkdirSync(archiveDir, { recursive: true });
  fs.mkdirSync(templatesDir, { recursive: true });
  fs.mkdirSync(agentLoopDir, { recursive: true });
  fs.mkdirSync(skillsDir, { recursive: true });
  fs.mkdirSync(scriptsDir, { recursive: true });

  const sourceTemplates = path.join(PACKAGE_ROOT, 'docs', 'agent-loop', 'templates');
  console.log('-> Copying templates to docs/templates...');
  copyDirectoryContents(sourceTemplates, templatesDir);

  console.log('-> Seeding active state documents...');
  copyFile(path.join(templatesDir, 'handover.md'), path.join(stateDir, 'handover.md'));
  copyFile(path.join(templatesDir, 'backlog.md'), path.join(stateDir, 'backlog.md'));
  copyFile(path.join(templatesDir, 'progress.md'), path.join(stateDir, 'progress.md'));

  console.log('-> Registering agent-loop.md skill...');
  const sourceSkill = path.join(PACKAGE_ROOT, 'docs', 'agent-loop', 'skill.md');
  copyFile(sourceSkill, path.join(skillsDir, 'agent-loop.md'));
  copyFile(sourceSkill, path.join(agentLoopDir, 'skill.md'));

  console.log('-> Copying agent loop coding standards...');
  copyFile(
    path.join(PACKAGE_ROOT, 'docs', 'agent-loop', 'standards.md'),
    path.join(agentLoopDir, 'standards.md')
  );
  copyFile(
    path.join(PACKAGE_ROOT, 'docs', 'agent-loop', 'standards.sample.md'),
    path.join(agentLoopDir, 'standards.sample.md')
  );

  console.log('-> Copying outer loop playbook...');
  copyFile(
    path.join(PACKAGE_ROOT, 'docs', 'agent-loop', 'outer-loop-playbook.md'),
    path.join(agentLoopDir, 'outer-loop-playbook.md')
  );

  console.log('-> Seeding planning document...');
  copyFile(path.join(sourceTemplates, 'planning.md'), path.join(docsDir, 'planning.md'));

  console.log('-> Copying operator scripts...');
  for (const scriptName of [
    'check-health.ps1',
    'check-health.sh',
    'run-loop.ps1',
    'run-loop.sh',
    'archive-backlog.ps1',
    'inject-skill.ps1',
  ]) {
    const sourceScript = path.join(PACKAGE_ROOT, 'scripts', scriptName);
    if (fs.existsSync(sourceScript)) {
      copyFile(sourceScript, path.join(scriptsDir, scriptName));
    }
  }

  const gitDir = path.join(targetRepo, '.git');
  if (!fs.existsSync(gitDir)) {
    console.log('-> Initializing Git and committing scaffolding...');
    if (git(targetRepo, ['init']).status !== 0) {
      fail('git init failed.');
    }
    git(targetRepo, ['add', '.']);
    const commit = git(targetRepo, [
      'commit',
      '-m',
      'chore: scaffold trial repo with agent loop skills and state templates',
    ]);
    if (commit.status !== 0) {
      fail(commit.stderr || 'git commit failed.');
    }
  } else {
    console.log('-> Existing Git repository detected. Staging agent harness files...');
    git(targetRepo, ['add', 'docs', '.agents', 'scripts']);
    const commit = git(targetRepo, ['commit', '-m', 'chore: integrate agent loop harness']);
    if (commit.status !== 0) {
      fail(commit.stderr || 'git commit failed.');
    }
  }

  console.log('');
  console.log('SUCCESS: Agentic Loop Harness scaffolded successfully.');
  console.log(`  Location: ${targetRepo}`);
  console.log('');
  console.log('[NEXT STEPS]');
  console.log(`  1. cd "${targetRepo}"`);
  console.log('  2. Populate docs/planning.md and docs/state/backlog.md');
  console.log('  3. Run: git status && npx @nikcholer/agentic-loop-harness health');
  console.log(`  4. grok -p "${LOOP_PROMPT}" --always-approve --max-turns 15`);
  console.log('');
}

function readIfExists(filePath) {
  return fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
}

function allBacklogItemsComplete(repositoryRoot) {
  const backlogPath = path.join(repositoryRoot, 'docs', 'state', 'backlog.md');
  if (!fs.existsSync(backlogPath)) {
    return false;
  }
  const matches = [...readIfExists(backlogPath).matchAll(/^\s*[-*]\s+\[([xX ])\]/gm)];
  if (matches.length === 0) {
    return false;
  }
  return matches.every((match) => match[1] !== ' ');
}

function porcelainStatus(repositoryRoot) {
  const result = git(repositoryRoot, ['status', '--porcelain']);
  if (result.status !== 0) {
    fail(result.stderr || 'git status failed. Is this a git repository?');
  }
  return result.stdout
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
}

function checkHealth(flags) {
  const repositoryRoot = path.resolve(flags.cwd || process.cwd());
  const tbdPath = path.join(repositoryRoot, 'docs', 'state', 'tbd.md');
  const tbdResponsePath = path.join(repositoryRoot, 'docs', 'state', 'tbd-response.md');
  const issues = [];
  const notes = [];

  const inside = git(repositoryRoot, ['rev-parse', '--is-inside-work-tree']);
  if (inside.status !== 0 || String(inside.stdout).trim() !== 'true') {
    fail('Not a git repository.');
  }

  if (fs.existsSync(tbdPath) && !fs.existsSync(tbdResponsePath)) {
    issues.push('Unresolved blocker: docs/state/tbd.md exists without docs/state/tbd-response.md.');
  }

  if (porcelainStatus(repositoryRoot).length > 0) {
    issues.push('Uncommitted changes detected in the repository.');
  }

  if (allBacklogItemsComplete(repositoryRoot)) {
    notes.push('All backlog items are complete. Consider tagging a milestone before adding new work.');
  }

  if (flags.verify && flags.verify.length > 0) {
    console.log(`Running baseline verification command: ${flags.verify.join(' ')}`);
    const verification = spawnSync(flags.verify[0], flags.verify.slice(1), {
      cwd: repositoryRoot,
      encoding: 'utf8',
      stdio: 'inherit',
      shell: process.platform === 'win32',
    });
    if (verification.status !== 0) {
      issues.push('Baseline verification command failed.');
    } else {
      notes.push('Baseline verification command passed.');
    }
  } else {
    notes.push('Skipped baseline verification; pass --verify <command ...> to run project-specific checks.');
  }

  for (const note of notes) {
    console.log(note);
  }

  if (issues.length > 0) {
    for (const issue of issues) {
      console.log(issue);
    }
    console.log('Fix before running');
    process.exit(1);
  }

  console.log('Ready');
}

function tbdPathFor(repositoryRoot) {
  return path.join(repositoryRoot, 'docs', 'state', 'tbd.md');
}

function tbdResponsePathFor(repositoryRoot) {
  return path.join(repositoryRoot, 'docs', 'state', 'tbd-response.md');
}

function tbdBlocksRun(repositoryRoot) {
  return fs.existsSync(tbdPathFor(repositoryRoot)) && !fs.existsSync(tbdResponsePathFor(repositoryRoot));
}

function tbdPairReady(repositoryRoot) {
  return fs.existsSync(tbdPathFor(repositoryRoot)) && fs.existsSync(tbdResponsePathFor(repositoryRoot));
}

function failDirtyAfterSuccess(repositoryRoot) {
  const dirty = porcelainStatus(repositoryRoot);
  process.stderr.write(
    'Stop: provider exited 0 but left uncommitted changes. Treat this as a harness failure, not a green run.\n'
  );
  for (const line of dirty) {
    process.stderr.write(`  ${line}\n`);
  }
  process.exit(1);
}

function sleep(ms) {
  Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);
}

function waitForResponse(repositoryRoot) {
  console.log('Waiting for docs/state/tbd-response.md ... (Ctrl+C to stop)');
  while (!fs.existsSync(tbdResponsePathFor(repositoryRoot))) {
    sleep(5000);
  }
}

function quoteForWindowsCmd(arg) {
  const value = String(arg);
  if (value === '') {
    return '""';
  }
  if (!/[\s"&<>|^()]/.test(value)) {
    return value;
  }
  return `"${value.replace(/"/g, '""')}"`;
}

function invokeProvider(flags, commandParts, repositoryRoot) {
  const options = {
    cwd: repositoryRoot,
    encoding: 'utf8',
    stdio: 'inherit',
  };

  if (flags.command) {
    return spawnSync(flags.command, { ...options, shell: true });
  }

  // Never pass an argv array through shell:true. cmd.exe re-tokenizes and
  // splits the -p prompt on spaces. On Windows, quote into one command line
  // so .cmd/.ps1 shims still run. On Unix, spawn argv directly.
  if (process.platform === 'win32') {
    return spawnSync(commandParts.map(quoteForWindowsCmd).join(' '), {
      ...options,
      shell: true,
    });
  }

  return spawnSync(commandParts[0], commandParts.slice(1), options);
}

function runLoop(flags) {
  const repositoryRoot = path.resolve(flags.cwd || process.cwd());
  const maxRuns = Number.parseInt(flags.maxRuns || '3', 10);
  if (!Number.isFinite(maxRuns) || maxRuns < 1) {
    fail('--max-runs must be a positive integer.');
  }

  let commandParts;
  if (flags.command) {
    commandParts = null;
  } else if (flags.provider) {
    const preset = PROVIDER_COMMANDS[flags.provider];
    if (!preset) {
      fail(`Unknown provider '${flags.provider}'. Choose one of: ${Object.keys(PROVIDER_COMMANDS).join(', ')}`);
    }
    commandParts = preset;
  } else {
    fail('Pass --provider <name> or --command "<shell command>".');
  }

  for (let run = 1; run <= maxRuns; run += 1) {
    if (tbdBlocksRun(repositoryRoot)) {
      console.log(`Stop: unresolved TBD at docs/state/tbd.md (before run ${run}).`);
      if (flags.waitForResponse) {
        waitForResponse(repositoryRoot);
      } else {
        process.exit(0);
      }
    }

    if (!tbdPairReady(repositoryRoot)) {
      checkHealth({ cwd: repositoryRoot });
    }

    console.log(`\n=== Loop run ${run} of ${maxRuns} ===`);
    const result = invokeProvider(flags, commandParts, repositoryRoot);

    if (result.status !== 0) {
      fail(`Provider command exited with status ${result.status}.`);
    }

    if (tbdBlocksRun(repositoryRoot)) {
      console.log('Stop: agent published docs/state/tbd.md. Resolve it before the next run.');
      if (flags.waitForResponse && run < maxRuns) {
        waitForResponse(repositoryRoot);
        continue;
      }
      process.exit(0);
    }

    if (porcelainStatus(repositoryRoot).length > 0) {
      failDirtyAfterSuccess(repositoryRoot);
    }
  }

  console.log(`Completed ${maxRuns} successful run(s). Outer loop stopped at the --max-runs cap.`);
}

function main() {
  const { command, flags, positional } = parseArgs(process.argv);
  if (flags.help || command === 'help' || command === '--help' || command === '-h') {
    usage(0);
  }

  switch (command) {
    case 'init':
      initTrial(flags, positional);
      break;
    case 'health':
      checkHealth(flags);
      break;
    case 'run':
      runLoop(flags);
      break;
    default:
      fail(`Unknown command: ${command}`);
  }
}

main();
