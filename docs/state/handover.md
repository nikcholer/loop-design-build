# Agent Handover

## Current Sprint Context
- **Current Epic/Goal:** Skill System - making skill activation repeatable inside trial repos.
- **Last File Edited:** `docs/state/handover.md`
- **Current Status:** Completed the fourth Outer Loop Tooling item by updating `docs/agent-loop/outer-loop-playbook.md` with rollback guidance for bad agent runs, including `git revert` versus `git reset --hard`, `docs/state/handover.md` recovery, and baseline-test expectations before resuming the loop.
- **Current Blockers:** None.

## Relevant Architectural Context
- *`docs/agent-loop/outer-loop-playbook.md` now includes a dedicated rollback section that distinguishes between preserving shared history with `git revert` and discarding safe local history with `git reset --hard`.*
- *The playbook now explicitly tells the outer-loop operator how `docs/state/handover.md` behaves under revert versus reset, and when to restore that file from a known-good commit before restarting.*
- *Baseline recovery guidance now lives beside the rollback steps, so the operator can verify a clean `git status` and rerun the project's normal checks before invoking the next agent run.*
- *`docs/state/backlog.md` remains comfortably below the archival threshold, so no backlog size warning is needed in this handover.*

## Primary Immediate Next Step
- Start the first Skill System item: document a `## Skills` section in the `docs/planning.md` template and decide whether `init-trial.ps1` should copy named skills directly or delegate that work to a new `inject-skill.ps1` helper.
