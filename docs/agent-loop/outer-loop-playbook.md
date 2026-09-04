# Outer Loop Playbook

The **outer loop** is everything that happens between individual agent runs: the human product owner, the orchestration chat, and any tooling that kicks off the next CLI invocation. This document records the recurring responsibilities of the outer-loop operator.

> **Note for agents:** This document describes duties performed by the human orchestrator between runs. It does not modify or supersede any phase in `skill.md`.

---

## First-Time Bootstrap

If you are starting from a new project idea, scaffold a trial repo and work there:

```bash
npx @nikcholer/agentic-loop-harness init
# or, from a clone:
pwsh -File ./init-trial.ps1          # Windows / PowerShell Core (recommended)
./init-trial.sh                      # Linux / macOS
```

PowerShell Core (`pwsh`) is the richest operator path and works on Windows, macOS, and Linux. The bash `init-trial.sh` plus `scripts/check-health.sh` and `scripts/run-loop.sh` cover the same first-run path without PowerShell. The Node CLI (`init`, `health`, `run`) is the portable option when you already have Node.

If you are taking over an existing repository, prefer adopting the harness in place. Do not copy the target codebase into a wrapper folder unless you know the project is location-independent and want an isolated clone.

For an existing repo, bootstrap it like this before the first run:
1. Copy `docs/agent-loop/skill.md` from this harness repo into `.agents/skills/agent-loop.md` in the target repo.
2. Copy `docs/agent-loop/outer-loop-playbook.md` into `docs/agent-loop/` in the target repo.
3. Copy `docs/agent-loop/standards.md` into `docs/agent-loop/` in the target repo.
4. Populate `docs/agent-loop/standards.md` with the target project's actual standards.
5. If useful, consult `docs/agent-loop/standards.sample.md` as a reference example rather than as a default.
6. Copy the files from `docs/agent-loop/templates/` into the target repo.
7. Create `docs/state/` and `docs/state/archive/`.
8. Seed `docs/state/handover.md`, `docs/state/backlog.md`, and `docs/state/progress.md` from the matching templates.
9. Create `docs/planning.md` from the planning template and fill it with the current architecture, supplied artefacts, constraints, current known priorities, and out-of-scope items.
10. Review the seeded backlog and handover files so the first run starts from intentional context rather than generic placeholders.

If `docs/` or `.agents/` already exists in the target repo, merge these files into the existing structure rather than renaming project folders or moving the codebase.

---

## State Archival

**Trigger:** The agent flags `## Backlog Size Warning` in `handover.md`, or the active `backlog.md` exceeds roughly 80 lines.

**Why the agent does not do this itself:** The agent is scoped to a single atomic task. Rewriting its own state files is a meta-operation that risks silently discarding context. The human orchestrator has better visibility of what is truly done and safe to archive.

### Backlog Procedure

1. Open `docs/state/backlog.md`.
2. Identify all fully-completed sections. These are sections where every item, including all sub-items, is marked `[x]`. Partially-completed sections stay in the active backlog.
3. Create or append to `docs/state/backlog-archive.md`. Prepend each archived section with a datestamp:
   ```markdown
   ## [Archived: YYYY-MM-DD] High Priority Queue
   ...
   ```
4. Delete the archived sections from `backlog.md`, keeping only the active or incomplete sections.
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
   ## [Archived: YYYY-MM-DD] Current Sprint / Milestone
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

- inject new backlog items directly into `backlog.md` under a new section labelled `(Added by Human)`,
- redirect the next run by editing `## Primary Immediate Next Step` in `handover.md`,
- add standards or design guidance by editing `docs/agent-loop/standards.md`,
- write a TBD response by creating `docs/state/tbd-response.md` if the agent has paused for human input.

---

## Pre-Run Ritual

Before every loop, prefer a clean tree and a passing health check:

```bash
git status

npx @nikcholer/agentic-loop-harness health
# or:
pwsh -File scripts/check-health.ps1
# bash scripts/check-health.sh
```

Pass a project verification command when you have one:

```powershell
pwsh -File scripts/check-health.ps1 -VerificationCommand npm,test
```

Do not start a run while `docs/state/tbd.md` exists without `docs/state/tbd-response.md`.

## Starting an Agent Run

Run the following from the root of the target repo. Keep this prompt string identical across providers:

```text
Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state.
```

The scaffold installs that file at `.agents/skills/agent-loop.md` and also keeps a copy at `docs/agent-loop/skill.md`. Prefer the `.agents/skills/` path in commands so skill discovery and the prompt agree.

Prefer a turn or budget cap when the provider offers one (`--max-turns 15` is a good default). The harness already bounds work to one backlog item; the cap is a safety net against a runaway tool loop.

### Grok Build

```powershell
grok -p "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state." --always-approve --max-turns 15
```

`--always-approve` is the product name for unattended tool approval (`--yolo` is an alias). Use it only in a trusted local repo. JSON / ACP event streams from `--output-format json` or `grok agent` are telemetry; they do not replace `docs/state/*.md`.

### Claude Code

```powershell
claude -p "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state." --dangerously-skip-permissions --max-turns 15
```

`--print` / `-p` is required for a non-interactive run. Omit `--max-turns` only if your installed Claude Code build does not advertise the flag.

### OpenAI Codex

```powershell
codex exec --dangerously-bypass-approvals-and-sandbox "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state."
```

Add `-m <model>` when you want to pin a specific Codex model.

### Gemini CLI

```powershell
gemini -m gemini-2.5-pro --approval-mode yolo -p "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state."
```

Equivalent short form:

```powershell
gemini -m gemini-2.5-pro -y -p "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state."
```

Substitute the current Gemini model id if `gemini-2.5-pro` is no longer the right default on your CLI.

### Aider

To run Aider non-interactively (`--yes` to auto-approve edits and commits, `-m` to execute a single prompt and exit), use the following syntax:

```powershell
aider -m "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state." --yes --no-gitignore --model <provider>/<model>
```

`--no-gitignore` keeps Aider from rewriting project ignore rules mid-run. To keep Aider metadata out of the repo, add `--map-tokens 0` and/or point history files outside the tree with `--input-history-file`, `--chat-history-file`, and `--llm-history-file`. The harness scaffold already ignores `.aider*`.

> **Note on Custom Endpoints:** For custom API routes (e.g., Together.ai, OpenRouter), it is strongly recommended to configure your endpoint strictly within a localized `.aider.conf.yml` file rather than mutating your shell environment. If you do override `OPENAI_API_BASE` and `OPENAI_API_KEY` in your terminal, ensure you unset both immediately afterward (`Remove-Item Env:\OPENAI_API_BASE, Env:\OPENAI_API_KEY`). Leaving them exported will silently hijack OpenAI traffic when using other CLI tools. Use `--no-show-model-warnings` to suppress browser pop-ups for unrecognized models.

### OpenCode

If you prefer a Node.js-based agent framework, configure your credentials interactively (`opencode auth login`), set your default model, and execute purely headlessly:

```powershell
opencode run --dangerously-skip-permissions --log-level WARN "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state."
```

Pin a model with `-m "<provider>/<model_name>"`. See https://api.together.ai/models for OpenAI-compatible hosted models.

Sample Together AI model strings: `moonshotai/Kimi-K2.6`, `zai-org/GLM-5.1`. Prefix them with `togetherai/` for OpenCode:

```powershell
opencode run -m "togetherai/zai-org/GLM-5.1" --dangerously-skip-permissions --log-level WARN "Read .agents/skills/agent-loop.md and execute the next run strictly from the repository's local markdown state."
```

Use `opencode run`, not `opencode .`, for non-interactive execution. `--log-level WARN` keeps message-delta noise out of the terminal.

## Bounded Outer Loop

The inner loop is still one backlog item. The outer loop removes you as a re-run button: if the previous run actually succeeded, it starts the next one.

```bash
npx @nikcholer/agentic-loop-harness run --provider grok --max-runs 15
# or, from a clone:
pwsh -File scripts/run-loop.ps1 -Provider grok -MaxRuns 15
# bash scripts/run-loop.sh --provider grok --max-runs 15
```

A run counts as success only when **all** of these hold:

1. the provider exited 0,
2. there is no unresolved `docs/state/tbd.md`,
3. the worktree is clean (`git status --porcelain` empty), meaning Phase 6 committed — or there was honestly nothing to commit.

The runner then health-checks and starts the next inner loop. `--max-runs` is a safety cap, not a target.

It **halts** when:

- the agent publishes an unresolved `tbd.md` (ambiguity, dirty-tree judgment, or backlog exhausted),
- the provider exits non-zero,
- the provider exits 0 but leaves uncommitted files (a harness failure: do not start the next item),
- or the cap is reached.

It does not resolve blockers and does not promote Icebox items. Pass `--wait-for-response` only for attended demos where you will drop `tbd-response.md` while the runner is parked. Default for real use is: press on through greens, stop and wait for you when it is not green.

## ACP and Structured Output

Several CLIs can emit ACP, JSON, or `stream-json` event streams. Those streams are useful for dashboards and spend tracking. They are not the harness source of truth.

The record of a run is still:

- the Git-tracked markdown in `docs/state/` and `docs/planning.md`,
- the commit produced at the end of a successful run,
- and `docs/state/tbd.md` when the agent must stop.

### Operating Rule

Use whichever provider is appropriate for the next run. The provider choice is not part of the harness state model. The important invariant is that the next agent reads the same local markdown context and performs the next bounded task.

After any run the outer-loop runner already checks `git status` and will not start the next item unless the tree is clean. If you are invoking the provider by hand instead of `run`:
- check `git status`,
- confirm the state files reflect the completed work,
- verify that the commit actually landed before starting the next loop.

If a provider fails to commit automatically, treat that as a failed run. Commit manually only after you have reviewed the leftover files; do not let the outer loop press on past them.

If an agent claims it left a successful run uncommitted due only to a generic "higher-priority CLI instruction," treat that as a harness-execution failure rather than a valid outcome. The runtime skill requires a commit unless the run stopped behind an unresolved `tbd.md` or an explicitly escalated dirty-worktree ambiguity.

### Dirty Worktree Rule

Before starting a run, prefer a clean working tree.

If you intentionally leave uncommitted changes for the next run, keep them narrow and obviously related to the next task. Examples include backlog steering, handover edits, or other operator-authored state updates.

The runtime skill now requires the agent to make that judgment at the **start** of the run, not at the end. If the worktree is not clean enough for the agent to be confident it can commit the run cleanly, it should stop immediately and publish the concern in `docs/state/tbd.md`.

Operationally, that means:
- prefer starting every run from a clean `git status`,
- if you must leave uncommitted operator edits behind, keep them limited to obvious state/planning guidance,
- if the repo is dirty in any way that would make the final commit scope debatable, expect the agent to abort early via `tbd.md`.

---

## Project-Specific Gotchas

Capture environment-specific failures in the target repo once they have repeated often enough to deserve standing operator guidance.

Examples:
- shell or encoding quirks,
- provider-specific tool approval behaviour,
- fragile generated files,
- slow or flaky verification commands,
- rollback cautions for sensitive migrations or stateful systems.

Avoid turning this harness repo into a catalogue of one stack's historical edge cases. Keep target-project gotchas with the target project.

---

## Periodic Standards Review

After several trial projects, review the populated `docs/agent-loop/standards.md` files and archived backlog patterns across those repos. If a new class of debt appears repeatedly, codify it into your house standards or use it to seed future project-specific standards files.

---

## Milestone Commits

At the end of a natural milestone, tag the repo:
```
git tag -a v0.x.0 -m "Milestone: <short description>"
```

This gives a clean rollback point and makes the git log readable as a project narrative.

---

## Rollback After a Bad Agent Run

If an agent run produces incorrect code, corrupts state files, or moves the backlog in the wrong direction, recover the repo before starting the next loop.

### Use `git revert` When History Must Stay Intact

Use `git revert` when the bad agent commit has already been pushed, shared, or is part of history you want to preserve as an auditable trail.

1. Identify the bad commit:
   ```
   git log --oneline -n 10
   ```
2. Revert it with a new commit:
   ```
   git revert <bad-commit>
   ```
3. If the bad run spans multiple consecutive commits, revert the range in one pass:
   ```
   git revert --no-commit <oldest-bad-commit>^..<newest-bad-commit>
   git commit -m "revert: undo bad agent run"
   ```

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

### Restore `handover.md` Before Restarting the Loop

The next run should inherit the last good context, not the bad run's summary.

- If you used `git reset --hard`, `docs/state/handover.md` is restored automatically with the rest of the tree.
- If you used `git revert`, verify that `docs/state/handover.md` now reflects the restored context. If it is semantically stale, rewrite it before continuing.
- If needed, restore only the handover from a known-good commit:
  ```
  git checkout <good-commit> -- docs/state/handover.md
  ```

### Re-Establish the Baseline Before the Next Run

- Rerun the target repo's normal verification command or commands before starting another loop.
- If the bad run touched only markdown state, rerunning all checks may be optional, but still recommended when there is any doubt.
- Do not resume the loop until the repo is both clean in `git status` and the relevant baseline checks are green.
