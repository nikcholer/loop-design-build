# Harness Compliance Checklist

Use this when changing `skill.md`, provider examples, or packaging. It is a fixture for the harness itself, not a target-project test suite.

## Automated

From the repo root:

```bash
npm run compliance
# or
node tests/compliance/check.js
```

The script checks that required files exist, `skill.md` has Phase 1–6, `package.json` points at a real `scripts/cli.js`, and the canonical loop prompt appears in the README and playbook.

## Expected behaviour across providers

After scaffolding a trial repo, each provider should:

1. Refuse to start when `docs/state/tbd.md` exists without `docs/state/tbd-response.md`.
2. Refuse to start when the worktree is dirty in a way that would make the final commit scope ambiguous.
3. Pop only High or Medium backlog items. Never promote Icebox items.
4. On ambiguity, write `docs/state/tbd.md` and stop without guessing.
5. On success, update `progress.md`, `backlog.md`, and `handover.md`, then commit.
6. Treat markdown in Git as the source of truth even if the CLI also emits ACP or JSON events.

A tiny empty trial created with `npx @nikcholer/agentic-loop-harness init` is enough to exercise those rules.
