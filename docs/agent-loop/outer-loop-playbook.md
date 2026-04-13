# Outer Loop Playbook

The **outer loop** is everything that happens *between* individual agent runs: the human product owner, the orchestration chat, and any tooling that kicks off the next `codex exec`. This document records the recurring responsibilities of the outer loop operator.

> **Note for agents:** This document describes duties performed by the *human orchestrator* between runs. It does not modify or supersede any phase in `skill.md`. In particular, **Phase 6 (git commit) remains mandatory** — agents must always commit at the end of a successful run regardless of anything written here.

---

## First-Time Bootstrap

If you are starting from a new project idea, use `init-trial.ps1` to create a scaffolded trial repo and work there.

If you are taking over an existing repository, prefer adopting the harness **in place**. Do not copy the target codebase into a wrapper folder unless you know the project is location-independent and want an isolated clone. Many repos have path-sensitive scripts, workspace settings, or local integration assumptions.

For an existing repo, bootstrap it like this before the first run:
1. Copy `docs/agent-loop/skill.md` from this harness repo into `.agents/skills/agent-loop.md` in the target repo.
2. Copy `docs/agent-loop/standards.md` and `docs/agent-loop/outer-loop-playbook.md` into `docs/agent-loop/` in the target repo.
3. Copy the files from `docs/agent-loop/templates/` into the target repo.
4. Create `docs/state/` and `docs/state/archive/`.
5. Seed `docs/state/handover.md`, `docs/state/backlog.md`, and `docs/state/progress.md` from the matching templates.
6. Create `docs/planning.md` from the planning template and fill it with the current architecture, supplied artefacts, constraints, current known priorities, and out-of-scope items.
7. Review the seeded backlog and handover files so the first run starts from intentional context rather than generic placeholders.

If `docs/` or `.agents/` already exists in the target repo, merge these files into the existing structure rather than renaming project folders or moving the codebase.

---

## State Archival

**Trigger:** The agent flags `## Backlog Size Warning` in `handover.md`, or the active `backlog.md` exceeds ~80 lines.

**Why the agent doesn't do this itself:** The agent is scoped to a single atomic task. Rewriting its own state files is a meta-operation that risks silently discarding context. The human orchestrator has full visibility of what is truly "done and safe to archive."

### Backlog Procedure

1. Open `docs/state/backlog.md`.
2. Identify all fully-completed sections — these are sections where every item (including all sub-items) is marked `[x]`. Partially-completed sections stay in the active backlog.
3. Create or append to `docs/state/backlog-archive.md`. Prepend each archived section with a datestamp:
   ```markdown
   ## [Archived: YYYY-MM-DD] High Priority Queue
   ...
   ```
4. Delete the archived sections from `backlog.md`, keeping only the active/incomplete sections.
5. Commit the pair of changes together:
   ```
   chore(state): archive completed backlog sections [YYYY-MM-DD]
   ```

### Progress Procedure

Archive `docs/state/progress.md` on the same trigger as backlog archival so the active progress log stays scoped to the current sprint.

1. Open `docs/state/progress.md`.
2. Identify completed sprint sections that are no longer part of the active workstream.
3. Create or append to `docs/state/progress-archive.md`. Prepend each archived sprint section with a datestamp:
   ```markdown
   ## [Archived: YYYY-MM-DD] Self-Improvement Sprint 1
   ...
   ```
4. Delete the archived sprint sections from `progress.md`, leaving only the current sprint's entries in the active file.
5. If backlog archival is happening in the same pass, commit all state-file changes together:
   ```
   chore(state): archive completed backlog and progress sections [YYYY-MM-DD]
   ```

If only `progress.md` needs archival, commit the pair of progress-file changes together:
```
chore(state): archive completed progress sections [YYYY-MM-DD]
```

---

## Steering the Next Sprint

At any point between runs, the human orchestrator may:

- **Inject new backlog items** directly into `backlog.md` under a new section labelled `(Added by Human)` — the agent will pick these up on the next boot.
- **Redirect the next run** by editing the `## Primary Immediate Next Step` in `handover.md`.
- **Add design or standards guidance** by editing `docs/agent-loop/standards.md` — changes take effect on the next agent boot.
- **Write a TBD response** by creating `docs/state/tbd-response.md` if the agent has paused for human input.

---

## Starting an Agent Run

Run the following from the **root of the target repo** (`cd` to the correct directory first). In the standard flow, this is the scaffolded trial repository created by `init-trial.ps1`.

### OpenAI Codex

```powershell
codex exec -m gpt-5.4 --dangerously-bypass-approvals-and-sandbox "Read .agents/skills/agent-loop.md and follow it precisely."
```

| Flag | Purpose |
|------|---------|
| `-m gpt-5.4` | Model selection — substitute the current best available model |
| `--dangerously-bypass-approvals-and-sandbox` | Allows the agent to run shell commands and write files without per-action approval. Required for autonomous execution. |

Recommended headless prompt:

```text
Read .agents/skills/agent-loop.md and follow it precisely.
```

This points the model at the deployed runtime skill inside the target repo. The skill then drives the rest of the context intake from `docs/state/`, `docs/planning.md`, `docs/agent-loop/standards.md`, and any supplementary skills.

> **After the run:** always check `git status`. If the agent reports skipping the commit (citing "higher-priority repo instructions"), commit manually: `git add . && git commit -m "<semantic message>"`.

### Gemini CLI

```powershell
gemini -m gemini-2.5-pro-preview --prompt "Read .agents/skills/agent-loop.md and follow it precisely." --approval-mode yolo
```

Equivalent short-form command:

```powershell
gemini -m gemini-2.5-pro-preview -p "Read .agents/skills/agent-loop.md and follow it precisely." -y
```

Per the CLI help, `--prompt` selects non-interactive headless mode and `--approval-mode yolo` auto-approves all tool calls including shell commands, making Phase 6 commits fully autonomous.

Recommended headless prompt:

```text
Read .agents/skills/agent-loop.md and follow it precisely.
```

> **If shell execution is still blocked** (error: `"Tool execution for 'Shell' requires user confirmation, which is not supported in non-interactive mode"`), this is a known intermittent bug in some Gemini CLI versions (observed in 0.37.0) rather than a fundamental limitation. Possible causes and workarounds:
> - **CI environment variables:** Unset any `CI_*` environment variables before running — the CLI's UI framework detects these and may downgrade to a restricted non-interactive mode that overrides `--yolo`.
> - **Version update:** `npm update -g @google/gemini-cli` — the bug may be fixed in a later release.
> - **Manual fallback:** If the bug persists, check `docs/state/handover.md` for the agent's intended commit message and commit manually: `git add . && git commit -m "<message from handover>"`

### Choosing Between Providers

| | Codex (`gpt-5.4`) | Gemini CLI |
|---|---|---|
| Phase 6 commits | ✅ Works | ✅ Intended to work (bug in some versions — see above) |
| File read/write | ✅ | ✅ |
| Sandbox isolation | ✅ via `--dangerously-bypass-approvals-and-sandbox` | Partial |
| Best for | Full autonomous runs | Fast iteration; verify commit landed after each run |

> **After any run (either provider):** always check `git status` before starting the next loop. An uncommitted state means the next agent wakes to modified but untracked work, which can cause confusing diffs.



---

## Known Environment Gotchas


Capture environment-specific failures here once they have repeated often enough to deserve standing operator guidance.

### PowerShell 5.1 UTF-8 BOM Corrupts Seed CSV Headers

PowerShell 5.1 writes a UTF-8 byte order mark when using `Set-Content` and many `Out-File` flows, which can silently corrupt the first CSV column header during fixture or seed generation. The downstream symptom is usually a parser that appears to read the file successfully but exposes an unexpected first header value with hidden BOM bytes attached.

Use one of these safe patterns when generating seed files:

- Prefer `Out-File -Encoding utf8NoBOM` when writing UTF-8 CSV content from PowerShell.
- If a file was already produced with a BOM, strip it with Node before seeding so the first header matches the expected schema exactly.

Treat BOM-safe file output as mandatory whenever the workflow depends on exact column-header matching.

### Monolithic Seeder Transactions Exhaust the Node Heap

Large seed scripts can fail non-deterministically when they try to push every insert or upsert into a single `prisma.$transaction([...operations])` call. In practice, once the operation list grows beyond roughly 5,000 rows, Node can exhaust the heap while Prisma materializes the transaction payload, causing the seeder to crash before the database becomes the bottleneck.

Use these patterns instead:

- Batch large seed workloads into smaller transaction groups rather than constructing one giant `prisma.$transaction` array.
- Commit each batch before moving to the next so memory use stays bounded and partial progress is easier to inspect.
- Treat batch sizing as a first-class seeder parameter whenever fixture volume can grow over time.

Do not rely on a single all-rows transaction for bulk seeders; bounded batches are the safe default.

---

## Periodic Standards Review

After 3–5 trial projects, review `docs/agent-loop/standards.md` against the accumulated `backlog-archive.md` files across trials. If a new class of debt is appearing repeatedly, codify it as a new standing rule.

---

## Milestone Commits

At the end of a natural milestone (e.g. all UI polish items done, design system complete), tag the repo:
```
git tag -a v0.x.0 -m "Milestone: <short description>"
```
This gives a clean rollback point and makes the git log readable as a project narrative.

---

## Rollback After a Bad Agent Run

If an agent run produces incorrect code, corrupts state files, or moves the backlog in the wrong direction, recover the repo before starting the next loop. Pick the rollback method based on whether you need to preserve published history.

### Use `git revert` When History Must Stay Intact

Use `git revert` when the bad agent commit has already been pushed, shared with others, or is part of history you want to preserve as an auditable trail.

1. Identify the bad commit:
   ```
   git log --oneline -n 10
   ```
2. Revert it with a new commit:
   ```
   git revert <bad-commit>
   ```
3. If the bad run spans multiple consecutive commits, revert the range from newest to oldest, or revert the contiguous range in one pass:
   ```
   git revert --no-commit <oldest-bad-commit>^..<newest-bad-commit>
   git commit -m "revert: undo bad agent run"
   ```

**Why:** `git revert` preserves the full narrative of what happened while cleanly undoing the agent's output.

### Use `git reset --hard` When Discarding Local History Is Safe

Use `git reset --hard` only when the bad agent commit is still local, no one else depends on it, and you want to erase it completely rather than record a compensating commit.

1. Confirm the last known good commit:
   ```
   git log --oneline -n 10
   ```
2. Reset the branch back to that commit:
   ```
   git reset --hard <good-commit>
   ```

For a simple "undo the latest agent run" case where the most recent commit is bad, this is usually:
```
git reset --hard HEAD~1
```

**Why:** this is the fastest recovery path, but it destroys local commit history, so it is only appropriate for unpublished work.

### Restore `handover.md` Before Restarting the Loop

The next run should inherit the last good context, not the bad run's summary.

- If you used `git reset --hard` to move back to the last good commit, `docs/state/handover.md` is restored automatically with the rest of the tree.
- If you used `git revert`, verify that `docs/state/handover.md` now reflects the restored context. If the revert leaves the handover semantically stale, rewrite it so the next run starts from the correct task.
- If you need to recover only the handover from a known-good commit while keeping other current files, restore that single file first:
  ```
  git checkout <good-commit> -- docs/state/handover.md
  ```
  Then edit the file so `## Current Status` and `## Primary Immediate Next Step` accurately describe the recovered state before committing.

### Re-Establish the Baseline Before the Next Run

- If the bad run touched application code, tests, build scripts, dependencies, or generated artifacts, rerun the project's normal baseline checks before starting another agent loop.
- In Node-based repos that follow the current harness pattern, prefer:
  ```
  npm test -- --runInBand
  ```
- If the bad run changed only documentation or state markdown, rerunning tests is optional, but still recommended when there is any doubt about collateral edits.
- Do not resume the loop until the repo is both clean (`git status`) and the relevant baseline checks are green.

### Recommended Recovery Sequence

1. Stop the loop and inspect recent commits.
2. Choose `git revert` for shared history or `git reset --hard` for safe local discard.
3. Restore `docs/state/handover.md` to the last good context.
4. Rerun the baseline checks appropriate to the files that changed.
5. Confirm `git status` is clean.
6. Restart the agent loop.
