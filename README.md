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
The harness can be deployed in two ways depending on the maturity of the target codebase:

- **Greenfield (Trial Repository):** Use the `init-trial.ps1` script to dynamically generate a clean sibling repository. This avoids contaminating the harness repo with application code and provides a blank slate for the agent to synthesize the custom backlog and system design from scratch.
- **Existing Codebase (In-Situ Harnessing):** Drop the `docs/state/` architecture and the `docs/planning.md` document directly into the root of an existing repository. This allows the agent to begin work on established code immediately, using the overarching documentation as its primary constraint.

In both cases, once the state architecture is present and the `planning.md` is populated, the project follows the same deterministic loop.

## Directory Structure Overview
- `skill.md` - The master system instruction governing the agent's step-by-step logic.
- `templates/` - Standardized schemas for the markdown-driven state memory `(handover, tbd, etc)`.
- `README.md` - (This document) The macro project architecture overview. 
