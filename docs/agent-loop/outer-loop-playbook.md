# Outer Loop Playbook

The **outer loop** is everything that happens *between* individual agent runs: the human product owner, the orchestration chat, and any tooling that kicks off the next `codex exec`. This document records the recurring responsibilities of the outer loop operator.

---

## Backlog Archival

**Trigger:** The agent flags `## Backlog Size Warning` in `handover.md`, or the active `backlog.md` exceeds ~80 lines.

**Why the agent doesn't do this itself:** The agent is scoped to a single atomic task. Rewriting its own state files is a meta-operation that risks silently discarding context. The human orchestrator has full visibility of what is truly "done and safe to archive."

**Procedure:**

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

---

## Steering the Next Sprint

At any point between runs, the human orchestrator may:

- **Inject new backlog items** directly into `backlog.md` under a new section labelled `(Added by Human)` — the agent will pick these up on the next boot.
- **Redirect the next run** by editing the `## Primary Immediate Next Step` in `handover.md`.
- **Add design or standards guidance** by editing `docs/agent-loop/standards.md` — changes take effect on the next agent boot.
- **Write a TBD response** by creating `docs/state/tbd-response.md` if the agent has paused for human input.

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
