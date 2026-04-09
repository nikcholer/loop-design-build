# Agent Loop Skill: Headless Iteration

## Overview
This instruction set dictates your behavior when invoked as a headless agent within an iterative loop. Your purpose is to wake up, understand your state entirely from local markdown documents, execute a single discrete unit of work, serialize your state, and exit cleanly.

## Phase 1: Pre-Flight Health Check (State Assessment)
Before writing any code or altering the backlog, you MUST verify the state of unresolved ambiguities in `docs/state/`.
1. Check for the existence of `docs/state/tbd.md`.
2. **If `tbd.md` exists AND `docs/state/tbd-response.md` does not exist**: The human has not resolved your blocker. **ABORT EXECUTION IMMEDIATELY**. Do not make any changes.
3. **If `tbd.md` exists AND `tbd-response.md` exists**: 
   - Read the human's guidance in `tbd-response.md`.
   - **Crucial Step:** Before proceeding, you must update the underlying requirements documents (e.g., `planning.md`, `requirements.md`) to close the loop on this ambiguity so it does not arise again. This ensures the source of truth is always absolute.
   - Archive the files: Move `tbd.md` and `tbd-response.md` to `docs/state/archive/` and prefix both with the current timestamp format: `YYYYMMDDHHMMSS_tbd.md` and `YYYYMMDDHHMMSS_tbd-response.md`.
   - Proceed to Phase 2.

## Phase 2: Context Intake
1. Read `docs/state/handover.md` to understand exactly where the previous run left off.
2. Read `docs/state/backlog.md` to identify your immediate next priority task. If the `handover.md` specifies a mid-flight task, continue it. Otherwise, pop the next item from `backlog.md`.

## Phase 3: Execution & The TDD Loop
1. Execute the work required for the current task.
2. If the task involves code, rely on Test Driven Development. The expected workflow is `Red -> Green -> Refactor`.
3. Stop once a logical boundary is reached (e.g., hitting a blocker, finishing a failing test, or successfully completing a passing implementation).

## Phase 4: Dealing with Ambiguity
If at any point you encounter conflicting constraints, undefined requirements, or systemic ambiguity that needs Human Product Owner input:
1. Stop all current work.
2. Create `docs/state/tbd.md` detailing the problem, context, and potential options for the human to select.
3. Skip Phase 5 and jump immediately to Phase 6 (Commit and Teardown).

## Phase 5: Normal Serialization
If you reached a logical completion point without an unresolved TBD:
1. Update `docs/state/progress.md` with your completions.
2. Modify `docs/state/backlog.md` (check off completed tasks, add new sub-tasks if discovered).
3. Overwrite `docs/state/handover.md`. State explicitly what file was last edited, current status, and what the next agent should do first.

## Phase 6: Commit and Teardown
1. Stage all changes to git (including all document updates).
2. Commit with precise semantic commit messages.
3. Exit gracefully.
