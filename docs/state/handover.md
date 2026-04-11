# Agent Handover

## Current Sprint Context
- **Current Epic/Goal:** Known Environment Gotchas - capture repeatable failure modes in operator guidance.
- **Last File Edited:** `docs/state/handover.md`
- **Current Status:** Completed the second Skill System item by updating both `.agents/skills/agent-loop.md` and `docs/agent-loop/skill.md` so Phase 2 now scans `.agents/skills/` for supplementary skills beyond `agent-loop.md` and reads each discovered skill entrypoint before execution starts.
- **Current Blockers:** None.

## Relevant Architectural Context
- *The agent-loop instructions now keep scaffolded trial repos and the canonical `docs/agent-loop/skill.md` in lockstep, reducing drift between the copied skill file and the source documentation.*
- *Phase 2 now explicitly handles both standalone markdown skills and directory-based skills with a `SKILL.md` entrypoint, matching the behavior introduced by `scripts/inject-skill.ps1`.*
- *`docs/state/backlog.md` remains comfortably below the archival threshold, so no backlog size warning is needed in this handover.*

## Primary Immediate Next Step
- Start the first Known Environment Gotchas item: add a `## Known Environment Gotchas` section to `docs/agent-loop/outer-loop-playbook.md` documenting the PowerShell 5.1 UTF-8 BOM issue, including the safe `Out-File -Encoding utf8NoBOM` alternative and the option to strip the BOM with Node before seeding.
