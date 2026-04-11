# Agent Handover

## Current Sprint Context
- **Current Epic/Goal:** Quality of Life - improve operator prompts and self-hosting guidance.
- **Last File Edited:** `docs/state/handover.md`
- **Current Status:** Completed the first Quality of Life item by adding an optional `## Token Usage` section to `docs/agent-loop/templates/handover.md`, so future handovers have a standard place to record approximate per-run token usage when available.
- **Current Blockers:** None.

## Token Usage
- Approximate token usage was not surfaced in this environment.

## Relevant Architectural Context
- *`init-trial.ps1` copies `docs/agent-loop/templates/handover.md` into each scaffolded repo's `docs/state/handover.md`, so updating the template propagates the new section to future trial repos without changing the scaffold flow.*
- *The new `## Token Usage` section is intentionally optional and informational only; agents can leave it untouched when runtime token metrics are unavailable.*
- *`docs/state/backlog.md` remains comfortably below the archival threshold, so no backlog size warning is needed in this handover.*

## Primary Immediate Next Step
- Start the remaining Quality of Life task in `docs/state/backlog.md`: update `scripts/check-health.ps1` so that when all backlog items are complete it reminds the operator to tag a milestone before adding new work.
