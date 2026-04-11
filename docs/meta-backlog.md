# loop-design-build: Meta Backlog

Improvements to the harness itself, derived from observations during Trial-20260409145641.

---

## Critical Fixes (Broken by Design)

- [ ] **`standards.md` not propagated to trial repos:** `init-trial.ps1` copies `skill.md` to `.agents/skills/agent-loop.md` but does not copy `docs/agent-loop/standards.md` into the trial scaffold. `skill.md` instructs agents to read `docs/agent-loop/standards.md` on boot, but that path does not exist in a freshly-created trial — the read silently fails. Fix: add a `Copy-Item` for `standards.md` into the trial's `docs/agent-loop/` directory (creating the folder if needed), and ensure `git init` picks it up in the first commit.

- [ ] **`outer-loop-playbook.md` also absent from trial scaffold:** Same issue — it lives only in the harness repo and is invisible inside a trial. Either copy it into the trial or move the reference in `skill.md` to point to a path that exists. Alternatively, consolidate `outer-loop-playbook.md` as a human-facing document that lives solely in the harness and is not expected inside trials — in which case the skill should not reference it.

- [ ] **`planning.md` template is too blank:** The current template is a single stub line. A first-run agent reading a near-empty `planning.md` has to hallucinate structure. Provide a structured template with headed sections: `## Domain Overview`, `## Data Sources`, `## Technical Constraints`, `## Preferred Stack`, `## Out of Scope`. Even with placeholder text, this scaffolds the agent's context intake and reduces first-loop drift.

---

## Outer Loop Tooling

- [ ] **Automated backlog archival script:** Add `scripts/archive-backlog.ps1` (or `.sh`) that implements the procedure from `outer-loop-playbook.md` automatically: scans `docs/state/backlog.md` for fully-completed sections, appends them to `backlog-archive.md` with a datestamp, removes them from the active file, and commits the pair. Reduces this to a single command the human runs between milestones.

- [ ] **Pre-run health check script:** Add `scripts/check-health.ps1` that the human operator runs before kicking off the next agent loop. Checks: (a) test suite is green (`npm test -- --runInBand`), (b) no uncommitted changes, (c) no `tbd.md` present without a `tbd-response.md`. Prints a clear `✅ Ready` or `❌ Fix before running` summary. Prevents burning a full agent run on a broken baseline.

- [ ] **`progress.md` archival — same pattern as backlog:** `progress.md` grows unboundedly in the same way. Add `progress-archive.md` to the outer loop archival procedure and update `outer-loop-playbook.md` accordingly. The active `progress.md` should contain only the current sprint; older entries move to archive.

- [ ] **Rollback procedure in `outer-loop-playbook.md`:** Document what to do when an agent run produces bad output: which git commands to run (`git revert` vs `git reset --hard`), how to edit `handover.md` to recover the previous context, and whether to restore the test baseline before re-running. Currently this is entirely undocumented.

---

## Skill System

- [ ] **Formal skill injection pattern:** We manually read the `frontend-design` skill and injected its design brief into the backlog by hand. Document and potentially automate this: add a `## Skills` section to `planning.md` where the operator lists skill names to activate, and have the `init-trial.ps1` (or a separate `inject-skill.ps1`) copy the requested skill files from `~/.agents/skills/` into the trial's `.agents/skills/` directory so the agent can discover them on boot.

- [ ] **Skill discovery in `skill.md`:** Add a Phase 2 step instructing the agent to check `.agents/skills/` for any skill files beyond `agent-loop.md` and internalize them as supplementary guidance before beginning work.

---

## Known Environment Gotchas (Document in `outer-loop-playbook.md`)

- [ ] **PowerShell BOM on `Set-Content`:** PowerShell 5.1's `Set-Content` and `Out-File` emit a UTF-8 BOM by default. Any CSV/data file written or sliced via PowerShell will be silently prefixed with `\xEF\xBB\xBF`, which corrupts the first column header. Document the safe alternative: `Out-File -Encoding utf8NoBOM` or strip the BOM explicitly with Node before seeding. Add this as a callout in `outer-loop-playbook.md` under a `## Known Environment Gotchas` section.

- [ ] **Monolithic seeder transactions with large datasets:** Passing all N rows into a single `prisma.$transaction([...N upserts])` causes Node heap exhaustion above ~5,000 rows. The fix (batching into `BATCH_SIZE` chunks) is now in `standards.md` implicitly, but it is worth explicitly calling out in the `planning.md` template as a constraint: *"If seeding more than 1,000 records, batch transactions — do not issue a single monolithic transaction."*

---

## Quality of Life

- [ ] **Token usage logging:** Each agent run currently exits with no record of how many tokens it consumed. Add an optional `## Token Usage` line to `handover.md` serialization so the outer loop can track context budget consumption per run and identify runs that are approaching model limits.

- [ ] **Milestone tagging reminder in health check script:** The pre-run health check should surface a prompt when all current backlog items are checked off: *"All items complete — consider tagging a milestone before adding new work: `git tag -a v0.x.0 -m '...'`"*
