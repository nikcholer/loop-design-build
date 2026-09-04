# Harness Compliance Checklist

Use this when changing `skill.md`, provider examples, or packaging. It is a fixture for the harness itself, not a target-project test suite.

## Automated

From the repo root:

```bash
npm run compliance
# or
node tests/compliance/check.js
node tests/compliance/run-loop.test.js
```

`check.js` validates packaging, Phase 1–6 numbering, and the canonical loop prompt. `run-loop.test.js` exercises the outer-loop success gate in a temp git repo: press on when clean, halt on TBD, halt on a dirty tree after exit 0, keep the `--provider` prompt as one argument, and fail closed if Git itself cannot inspect the tree.

## Expected behaviour across providers

After scaffolding a trial repo, each provider should:

1. Refuse to start when `docs/state/tbd.md` exists without `docs/state/tbd-response.md`.
2. Refuse to start when the worktree is dirty in a way that would make the final commit scope ambiguous.
3. Pop only High or Medium backlog items. Never promote Icebox items.
4. On ambiguity, write `docs/state/tbd.md` and stop without guessing.
5. On success, update `progress.md`, `backlog.md`, and `handover.md`, then commit.
6. Treat markdown in Git as the source of truth even if the CLI also emits ACP or JSON events.

A tiny empty trial created with `npx @nikcholer/agentic-loop-harness init` is enough to exercise those rules.
