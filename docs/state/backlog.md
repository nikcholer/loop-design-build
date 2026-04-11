# Project Backlog

> This is the active backlog for the `loop-design-build` self-improvement run.
> Source of requirements: `docs/meta-backlog.md` and `docs/planning.md`.

## Critical Fixes

- [x] **`standards.md` not propagated to trial repos:** `init-trial.ps1` now creates `docs/agent-loop/` in new trial scaffolds and copies `docs/agent-loop/standards.md` into it before the initial `git commit`.

- [x] **`outer-loop-playbook.md` also absent from trial scaffold:** `init-trial.ps1` now copies `docs/agent-loop/outer-loop-playbook.md` alongside `standards.md` into each new trial repo's `docs/agent-loop/` directory before the initial `git commit`.

- [x] **`planning.md` template too sparse:** `init-trial.ps1` now seeds `docs/planning.md` with a structured template containing `## Domain Overview`, `## Data Sources / Requirements`, `## Technical Constraints`, `## Preferred Stack`, and `## Out of Scope`, each with placeholder guidance text for first-run context intake.

## Outer Loop Tooling

- [x] **Automated backlog archival script:** Added `scripts/archive-backlog.ps1` implementing the procedure from `outer-loop-playbook.md`: scans `docs/state/backlog.md` for fully-completed sections (all items `[x]`), appends them to `backlog-archive.md` with a datestamp, removes them from the active file, and commits the pair.

- [x] **Pre-run health check script:** Added `scripts/check-health.ps1` to verify: (a) no `tbd.md` without a matching `tbd-response.md`, (b) no uncommitted changes in `docs/state/`, (c) optionally run `npm test -- --runInBand` when invoked with `-RunTestsIfPresent` and a `package.json` is present. Prints `✅ Ready` or `❌ Fix before running` and exits non-zero on failures.

- [x] **`progress.md` archival — same pattern as backlog:** Updated `docs/agent-loop/outer-loop-playbook.md` to document `progress-archive.md` archival on the same trigger as the backlog. The active `progress.md` should contain only the current sprint's entries.

- [x] **Rollback procedure in `outer-loop-playbook.md`:** Documented recovery steps for bad agent runs in `docs/agent-loop/outer-loop-playbook.md`, including when to use `git revert` versus `git reset --hard`, how to restore `docs/state/handover.md`, and when to rerun the test baseline before restarting the loop.

## Skill System

- [x] **Skill injection via `planning.md`:** `init-trial.ps1` now seeds a documented `## Skills` section in the `planning.md` template, and `scripts/inject-skill.ps1` copies the named skill folders or markdown files from `~/.agents/skills/` into the trial's `.agents/skills/` directory.

- [x] **Skill discovery in `skill.md`:** Add a Phase 2 step instructing the agent to check `.agents/skills/` for any files beyond `agent-loop.md` and internalize them as supplementary guidance before beginning work.

## Known Environment Gotchas

- [x] **Document PowerShell BOM gotcha:** Added a `## Known Environment Gotchas` section to `docs/agent-loop/outer-loop-playbook.md`. First entry documents how PowerShell 5.1's `Set-Content` and `Out-File` emit a UTF-8 BOM by default, silently corrupting the first CSV column header, and records the safe `Out-File -Encoding utf8NoBOM` and Node BOM-stripping alternatives.

- [ ] **Document monolithic seeder transaction limit:** Add to `outer-loop-playbook.md` gotchas: passing all N rows into a single `prisma.$transaction([...N upserts])` causes Node heap exhaustion above ~5,000 rows. Always batch large seeder operations.

## Quality of Life

- [ ] **Token usage logging:** Add an optional `## Token Usage` note to the `handover.md` template so agents can record approximate token consumption per run, giving the outer loop visibility of context budget trends.

- [ ] **Milestone tagging reminder in health check:** When `check-health.ps1` detects all backlog items are complete, prompt the operator to tag a milestone before adding new work.

- [ ] **Self-improvement mode:** Update `README.md` and `outer-loop-playbook.md` to document running the harness on itself (as demonstrated in this run): drop `docs/state/` directly into `loop-design-build`, write `docs/planning.md` describing the harness as the target codebase, and run `codex exec` from the root — no trial scaffolding required.
