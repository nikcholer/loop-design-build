# Agentic Loop Workflow Architecture

## Project Philosophy
This project is designed to showcase rigorous, structured agentic coding. By stripping away typical UI/UX focus and abstracting orchestration tooling, the goal is to observe and enforce a deterministic, iterative software development lifecycle driven by LLM agents.

We achieve resilient AI workflows not by utilizing continuous, infinitely expanding context windows, but by forcing the agent to serialize its state locally, commit atomically, and explicitly generate its own "shift change" documentation.

## The Pillars of the Workflow

### 1. Constraint-Anchored Development
The architecture relies on an unyielding "external anchor" to prevent agent drift. This can be a medium-complexity relational dataset (for application builds) or overarching architectural documentation and a meta-backlog (for infrastructure builds).

- **Why?** The anchor acts as an objective Product Owner. Whether it's a schema enforcing DTO translation or a playbook enforcing state serialization, the constraints provide a "ground truth" that prevents the agent from hallucinating requirements or architectural shortcuts.

### 2. Deterministic Implementation & Traceability
Development is divided into strict, traceable phases derived directly from the anchor:
1. **Backlog Synthesis:** The agent must fully populate the `backlog.md` from the provided constraints before writing a single line of logic.
2. **Contract-First Design:** Establish the foundational interfaces or standards that govern the solution.
3. **Atomic Verification:** Implement functional units only to satisfy explicitly defined requirements, verified by small, atomic git commits that allow for precise rollbacks.

### 3. Provider-Agnostic Headless Harness
The agent's execution is not tied to a specific orchestration framework (like auto-gpt or langgraph) but is instead designed to be run repeatedly by a simple outer shell or harness. 
- On every boot, the agent reads its entire state from local `.md` documents. 
- It executes exactly one prioritized atomic task.
- It serializes its exit state to the file system.
- It safely shuts down.

### 4. Deterministic State & Ambiguity Resolution (The TBD Pattern)
The backbone of this stateless setup is the `docs/state/` folder. The flow uses rigid templates:
- `handover.md`: A high-density "you are here" map generated for the *next* agent instance.
- `backlog.md` & `progress.md`: For epic management.
- **Escalation (`tbd.md` & `tbd-response.md`)**: Whenever the agent encounters systemic ambiguity, conflicting constraints, or unmapped requirements, it **aborts execution immediately** and drafts a `tbd.md` file requesting human guidance.
  - The outer harness detects this file and suspends automated loops.
  - A human operator responds via `tbd-response.md`.
  - Upon waking and reading the response, the agent **must update the original requirements/planning documents** (to ensure the issue never recurs).
  - Both TBD files are archived into a historical directory using `YYYYMMDDHHMMSS_` prefixes.

### 5. Project Onboarding Strategies
The harness can be used in two ways depending on the maturity of the target codebase:

- **Greenfield (Trial Repository):** Use the `init-trial.ps1` script to generate a clean sibling repository with the required `docs/`, `.agents/skills/`, and state templates already scaffolded.
- **Existing Codebase (In-Situ Harnessing):** Copy the canonical scaffold assets from this repo into the target repository: `docs/agent-loop/templates/`, `docs/agent-loop/skill.md`, `docs/agent-loop/standards.md`, and any helper scripts you want the operator to use. The active `docs/state/` files should live in the target repository, not in this harness repo.

In both cases, the active state lives with the target project being worked on. This repository remains the canonical source for the harness templates and instructions.

### Existing Repo Bootstrap
When adopting the harness into an existing repository, prefer working **in place** rather than copying the target codebase into a new wrapper folder. Many projects have path-sensitive scripts, workspace assumptions, or local tooling that become brittle when moved.

Recommended bootstrap checklist:
1. Copy `docs/agent-loop/skill.md` into `.agents/skills/agent-loop.md` in the target repo.
2. Copy `docs/agent-loop/standards.md` and `docs/agent-loop/outer-loop-playbook.md` into `docs/agent-loop/`.
3. Copy the template files from `docs/agent-loop/templates/` into the target repo.
4. Create `docs/state/` and `docs/state/archive/`.
5. Seed `docs/state/handover.md`, `docs/state/backlog.md`, and `docs/state/progress.md` from the matching templates.
6. Create `docs/planning.md` from the planning template and populate it with the codebase constraints, current architecture, supplied artefacts, and out-of-scope items.
7. Start the first run from the root of the target repo.

If the target repo already has a `docs/` or `.agents/` directory, merge these files into the existing structure rather than relocating the codebase. Only use a copied-wrapper approach when the project is known to be location-independent and you explicitly want an isolated working clone.

## Directory Structure Overview
- `skill.md` - The master system instruction governing the agent's step-by-step logic.
- `templates/` - Standardized schemas for the markdown-driven state memory `(handover, tbd, etc)`.
- `README.md` - (This document) The macro project architecture overview. 
