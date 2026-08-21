#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
skill="$repo_root/skills/crew/SKILL.md"
frontend="$repo_root/skills/crew/workers/frontend.md"
backend="$repo_root/skills/crew/workers/backend.md"
mechanical="$repo_root/skills/crew/workers/mechanical.md"

for worker in "$frontend" "$backend" "$mechanical"; do
  [[ -f "$worker" ]]
done

for stale_worker in \
  "$repo_root/skills/crew/workers/opus-frontend.md" \
  "$repo_root/skills/crew/workers/gpt-backend.md" \
  "$repo_root/skills/crew/workers/sonnet-mechanical.md"; do
  [[ ! -e "$stale_worker" ]]
done

grep -F '[workers/frontend.md](workers/frontend.md)' "$skill"
grep -F '[workers/backend.md](workers/backend.md)' "$skill"
grep -F '[workers/mechanical.md](workers/mechanical.md)' "$skill"
grep -F 'Never substitute another' "$skill"
grep -F 'Every external bridge writer uses an isolated worktree.' "$skill"

grep -F 'Frontend implementation is always authored by Opus at `high` effort.' "$frontend"
grep -F 'Every controller' "$frontend"
grep -F 'run-claude-worker.sh <isolated-worktree> <brief-file> opus high' "$frontend"
grep -F 'integrates its diff only after the wrapper exits successfully' "$frontend"

grep -F 'GPT-5.6 Sol with `high` reasoning on every host' "$backend"
grep -F 'model: "gpt-5.6-sol"' "$backend"
grep -F -- '--model gpt-5.6-sol --effort high' "$backend"

grep -F 'Sonnet under a Claude Code controller' "$mechanical"
grep -F 'GPT-5.6 Luna with `max` reasoning under a Codex controller' "$mechanical"
grep -F 'run-claude-worker.sh <isolated-worktree> <brief-file> sonnet high' "$mechanical"
grep -F 'integrates the diff only after the wrapper exits successfully' "$mechanical"
grep -F 'model: "gpt-5.6-luna"' "$mechanical"
grep -F 'reasoning_effort: "max"' "$mechanical"

if rg -n 'GPT-?5\.5|gpt-5\.5' "$repo_root/skills/crew"; then
  printf '%s\n' 'FAIL: active Crew skill still names GPT-5.5.' >&2
  exit 1
fi

printf '%s\n' 'PASS: Crew routing contract is current and fail closed.'
