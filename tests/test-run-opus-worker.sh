#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
runner="$repo_root/skills/crew/scripts/run-claude-worker.sh"
test_root="$(mktemp -d)"
cleanup() {
  status=$?
  trap - EXIT
  rm -rf "$test_root"
  exit "$status"
}
trap cleanup EXIT

mkdir -p "$test_root/bin" "$test_root/repo"
git -C "$test_root/repo" init -q
git -C "$test_root/repo" config user.email crew-test@example.invalid
git -C "$test_root/repo" config user.name 'Crew test'
git -C "$test_root/repo" commit --allow-empty -qm initial
git -C "$test_root/repo" worktree add -q "$test_root/work" -b bridge-test
work_dir="$(cd "$test_root/work" && pwd -P)"
brief_file="$test_root/brief.txt"
capture_file="$test_root/capture.txt"
printf '%s\n' 'GOAL: Implement the assigned frontend component.' > "$brief_file"

cat > "$test_root/bin/claude" <<'FAKE_CLAUDE'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "auth" && "${2:-}" == "status" ]]; then
  if [[ "${CREW_FAKE_AUTH_FAIL:-0}" == "1" ]]; then
    printf '%s\n' 'sensitive authentication output'
    exit 1
  fi
  exit 0
fi

{
  printf 'cwd=%s\n' "$PWD"
  printf 'effort_env=%s\n' "${CLAUDE_CODE_EFFORT_LEVEL-unset}"
  printf 'subagent_model_env=%s\n' "${CLAUDE_CODE_SUBAGENT_MODEL-unset}"
  printf 'disable_thinking_env=%s\n' "${CLAUDE_CODE_DISABLE_THINKING-unset}"
  printf 'max_thinking_env=%s\n' "${MAX_THINKING_TOKENS-unset}"
  printf 'arg=%s\n' "$@"
} > "$CREW_CLAUDE_CAPTURE"

effective_model="${CREW_FAKE_EFFECTIVE_MODEL:-claude-opus-5}"
printf '{"type":"system","subtype":"init","model":"%s"}\n' "$effective_model"
printf '{"type":"assistant","message":{"model":"%s","content":[]}}\n' "$effective_model"
printf '%s\n' '{"type":"result","subtype":"success","result":"worker complete"}'
FAKE_CLAUDE
chmod +x "$test_root/bin/claude"

bridge_output="$(PATH="$test_root/bin:$PATH" \
  CREW_CLAUDE_CAPTURE="$capture_file" \
  CLAUDE_CODE_EFFORT_LEVEL=low \
  CLAUDE_CODE_SUBAGENT_MODEL=sonnet \
  CLAUDE_CODE_DISABLE_THINKING=1 \
  MAX_THINKING_TOKENS=1 \
  "$runner" "$work_dir" "$brief_file" opus high)"

grep -Fx "cwd=$work_dir" "$capture_file"
grep -Fx 'effort_env=unset' "$capture_file"
grep -Fx 'subagent_model_env=unset' "$capture_file"
grep -Fx 'disable_thinking_env=unset' "$capture_file"
grep -Fx 'max_thinking_env=unset' "$capture_file"
grep -Fx 'arg=-p' "$capture_file"
grep -Fx 'arg=--model' "$capture_file"
grep -Fx 'arg=opus' "$capture_file"
grep -Fx 'arg=--effort' "$capture_file"
grep -Fx 'arg=high' "$capture_file"
grep -Fx 'arg=--tools' "$capture_file"
grep -Fx 'arg=Read,Edit,Write,Glob,Grep' "$capture_file"
grep -Fx 'arg=--permission-mode' "$capture_file"
grep -Fx 'arg=acceptEdits' "$capture_file"
grep -Fx 'arg=--safe-mode' "$capture_file"
grep -Fx 'arg=--output-format' "$capture_file"
grep -Fx 'arg=stream-json' "$capture_file"
grep -Fx 'arg=--verbose' "$capture_file"
grep -Fx 'arg=GOAL: Implement the assigned frontend component.' "$capture_file"
grep -F '"model":"claude-opus-5"' <<<"$bridge_output"
grep -F '"result":"worker complete"' <<<"$bridge_output"

model_output="$test_root/model-mismatch.txt"
set +e
PATH="$test_root/bin:$PATH" \
  CREW_CLAUDE_CAPTURE="$capture_file" \
  CREW_FAKE_EFFECTIVE_MODEL=claude-sonnet-4-6 \
  "$runner" "$work_dir" "$brief_file" opus high >"$model_output" 2>&1
model_status=$?
set -e
[[ $model_status -eq 70 ]]
grep -F 'requested model opus, effective model claude-sonnet-4-6' "$model_output"

sonnet_output="$(PATH="$test_root/bin:$PATH" \
  CREW_CLAUDE_CAPTURE="$capture_file" \
  CREW_FAKE_EFFECTIVE_MODEL=claude-sonnet-4-6 \
  "$runner" "$work_dir" "$brief_file" sonnet high)"
grep -F '"model":"claude-sonnet-4-6"' <<<"$sonnet_output"

sonnet_mismatch_output="$test_root/sonnet-mismatch.txt"
set +e
PATH="$test_root/bin:$PATH" \
  CREW_CLAUDE_CAPTURE="$capture_file" \
  CREW_FAKE_EFFECTIVE_MODEL=claude-opus-5 \
  "$runner" "$work_dir" "$brief_file" sonnet high >"$sonnet_mismatch_output" 2>&1
sonnet_mismatch_status=$?
set -e
[[ $sonnet_mismatch_status -eq 70 ]]
grep -F 'requested model sonnet, effective model claude-opus-5' "$sonnet_mismatch_output"

main_worktree_output="$test_root/main-worktree.txt"
set +e
PATH="$test_root/bin:$PATH" \
  CREW_CLAUDE_CAPTURE="$capture_file" \
  "$runner" "$test_root/repo" "$brief_file" opus high >"$main_worktree_output" 2>&1
main_worktree_status=$?
set -e
[[ $main_worktree_status -eq 66 ]]
grep -F 'work directory must be an isolated Git worktree' "$main_worktree_output"

missing_cli_output="$test_root/missing-cli.txt"
set +e
PATH="/usr/bin:/bin" /bin/bash "$runner" \
  "$work_dir" "$brief_file" opus high >"$missing_cli_output" 2>&1
missing_cli_status=$?
set -e
[[ $missing_cli_status -eq 69 ]]
grep -F 'Claude Code CLI is unavailable' "$missing_cli_output"

auth_output="$test_root/auth-failure.txt"
set +e
PATH="$test_root/bin:$PATH" \
  CREW_FAKE_AUTH_FAIL=1 \
  "$runner" "$work_dir" "$brief_file" opus high >"$auth_output" 2>&1
auth_status=$?
set -e
[[ $auth_status -eq 69 ]]
grep -F 'Claude Code authentication is unavailable' "$auth_output"
if grep -F 'sensitive authentication output' "$auth_output"; then
  printf '%s\n' 'FAIL: authentication output was not suppressed.' >&2
  exit 1
fi

printf '%s\n' 'PASS: Claude worker bridge preserves routing and fails closed.'
