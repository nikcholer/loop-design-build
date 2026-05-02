# Visual Demo: The "Stop Rather Than Guess" Mechanic

One of the most critical features of the Agentic Loop Harness is its ability to prevent hallucinated progress when requirements are ambiguous.

## The Agent Loop in Action

When an agent is invoked within this harness, it follows a strict Phase-based lifecycle (defined in `skill.md`). If it encounters a conflict or missing design decision—for example, if a task requires data storage but the technology stack hasn't been chosen—the agent will not assume a path forward.

Instead, it triggers the **TBD Logic**:

### 1. Blocker Detected
The agent immediately halts all file modifications and creates a new document: `docs/state/tbd.md`.

![Terminal Mockup: Ambiguity Detection](/c:/data/loop-design-build/docs/assets/terminal_tbd_pause.png)

### 2. The TBD Report (Real World Example)
The following is an actual `tbd.md` from the [Sample-NYCTraffic-Refresh](https://github.com/nikcholer/Sample-NYCTraffic-Refresh) case study:

```markdown
# TBD: Human Input Required

**Date Context Generated:** 2026-04-09
**Agent Encountered Blocker:** Undefined Database/ORM Technology

## The Ambiguity / Blocker
I am assigned to the task "Define the Database Schema for collision storage." However, package.json does not include any DB dependencies and docs/planning.md does not specify the tech stack.

## Potential Options for the Human
1. **Option A:** Use SQLite with Prisma (I will install Prisma and configure a local DB).
2. **Option B:** Use SQLite with better-sqlite3 (raw SQL/lightweight).
3. **Option C:** Use PostgreSQL with Prisma (requires external setup).
```

### 3. Human Resolution
The human operator provides a `tbd-response.md`. The harness ensures that the next agent run *consumes this response first*, updates the permanent documentation (`planning.md`), and only then resumes work.

See the [Detailed Case Study: Database Strategy](./case-study-database.md) for the full resolution.

---

## 2. Phase 1 Safety: The Dirty Worktree Blocker
A core strength of the harness is **Pre-Flight Locality Checks**. If the repository was already "dirty" (contained uncommitted changes) at run start, and those changes are ambiguous, the agent will refuse to proceed.

### The Blocker in Action
In the NYC project, the agent detected uncommitted Node 22+ engine updates and a lockfile rewrite that weren't part of the current sprint. To protect the audit trail, it stopped.

![Terminal Mockup: Safety Check Abort](/c:/data/loop-design-build/docs/assets/terminal_git_dirty_safety.png)

Read more in the [Detailed Case Study: Safety Audit](./case-study-safety.md).

---

## 3. Phase 5 Success: The Handover
The loop ends when the agent serializes its state for the next run (or the human operator). Even when the project is "complete," the agent provides a structured exit.

### The Success State
The following is the **Handover** from the final run of the NYC project:

```markdown
# Handover Document

**Last Agent Exited At:** 2026-04-14 10:20:43 UTC

## Primary Immediate Next Step
- No active High or Medium backlog items remain.
- The project milestone is complete.

## Active Context
- **Current Epic/Goal:** All human-added backlog items are complete.
- **Last File Modified:** README.md
- **Current Status:** The "Powered by OpenCode" footnote has been integrated. Project logic is stable.
```

By standardizing the **Exit State**, the harness eliminates the "What did the AI actually finish?" guesswork at the end of a sprint.

---

## Why This Matters
As a portfolio piece, this demonstrates an understanding of the **Real-World Risks** of AI agents:
- **Cost Control**: Prevents recursive loops that drain token budgets.
- **Safety**: Ensures no code is written based on false assumptions.
- **Auditability**: Leaves a permanent record of every human-in-the-loop decision in the Git history.
