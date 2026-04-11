# Agent Handover

## Current Sprint Context
- **Current Epic/Goal:** Quality of Life - improve operator prompts and self-hosting guidance.
- **Last File Edited:** `docs/state/handover.md`
- **Current Status:** Completed the second Known Environment Gotchas item by adding a second `## Known Environment Gotchas` entry to `docs/agent-loop/outer-loop-playbook.md`, documenting that monolithic `prisma.$transaction([...N upserts])` seeders can exhaust the Node heap above roughly 5,000 rows and should always be batched.
- **Current Blockers:** None.

## Relevant Architectural Context
- *`docs/agent-loop/outer-loop-playbook.md` now records two standing gotchas: BOM-safe CSV generation for PowerShell 5.1 and bounded batching for large Prisma seeders, giving operators a canonical checklist for two high-cost failure modes observed in prior runs.*
- *The seeder guidance focuses on memory pressure before database limits: the failure happens while Prisma and Node build the transaction payload, so batching is recommended even when the database could theoretically accept a larger write.*
- *`docs/state/backlog.md` still remains comfortably below the archival threshold, so no backlog size warning is needed in this handover.*

## Primary Immediate Next Step
- Start the first remaining Quality of Life item: add an optional `## Token Usage` note to the `docs/state/handover.md` template so agents can record approximate token consumption per run and the outer loop can monitor context budget trends.
