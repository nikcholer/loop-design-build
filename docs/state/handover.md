# Agent Handover

## Current Sprint Context
- **Current Epic/Goal:** Known Environment Gotchas - capture repeatable failure modes in operator guidance.
- **Last File Edited:** `docs/state/handover.md`
- **Current Status:** Completed the first Known Environment Gotchas item by adding a `## Known Environment Gotchas` section to `docs/agent-loop/outer-loop-playbook.md` and documenting the PowerShell 5.1 UTF-8 BOM seed-file hazard together with the safe `Out-File -Encoding utf8NoBOM` and Node BOM-stripping mitigations.
- **Current Blockers:** None.

## Relevant Architectural Context
- *`docs/agent-loop/outer-loop-playbook.md` now has a dedicated `## Known Environment Gotchas` section, giving the outer loop a canonical place to record repeatable environment-specific failures before they recur in future trials.*
- *The first gotcha captures a PowerShell-only encoding pitfall that surfaces as corrupted seed CSV headers rather than an obvious write failure, so operator guidance now emphasizes BOM-safe file generation when exact header matching matters.*
- *`docs/state/backlog.md` remains comfortably below the archival threshold, so no backlog size warning is needed in this handover.*

## Primary Immediate Next Step
- Start the second Known Environment Gotchas item: add a second entry to `docs/agent-loop/outer-loop-playbook.md` documenting that passing all rows into a single `prisma.$transaction([...N upserts])` can exhaust the Node heap above roughly 5,000 rows and that large seeders should always batch work.
