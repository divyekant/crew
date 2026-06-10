# crew

Multi-model build orchestrator skill. The session model (Fable) is the
controller and mastermind; implementation is dispatched to model-matched
workers and every diff is reviewed before it reaches the user.

| Worker | Domain |
|---|---|
| Opus | Frontend — components, styling, UX, accessibility |
| GPT‑5.5 (via Codex CLI) | Backend — APIs, services, DB, auth, business logic |
| Sonnet | Mechanical — tests, renames, codemods, boilerplate |

## How it works

- **Claude Code** (orchestrator host): crew decomposes the task, writes
  self-contained briefs, dispatches workers in parallel (worktree isolation
  when they share a repo), reviews every diff, runs tests, integrates, and
  reports with per-worker attribution.
- **Codex CLI / other hosts**: the capability gate at the top of SKILL.md
  makes crew a one-line pass-through — the host executes the build phase
  directly. Same skill file, both hosts, no config divergence.

## Install

```sh
ln -s ~/projects/crew ~/.claude/skills/crew    # Claude Code
ln -s ~/projects/crew ~/.agents/skills/crew    # Codex CLI
```

Requires the [openai-codex Claude Code plugin](https://github.com/openai/codex-plugin-cc)
with `codex login` completed for the backend worker. Without it, backend
work falls back to Opus (flagged in reports).

Conductor integration: `crew` is wired into the build phase of the
`feature` and `complex` pipelines in `skill-conductor/pipelines.yaml`.
The `small-fix` pipeline deliberately excludes it — delegation overhead
isn't worth it below multi-file scope.

## Design

- Spec: `docs/superpowers/specs/2026-06-10-crew-design.md`
- Research behind the routing split and brief protocol: `docs/research/findings.md`
