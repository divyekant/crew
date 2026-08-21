# Frontend Worker

Frontend implementation is always authored by Opus at `high` effort.

## Routing

Every controller writes the complete brief to a file and creates an isolated
Git worktree. From this directory, run:

```bash
../scripts/run-claude-worker.sh <isolated-worktree> <brief-file> opus high
```

The bridge clears environment overrides, pins the Claude Code `opus` alias and
`high` effort, and verifies the effective model in the event stream. It gives
Opus read and edit tools, but no shell. Safe mode prevents nested routing and
agent instructions from re-entering the pipeline.

The controller integrates its diff only after the wrapper exits successfully.
It then runs tests, builds, and screenshots. A fallback or failed run stays in
the isolated worktree.

If the bridge is unavailable, or if authentication, quota, or execution fails,
report `crew: Opus frontend blocked — <reason>.` Do not assign frontend
implementation to Sol, Luna, Sonnet, or the controller without explicit user
approval.

## Owns

Components, styling, layout, user experience states, responsive behavior,
accessibility, animation, visual polish, and user-interface copy placement.

## Does not own

API shapes, server logic, migrations, general test infrastructure, or files
outside its brief.

## Brief additions

- Include the interface contract verbatim when the frontend consumes backend
  data.
- Name the existing component library and design tokens.
- Give target viewports when responsive behavior matters.
- Link one neighboring component that shows project conventions.

## Review focus

- No drift into backend files or contract changes.
- Existing library components are used.
- Loading, empty, error, and success states exist where applicable.
- Accessibility and responsive behavior are complete.
- Comments match the surrounding codebase.

Run screenshot-based validation when a development server is available.
