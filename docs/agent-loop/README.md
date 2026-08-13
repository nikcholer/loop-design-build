# Agent Loop Deployment Guide

This document is the implementation reference for deploying the harness into a target repository.

For the public overview of the method, see the root [README.md](../../README.md).

## Files To Deploy

Copy these into the target repository:

- `.agents/skills/agent-loop.md`
  Runtime instructions for the agent.
- `docs/agent-loop/outer-loop-playbook.md`
  Human operator instructions between runs.
- `docs/agent-loop/standards.md`
  Project-specific coding and delivery standards. This file is intentionally a placeholder scaffold.
- `docs/agent-loop/templates/`
  Blank planning/state templates to seed the working documents. (Deploys to `docs/templates/`).
- `docs/agent-loop/skill.md`
  Same runtime skill, kept next to the playbook so either path works.

Optional reference material:

- `docs/agent-loop/standards.sample.md`
  A populated example from a TypeScript/Prisma API project. Use it as a pattern, not as a default.
- `scripts/`
  Operator tools: health check, bounded outer-loop runner, backlog archival, and skill injection.
- Node CLI (`npx @nikcholer/agentic-loop-harness`)
  Portable `init`, `health`, and `run` commands. The published package does not include the portfolio images.

## Bootstrap Checklist

1. Copy `docs/agent-loop/skill.md` into `.agents/skills/agent-loop.md` in the target repo. Also keep a copy at `docs/agent-loop/skill.md`.
2. Copy `docs/agent-loop/outer-loop-playbook.md` into `docs/agent-loop/`.
3. Copy `docs/agent-loop/standards.md` into `docs/agent-loop/`.
4. Populate `docs/agent-loop/standards.md` from the target project's house style guide, vendor guidance, community best practices, or your own operating rules.
5. If useful, consult `docs/agent-loop/standards.sample.md` for an example of a fully-populated standards file from a prior trial.
6. Copy the files from `docs/agent-loop/templates/` into `docs/templates/` in the target repo.
7. Create `docs/state/` and `docs/state/archive/`.
8. Seed `docs/planning.md`, `docs/state/handover.md`, `docs/state/backlog.md`, and `docs/state/progress.md` from the newly copied `docs/templates/`.
9. Populate `docs/planning.md` with the project context, supplied artefacts, constraints, current priorities, and out-of-scope items.
10. Review the seeded backlog and handover so the first run begins from intentional context rather than placeholder text.

## Design Principles

- The active state lives in the target repo, not in this harness repo.
- Each run should complete one bounded task, update state, commit, and stop.
- Ambiguity is resolved through `tbd.md` and human response, not by agent improvisation.
- The provider is interchangeable as long as it can read local files, edit the repo, and commit.

## Standards Strategy

Do not treat the placeholder `standards.md` as a universal rulebook. It is a deployment slot.

Good sources for a populated project standards file include:
- your team's house style guide,
- framework or vendor best-practice documents,
- recurring debt patterns discovered in previous runs,
- repo-specific constraints that the agent must not violate.

Keep only standards that should be enforced in the target project. Anything stack-specific belongs in the populated project file or in a clearly-labelled sample, not in the generic scaffold.

## Operator Path

- **PowerShell Core** (`pwsh`) is the richest operator path and works on Windows, macOS, and Linux.
- **bash** is first-class for `init-trial.sh`, `scripts/check-health.sh`, and `scripts/run-loop.sh`.
- **Node 18+** is the portable path: `npx @nikcholer/agentic-loop-harness init|health|run`.

Archival and skill injection remain PowerShell scripts. Run them with `pwsh` on Unix if you need those helpers.
