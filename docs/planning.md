# Target Architecture / Product Requirements

## Project Overview

This is a **meta-improvement project**. The codebase being worked on is `loop-design-build` itself — a provider-agnostic headless agentic coding harness. The goal of this run is to implement improvements to the harness using the same harness methodology.

There is no external dataset. The "requirements" are the improvement backlog in `docs/meta-backlog.md` and the gap analysis derived from running Trial-20260409145641 (a full NYC Motor Vehicle Collisions visualiser built end-to-end using this harness).

## What the Codebase Is

`loop-design-build` is a template harness that:
- Defines a stateless, headless agent execution protocol via `docs/agent-loop/skill.md`
- Supplies state-management templates (`handover.md`, `backlog.md`, `progress.md`, `tbd.md`)
- Initialises clean sibling "trial" repos via `init-trial.ps1`
- Records standing coding standards in `docs/agent-loop/standards.md`
- Documents human orchestrator responsibilities in `docs/agent-loop/outer-loop-playbook.md`

## Tech Stack

- **Language:** PowerShell (scripts), Markdown (documentation)
- **No build step, no compiler, no test runner required** for most tasks
- Where a script needs testing, test it by running it; document the expected output
- Git is available and should be used for all commits as usual

## Working Directory

The agent is operating **directly inside** `loop-design-build`. Do not create sibling trial repos. All changes go into this repository.

## Constraints

- Do not modify `docs/meta-backlog.md` directly — use `docs/state/backlog.md` to track work
- Preserve the existing `docs/agent-loop/` structure; extend it, do not reorganise it
- `init-trial.ps1` is the primary consumer of the harness — any changes must remain compatible with its scaffolding flow
- PowerShell scripts must use `$ErrorActionPreference = "Stop"` and be tested before committing

## Out of Scope

- Actual application code (TypeScript, React, Prisma, etc.) — that belongs in trial repos
- Changes to any Trial-* sibling repos
- Upgrading or locking any npm dependencies
