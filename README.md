# Agentic Loop Harness

This repository is a publishable harness for running a single bounded CLI-agent task at a time under human oversight.

It is designed to be copied into a target repository so an agent can:
- read its working context from local markdown files,
- complete one discrete backlog item using a TDD-first workflow when code is involved,
- write a handover for the next run,
- stop rather than guess when requirements are ambiguous.

The aim is not to build a fully autonomous multi-agent framework. The aim is to make repeated, context-clear agent runs auditable, reviewable, and portable across providers such as Codex CLI, Gemini CLI, or similar tools.

## What This Repo Contains

- `docs/agent-loop/skill.md`
  The runtime instruction the agent reads inside the target repo.
- `docs/agent-loop/outer-loop-playbook.md`
  The human operator guide for starting runs, handling blockers, archiving state, and steering the next sprint.
- `docs/agent-loop/standards.md`
  A neutral placeholder file to populate with project-specific standards before or during a trial.
- `docs/agent-loop/standards.sample.md`
  An example populated standards file from a TypeScript/Prisma-style project. It is reference material, not the default scaffold.
- `docs/agent-loop/templates/`
  Blank markdown templates for planning, backlog, progress, handover, and TBD files.
- `init-trial.ps1`
  Creates a sibling trial repo with the harness files and empty active state scaffolded.
- `scripts/`
  Optional operator helpers for skill injection, backlog archival, and lightweight health checks.

## Core Model

### 1. Local Markdown State

The target repo carries its own working state in markdown:
- `docs/planning.md`
- `docs/state/backlog.md`
- `docs/state/progress.md`
- `docs/state/handover.md`
- `docs/state/tbd.md` and `tbd-response.md` when escalation is required

That keeps each agent run short-lived and restartable. The next run reads the repo, not an opaque chat transcript.

### 2. One Task Per Run

Each invocation is expected to complete one bounded unit of work, update the state files, commit, and stop.

This keeps the git history readable and makes the development narrative inspectable by another human or another model.

### 3. Human Oversight, Not Agent Guessing

If the agent hits ambiguity, conflicting requirements, or an exhausted active backlog, it writes `tbd.md` and stops.

That is a deliberate control point. The human operator resolves the ambiguity in writing, updates the source documents, and only then starts the next run.

### 4. Provider-Agnostic Execution

The harness is intentionally orchestration-light. The provider is an implementation detail of the next run, not part of the state model.

If the target repo is prepared correctly, different CLI agents should be able to pick up the same backlog and handover files and continue from the same local ground truth.

## How To Use It

### Option A: Create a New Trial Repo

Run:

```powershell
.\init-trial.ps1
```

That scaffolds a sibling repo with:
- the runtime skill in `.agents/skills/agent-loop.md`,
- the operator docs in `docs/agent-loop/`,
- empty planning/state files ready to populate.

### Option B: Adopt It In An Existing Repo

Copy the harness files into the target repository in place rather than wrapping the repo in another folder:

1. Copy `docs/agent-loop/skill.md` to `.agents/skills/agent-loop.md`.
2. Copy `docs/agent-loop/outer-loop-playbook.md` into `docs/agent-loop/`.
3. Copy `docs/agent-loop/standards.md` into `docs/agent-loop/` and replace its placeholders with the project's actual standards.
4. Optionally consult `docs/agent-loop/standards.sample.md` as an example of a populated standards file.
5. Copy `docs/agent-loop/templates/` into the target repo and seed `docs/planning.md` plus the active `docs/state/` files from those templates.

## Publishing Strategy

This repo is strongest when published alongside at least one companion project that used it.

The harness repo explains the method.
The companion repo demonstrates the method through:
- the evolving `docs/state/` files,
- the `tbd` escalation trail,
- and the git commit history of one-task-per-run delivery.

That pairing makes the concept concrete for recruiters, hiring managers, or collaborators evaluating how you work with agentic loops in practice.

## Next Reading

- Deployment details: [docs/agent-loop/README.md](docs/agent-loop/README.md)
- Human operator workflow: [docs/agent-loop/outer-loop-playbook.md](docs/agent-loop/outer-loop-playbook.md)
