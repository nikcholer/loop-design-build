# Agent Handover

## Current Sprint Context
- **Current Epic/Goal:** Skill System - making skill activation repeatable inside trial repos.
- **Last File Edited:** `docs/state/handover.md`
- **Current Status:** Completed the first Skill System item by adding a documented `## Skills` section to the scaffolded `docs/planning.md` template, implementing `scripts/inject-skill.ps1` to copy requested local skills into trial repos, and documenting the operator flow in `docs/agent-loop/README.md`.
- **Current Blockers:** None.

## Relevant Architectural Context
- *`init-trial.ps1` now seeds a dedicated `## Skills` section in each new trial's `docs/planning.md`, giving the operator a single source of truth for optional skill activation at planning time.*
- *The new helper `scripts/inject-skill.ps1` reads that section, deduplicates listed skill names, and copies matching directories or `.md` files from `~/.agents/skills/` into the target repo's `.agents/skills/` folder.*
- *`docs/agent-loop/README.md` now documents the helper-based workflow, which keeps `init-trial.ps1` focused on scaffolding while letting skill injection happen after the operator fills out the planning document.*
- *`docs/state/backlog.md` remains comfortably below the archival threshold, so no backlog size warning is needed in this handover.*

## Primary Immediate Next Step
- Start the second Skill System item: update `.agents/skills/agent-loop.md` and `docs/agent-loop/skill.md` so Phase 2 explicitly scans `.agents/skills/` for any files beyond `agent-loop.md` and internalizes them before execution begins.
