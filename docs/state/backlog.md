# Project Backlog

> This is the active backlog for the `loop-design-build` self-improvement run.
> Source of requirements: `docs/meta-backlog.md` and `docs/planning.md`.

## Critical Fixes

- [x] **`standards.md` not propagated to trial repos:** `init-trial.ps1` now creates `docs/agent-loop/` in new trial scaffolds and copies `docs/agent-loop/standards.md` into it before the initial `git commit`.

- [ ] **`outer-loop-playbook.md` also absent from trial scaffold:** Same issue — copy it alongside `standards.md` into `docs/agent-loop/` in each new trial, or decide it is harness-only and remove the implicit expectation from `skill.md`.

- [ ] **`planning.md` template too sparse:** Current template is a one-liner stub. Replace with a structured template containing headed sections (`## Domain Overview`, `## Data Sources / Requirements`, `## Technical Constraints`, `## Preferred Stack`, `## Out of Scope`) with placeholder guidance text so the agent's first-run context intake is anchored.

## Outer Loop Tooling

- [ ] **Automated backlog archival script:** Add `scripts/archive-backlog.ps1` implementing the procedure from `outer-loop-playbook.md`: scans `docs/state/backlog.md` for fully-completed sections (all items `[x]`), appends them to `backlog-archive.md` with a datestamp, removes them from the active file, and commits the pair.

- [ ] **Pre-run health check script:** Add `scripts/check-health.ps1` that verifies: (a) no `tbd.md` without a matching `tbd-response.md`, (b) no uncommitted changes in `docs/state/`, (c) optionally runs `npm test -- --runInBand` if a `package.json` is detected. Prints `✅ Ready` or `❌ Fix before running`.

- [ ] **`progress.md` archival — same pattern as backlog:** Update `outer-loop-playbook.md` to document `progress-archive.md` archival on the same trigger as the backlog. The active `progress.md` should contain only the current sprint's entries.

- [ ] **Rollback procedure in `outer-loop-playbook.md`:** Document what to do when an agent run produces bad output: `git revert` vs `git reset --hard`, how to restore `handover.md` to the previous context, and whether to re-run the test baseline before the next loop.

## Skill System

- [ ] **Skill injection via `planning.md`:** Document (and optionally script) a `## Skills` section in the `planning.md` template where the operator lists skill names to activate. `init-trial.ps1` (or a new `inject-skill.ps1`) copies the named skill files from `~/.agents/skills/` into the trial's `.agents/skills/` directory.

- [ ] **Skill discovery in `skill.md`:** Add a Phase 2 step instructing the agent to check `.agents/skills/` for any files beyond `agent-loop.md` and internalize them as supplementary guidance before beginning work.

## Known Environment Gotchas

- [ ] **Document PowerShell BOM gotcha:** Add a `## Known Environment Gotchas` section to `outer-loop-playbook.md`. First entry: PowerShell 5.1's `Set-Content` and `Out-File` emit a UTF-8 BOM by default, silently corrupting the first CSV column header. Safe alternatives: `Out-File -Encoding utf8NoBOM` or strip with Node before seeding.

- [ ] **Document monolithic seeder transaction limit:** Add to `outer-loop-playbook.md` gotchas: passing all N rows into a single `prisma.$transaction([...N upserts])` causes Node heap exhaustion above ~5,000 rows. Always batch large seeder operations.

## Quality of Life

- [ ] **Token usage logging:** Add an optional `## Token Usage` note to the `handover.md` template so agents can record approximate token consumption per run, giving the outer loop visibility of context budget trends.

- [ ] **Milestone tagging reminder in health check:** When `check-health.ps1` detects all backlog items are complete, prompt the operator to tag a milestone before adding new work.

- [ ] **Self-improvement mode:** Update `README.md` and `outer-loop-playbook.md` to document running the harness on itself (as demonstrated in this run): drop `docs/state/` directly into `loop-design-build`, write `docs/planning.md` describing the harness as the target codebase, and run `codex exec` from the root — no trial scaffolding required.
