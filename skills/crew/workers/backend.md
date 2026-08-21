# Backend Worker

Backend implementation uses GPT-5.6 Sol with `high` reasoning on every host.

## Routing

| Controller capability | Dispatch |
|---|---|
| Native Codex subagents | Spawn a clean-context worker with `model: "gpt-5.6-sol"` and `reasoning_effort: "high"`. Put the complete brief in the task. |
| Claude Code with the Codex plugin | Invoke `codex:codex-rescue` once. Include `--model gpt-5.6-sol --effort high` as runtime controls with the complete brief. Default to write-capable execution. |

Do not set the forwarding Claude model and mistake it for the Codex runtime
model. Verify that both the Sol model and `high` effort reach the worker.

If neither transport works, or if the Codex run fails, report
`crew: Sol backend blocked — <reason>.` Do not fall back to Opus or another
model without explicit user approval.

## Owns

APIs, services, business logic, database schema and migrations,
authentication, queues, background jobs, third-party integrations, and
structured data transformations.

## Does not own

Frontend components, styling, broad mechanical sweeps, the interface contract,
or files outside its brief.

## Brief additions

- Include the interface contract verbatim.
- Require reversible migrations that follow project naming conventions.
- State boundary errors, status codes, and error shapes.
- Give the exact validation commands.

## Review focus

- Run tests and builds independently.
- Check error handling at every changed boundary.
- Check exact contract fields, status codes, and errors.
- Reject silent scope expansion.
- Check migration safety and rollback behavior.
