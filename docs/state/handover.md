# Handover Document

**Last Agent Exited At:** N/A — this is the first run of the self-improvement loop on `loop-design-build`.

## Primary Immediate Next Step
- Read `docs/planning.md` to understand the project context (this is a meta-improvement run on the harness itself, not a data-driven trial).
- Read `docs/state/backlog.md` and begin the **Critical Fixes** section — specifically the `standards.md` propagation fix in `init-trial.ps1`.
- No test suite exists for PowerShell scripts; validate by reading the modified script carefully and performing a dry-run trace before committing.

## Active Context
- **Current Epic/Goal:** Critical Fixes — ensuring newly scaffolded trial repos receive the correct set of harness support files.
- **Last File Modified:** `docs/state/handover.md` (this file, initial seed)
- **Current Status:** Fresh start. No code has been modified yet.
- **Current Blockers:** None.

## Relevant Architectural Context
- *This repo operates without a build step or test runner. Validation is by inspection and manual dry-run.*
- *`init-trial.ps1` is the primary file to modify for the Critical Fixes epic — it scaffolds all new trial repos.*
- *`docs/agent-loop/` contains the canonical versions of `skill.md`, `standards.md`, and `outer-loop-playbook.md`. The init script copies from here into trials.*
- *Do not use `docs/meta-backlog.md` as the working backlog — use `docs/state/backlog.md` (this file's sibling). `meta-backlog.md` is the source-of-requirements reference only.*
