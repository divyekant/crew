#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  printf '%s\n' 'usage: run-claude-worker.sh <work-directory> <brief-file> <model> <effort>' >&2
  exit 64
fi

work_dir="$1"
brief_file="$2"
model="$3"
effort="$4"

if [[ ! -d "$work_dir" ]]; then
  printf 'crew: Claude worker blocked — work directory does not exist: %s\n' "$work_dir" >&2
  exit 66
fi

if [[ ! -f "$brief_file" ]]; then
  printf 'crew: Claude worker blocked — brief file does not exist: %s\n' "$brief_file" >&2
  exit 66
fi

work_dir="$(cd "$work_dir" && pwd -P)"
brief_file="$(cd "$(dirname "$brief_file")" && pwd -P)/$(basename "$brief_file")"

if ! git_dir="$(git -C "$work_dir" rev-parse --path-format=absolute --git-dir 2>/dev/null)" ||
   ! common_dir="$(git -C "$work_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" ||
   [[ "$git_dir" == "$common_dir" ]]; then
  printf '%s\n' 'crew: Claude worker blocked — work directory must be an isolated Git worktree.' >&2
  exit 66
fi

if ! command -v claude >/dev/null 2>&1; then
  printf '%s\n' 'crew: Claude worker blocked — Claude Code CLI is unavailable.' >&2
  exit 69
fi

if ! claude auth status >/dev/null 2>&1; then
  printf '%s\n' 'crew: Claude worker blocked — Claude Code authentication is unavailable.' >&2
  exit 69
fi

brief="$(<"$brief_file")"
output_file="$(mktemp "${TMPDIR:-/tmp}/crew-claude-worker.XXXXXX")"

cleanup() {
  status=$?
  trap - EXIT
  rm -f "$output_file"
  exit "$status"
}
trap cleanup EXIT

cd "$work_dir"
set +e
env \
  -u CLAUDE_CODE_EFFORT_LEVEL \
  -u CLAUDE_CODE_SUBAGENT_MODEL \
  -u CLAUDE_CODE_DISABLE_THINKING \
  -u MAX_THINKING_TOKENS \
  claude -p \
  --model "$model" \
  --effort "$effort" \
  --tools 'Read,Edit,Write,Glob,Grep' \
  --permission-mode acceptEdits \
  --safe-mode \
  --output-format stream-json \
  --verbose \
  --no-session-persistence \
  "$brief" >"$output_file" 2>&1
claude_status=$?
set -e

if [[ $claude_status -ne 0 ]]; then
  cat "$output_file" >&2
  printf 'crew: Claude worker blocked — Claude Code exited with status %s.\n' "$claude_status" >&2
  exit "$claude_status"
fi

effective_models="$(
  sed -nE \
    '/"type":"(system|assistant)"/s/.*"model":"([^"]+)".*/\1/p' \
    "$output_file"
)"

if [[ -z "$effective_models" ]]; then
  printf '%s\n' 'crew: Claude worker blocked — Claude Code did not report an effective model.' >&2
  exit 70
fi

while IFS= read -r effective_model; do
  case "$model" in
    *opus*) [[ "$effective_model" == *opus* ]] && model_matches=true || model_matches=false ;;
    *sonnet*) [[ "$effective_model" == *sonnet* ]] && model_matches=true || model_matches=false ;;
    *) [[ "$effective_model" == "$model" ]] && model_matches=true || model_matches=false ;;
  esac

  if [[ "$model_matches" != true ]]; then
    printf 'crew: Claude worker blocked — requested model %s, effective model %s.\n' \
      "$model" "$effective_model" >&2
    exit 70
  fi
done <<<"$effective_models"

cat "$output_file"
