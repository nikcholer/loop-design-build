# Agentic Loop Workflow Architecture

## Project Philosophy
This project is designed to showcase rigorous, structured agentic coding. By stripping away typical UI/UX focus and abstracting orchestration tooling, the goal is to observe and enforce a deterministic, iterative software development lifecycle driven by LLM agents.

We achieve resilient AI workflows not by utilizing continuous, infinitely expanding context windows, but by forcing the agent to serialize its state locally, commit atomically, and explicitly generate its own "shift change" documentation.

## The Pillars of the Workflow

### 1. Data-Driven Requirements
Rather than starting with an abstract greenfield application, the architecture relies heavily on utilizing existing "medium-complexity" relational public datasets (such as the Ergast F1 Dataset, the Olist E-commerce Dataset, or Northwind/Sakila). 

- **Why?** The dataset acts as an unyielding product owner. The schema structure enforces strict architectural boundaries, requires explicit DTO (Data Transfer Object) translation, and provides natural edge cases without the agent hallucinating relationships. 

### 2. Tiered Implementation & Strict TDD
Development occurs in highly structured phases:
1. **Contracts:** Establish the Data Access Layer (DAL) and strictly defined DTO interfaces based on the dataset.
2. **Tests:** Write failing data-generator scripts and unit tests against those contracts.
3. **Logic:** Implement business logic only to satisfy passing tests.
- **Git Discipline:** The agent's adherence to TDD is enforced mathematically via small git commits, ensuring the system can be rolled back to a "green state" at any moment.

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

### 5. The "Clean Slate" Trialling Strategy
To prevent contamination between the meta-architecture design and active application development, this framework relies on bounding executions in separate *trial repositories*.

- Use the `init-trial.ps1` script to dynamically generate a clean sibling repository.
- The script automatically scaffolds the `docs/state/` architecture with **blank, domain-agnostic templates**. 
- The scaffolded `docs/planning.md` now includes a `## Skills` section; after the operator lists optional local skills there, run `scripts/inject-skill.ps1 -TargetRepoPath <trial-repo>` from the harness repo to copy them into the trial's `.agents/skills/` directory.
- The agent wakes up to this "clean slate", parses the raw constraints pasted into the target `planning.md` file by the human product owner, and fully synthesizes the custom backlog and system design before writing any code.

### 6. Self-Improvement Mode
The harness can be used to recursively improve its own tooling, documentation, and playbooks (as demonstrated in this repository's own development). To run the harness on itself:
- Do not use trial scaffolding.
- Drop a populated `docs/state/` architecture directly into the root of `loop-design-build`.
- Write a `docs/planning.md` describing the harness architecture as the target codebase.
- Run the agent execution command (e.g., `codex exec`) directly from the root.

## Directory Structure Overview
- `skill.md` - The master system instruction governing the agent's step-by-step logic.
- `templates/` - Standardized schemas for the markdown-driven state memory `(handover, tbd, etc)`.
- `README.md` - (This document) The macro project architecture overview. 
