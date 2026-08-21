# Installing Crew for Codex

Crew uses the native and local transports selected by its worker definitions.
The same `skills/crew/` directory also serves Claude Code.

## Requirements

- A current Codex release with subagent support.
- Git with worktree support.
- Claude Code CLI on `PATH` for frontend work.
- A Claude Code login that passes `claude auth status` for frontend work.

The [frontend worker definition](../skills/crew/workers/frontend.md) is the
source for the exact frontend command and failure behavior.

## Installation

1. Clone Crew:

   ```bash
   git clone https://github.com/divyekant/crew.git ~/.codex/crew
   ```

2. Symlink the shared skill into Codex discovery:

   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/crew/skills/crew ~/.agents/skills/crew
   ```

3. Restart Codex so it reloads the skill.

## Behavior

Crew checks only the worker domains that a task needs. It uses the exact route
in each worker definition. If a required worker is unavailable, Crew blocks
that domain instead of silently substituting another model.

For work that uses an external bridge, the Codex controller writes a complete
brief to a file and runs the exact command in the relevant worker definition.
The controller then reviews the diff and runs validation.
