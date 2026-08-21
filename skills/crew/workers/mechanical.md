# Mechanical Worker

Mechanical implementation uses Sonnet under a Claude Code controller and
GPT-5.6 Luna with `max` reasoning under a Codex controller.

## Routing

For a Claude Code controller, write the complete brief to a file and create
an isolated Git worktree. From this directory, run:

```bash
../scripts/run-claude-worker.sh <isolated-worktree> <brief-file> sonnet high
```

The controller integrates the diff only after the wrapper exits successfully.
The wrapper verifies the effective Sonnet model and contains failed or
substituted work in the isolated worktree.

For a Codex controller, use the first available native route:

| Controller capability | Dispatch |
|---|---|
| Native Codex subagents with `luna_dev` | Spawn `agent_type: "luna_dev"` with a clean context and a complete brief. The role is fixed to Luna `max`. |
| Native Codex subagents without `luna_dev` | Spawn with `model: "gpt-5.6-luna"` and `reasoning_effort: "max"`. |

If the required host route is unavailable, report
`crew: mechanical worker blocked — <reason>.` Do not substitute another model
without explicit user approval.

## Owns

Tests and fixtures, renames, codemods, boilerplate, scaffolding, rote
migrations, documentation updates, lint and format sweeps, dependency chores,
and repetitive edits with a clear pattern.

## Does not own

Design decisions. If a mechanical task needs a behavioral or naming decision,
stop and return the question to the controller.

## Brief additions

- Give one exact before-and-after example.
- List every file when the scope is enumerable.
- For tests, name the behaviors, framework, and one existing test to follow.
- Give the exact validation commands.

## Review focus

- Search for missed instances.
- Check that the pattern was not applied where it does not fit.
- Ensure tests assert behavior instead of implementation details.
- Escalate ambiguity instead of inventing a decision.
