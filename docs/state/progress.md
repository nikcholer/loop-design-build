# Feature Progress Log

## Self-Improvement Sprint 1

- Completed the first Critical Fixes task in `init-trial.ps1`: new trial scaffolds now create `docs/agent-loop/` and copy `docs/agent-loop/standards.md` before the initial git commit.
- Validated the change by running `init-trial.ps1 -TrialName Trial-LoopValidation`, confirming the scaffolded repo contains `docs/agent-loop/standards.md`, then deleting the throwaway repo.
- Completed the second Critical Fixes task in `init-trial.ps1`: new trial scaffolds now also copy `docs/agent-loop/outer-loop-playbook.md` into `docs/agent-loop/` before the initial git commit.
- Validated the change with a red/green dry-run: first confirmed the scaffold omitted `docs/agent-loop/outer-loop-playbook.md`, then reran the scaffold after the patch and confirmed the file exists, deleting both throwaway repos afterward.
- Completed the third Critical Fixes task in `init-trial.ps1`: new trial scaffolds now seed `docs/planning.md` with a structured template containing `## Domain Overview`, `## Data Sources / Requirements`, `## Technical Constraints`, `## Preferred Stack`, and `## Out of Scope`.
- Validated the planning template with a red/green scaffold smoke test: first confirmed the previous scaffold produced only a one-line stub, then reran `init-trial.ps1 -TrialName Trial-Green-PlanningTemplate` and verified all required headings exist before deleting the throwaway repo.
