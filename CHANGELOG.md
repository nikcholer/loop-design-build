# Changelog

## 1.1.1 — 2026-08-13

### Changed

- Outer-loop `run` now presses on only after a real success: provider exit 0, clean worktree, and no unresolved `tbd.md`. A clean exit that leaves uncommitted files is a harness failure and stops the loop. `--max-runs` remains the safety cap.

## 1.1.0 — 2026-08-13

Portfolio and operator refresh. The runtime contract is unchanged: Git-tracked markdown state, one bounded run, stop rather than guess.

### Added

- Working Node CLI at `scripts/cli.js` (`init`, `health`, `run`) so `npx @nikcholer/agentic-loop-harness` actually scaffolds a trial.
- Bounded outer-loop runner (`run`, plus `scripts/run-loop.ps1` and `scripts/run-loop.sh`) that stops on an unresolved `tbd.md`.
- Bash health check (`scripts/check-health.sh`) so Linux/macOS operators are not PowerShell-only.
- Headless examples for Grok Build and Claude Code, with a single shared prompt string.
- `tests/compliance/check.js` and checklist for validating harness packaging and phase numbering.
- Optional `docs/agent-loop/templates/observations.md` for downstream lessons.

### Changed

- README restructured around value prop, 30-second loop, provider table, quick start, and operator tooling.
- `skill.md` now has sequential Phase 1–6 numbering, including **Phase 4: Dealing with Ambiguity**, and explicitly intakes planning/handover/backlog/progress.
- Playbook documents the pre-run health ritual, turn/budget caps, ACP-as-telemetry, and current provider flags.
- Init paths copy `skill.md` into both `.agents/skills/agent-loop.md` and `docs/agent-loop/skill.md`.
- Package keywords expanded beyond Aider/Gemini. Version bumped for a possible republish.

- README mockups re-encoded as JPEG (~97 KB each, down from ~580 KB PNG-named JPEGs).

### Fixed

- `package.json` `bin` pointed at a missing `scripts/cli.js`.
- Visual-demo image paths used a local Windows absolute path that would not resolve on GitHub.
