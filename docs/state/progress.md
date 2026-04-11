# Feature Progress Log

## Self-Improvement Sprint 1

- Completed the first Critical Fixes task in `init-trial.ps1`: new trial scaffolds now create `docs/agent-loop/` and copy `docs/agent-loop/standards.md` before the initial git commit.
- Validated the change by running `init-trial.ps1 -TrialName Trial-LoopValidation`, confirming the scaffolded repo contains `docs/agent-loop/standards.md`, then deleting the throwaway repo.
