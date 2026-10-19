#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

failures=0

fail() {
  failures=$((failures + 1))
  echo "FAIL: $1" >&2
  if [[ -n "${2:-}" && -f "$2" ]]; then
    sed 's/^/    /' "$2" >&2
  fi
}

new_home() {
  local home="$TMP_DIR/$1"
  mkdir -p "$home"
  echo "$home"
}

# 실제 stow를 쓴다. .stow-local-ignore가 제대로 동작하는지까지 확인하기 위해서다.
run_setup() {
  HOME="$1" bash "$ROOT_DIR/claude-setup.sh" > "$TMP_DIR/out" 2>&1
}

settings_equal_base() {
  diff <(jq -S . "$1/.claude/settings.json") <(jq -S . "$ROOT_DIR/claude/settings.base.json") > /dev/null
}

# herdr-setup.sh가 settings.json에 훅을 넣는 동작을 흉내 낸다
add_herdr_hook() {
  local settings="$1/.claude/settings.json"
  mkdir -p "$1/.claude"
  [[ -f "$settings" ]] || echo '{}' > "$settings"
  jq '.hooks.SessionStart = [{"hooks": [{"type": "command", "command": "bash herdr-agent-state.sh session"}]}]' \
    "$settings" > "$settings.tmp"
  mv "$settings.tmp" "$settings"
}

# 1. 새 Mac: 아무것도 없는 상태
home="$(new_home fresh)"
if run_setup "$home"; then
  [[ -d "$home/.claude" && ! -L "$home/.claude" ]] || fail "fresh: ~/.claude must be a real folder, not a link"
  [[ -L "$home/.claude/CLAUDE.md" ]] || fail "fresh: CLAUDE.md must be a link"
  [[ -f "$home/.claude/statusline-command.sh" && ! -L "$home/.claude/statusline-command.sh" ]] \
    || fail "fresh: statusline-command.sh must be a copied file"
  [[ -x "$home/.claude/statusline-command.sh" ]] || fail "fresh: statusline-command.sh must be executable"
  [[ ! -e "$home/.claude/settings.base.json" && ! -e "$home/settings.base.json" && ! -e "$home/statusline-command.sh" ]] \
    || fail "fresh: files listed in .stow-local-ignore must not be linked"
  settings_equal_base "$home" || fail "fresh: settings.json must equal settings.base.json"
else
  fail "fresh: setup failed" "$TMP_DIR/out"
fi

# 2. 다시 실행: 바뀌는 것도, 백업도 없어야 한다
home="$(new_home rerun)"
run_setup "$home"
before="$(cat "$home/.claude/settings.json")"
if run_setup "$home"; then
  [[ "$(cat "$home/.claude/settings.json")" == "$before" ]] || fail "rerun: settings.json changed"
  ! compgen -G "$home/.claude/statusline-command.sh.bak-*" > /dev/null || fail "rerun: unexpected statusline backup"
else
  fail "rerun: setup failed" "$TMP_DIR/out"
fi

# 3. 기존 settings.json: 다른 값은 지키고, 기본값 키는 기본값으로 맞춘다
home="$(new_home existing-settings)"
mkdir -p "$home/.claude"
cat > "$home/.claude/settings.json" <<'EOF'
{
  "model": "sonnet",
  "enabledPlugins": { "other@market": true },
  "hooks": { "SessionStart": [] },
  "permissions": { "allow": ["Bash(ls)"] }
}
EOF
if run_setup "$home"; then
  s="$home/.claude/settings.json"
  [[ "$(jq -r .model "$s")" == opus ]] || fail "existing-settings: model must become opus"
  [[ "$(jq -r '.enabledPlugins["other@market"]' "$s")" == true ]] || fail "existing-settings: other plugin lost"
  [[ "$(jq -r '.enabledPlugins["superpowers@claude-plugins-official"]' "$s")" == true ]] || fail "existing-settings: superpowers missing"
  [[ "$(jq -c .hooks "$s")" == '{"SessionStart":[]}' ]] || fail "existing-settings: hooks lost"
  [[ "$(jq -c .permissions "$s")" == '{"allow":["Bash(ls)"]}' ]] || fail "existing-settings: permissions lost"
  [[ "$(stat -f %Lp "$s")" == 600 ]] || fail "existing-settings: settings.json must stay 600"
else
  fail "existing-settings: setup failed" "$TMP_DIR/out"
fi

# 4. 내용이 다른 상태줄 스크립트: 백업한 뒤 바꾼다
home="$(new_home statusline-differs)"
mkdir -p "$home/.claude"
echo 'echo old' > "$home/.claude/statusline-command.sh"
if run_setup "$home"; then
  backups=("$home"/.claude/statusline-command.sh.bak-*)
  [[ -f "${backups[0]}" && "$(cat "${backups[0]}")" == 'echo old' ]] || fail "statusline-differs: backup missing"
  cmp -s "$home/.claude/statusline-command.sh" "$ROOT_DIR/claude/statusline-command.sh" \
    || fail "statusline-differs: statusline not replaced"
else
  fail "statusline-differs: setup failed" "$TMP_DIR/out"
fi

# 5. 저장소와 같은 내용의 CLAUDE.md가 일반 파일로 있음: 지우고 링크한다
home="$(new_home claude-md-same)"
mkdir -p "$home/.claude"
cp "$ROOT_DIR/claude/.claude/CLAUDE.md" "$home/.claude/CLAUDE.md"
if run_setup "$home"; then
  [[ -L "$home/.claude/CLAUDE.md" ]] || fail "claude-md-same: CLAUDE.md must become a link"
else
  fail "claude-md-same: setup failed" "$TMP_DIR/out"
fi

# 6. 내용이 다른 CLAUDE.md: 덮어쓰지 않고 멈춘다
home="$(new_home claude-md-differs)"
mkdir -p "$home/.claude"
echo '- my own rule' > "$home/.claude/CLAUDE.md"
if run_setup "$home"; then
  fail "claude-md-differs: setup must fail"
else
  [[ ! -L "$home/.claude/CLAUDE.md" && "$(cat "$home/.claude/CLAUDE.md")" == '- my own rule' ]] \
    || fail "claude-md-differs: CLAUDE.md was changed"
  [[ ! -e "$home/.claude/settings.json" ]] || fail "claude-md-differs: settings.json must not be written"
fi

# 7. 망가진 settings.json: 건드리지 않고 멈춘다
home="$(new_home broken-settings)"
mkdir -p "$home/.claude"
echo '{ not json' > "$home/.claude/settings.json"
if run_setup "$home"; then
  fail "broken-settings: setup must fail"
else
  [[ "$(cat "$home/.claude/settings.json")" == '{ not json' ]] || fail "broken-settings: settings.json was changed"
fi

# 8. ~/.claude가 링크: 링크 너머의 파일을 건드리지 않고 멈춘다
home="$(new_home linked-claude-dir)"
elsewhere="$TMP_DIR/elsewhere"
mkdir -p "$elsewhere"
# 저장소와 같은 내용이면 안전장치가 없을 때 이 파일이 지워진다
cp "$ROOT_DIR/claude/.claude/CLAUDE.md" "$elsewhere/CLAUDE.md"
ln -s "$elsewhere" "$home/.claude"
if run_setup "$home"; then
  fail "linked-claude-dir: setup must fail"
else
  [[ -f "$elsewhere/CLAUDE.md" && ! -e "$elsewhere/settings.json" && ! -e "$elsewhere/statusline-command.sh" ]] \
    || fail "linked-claude-dir: files behind the link were changed"
fi

# 9. herdr-setup.sh와 실행 순서가 바뀌어도 settings.json 결과가 같아야 한다
home_a="$(new_home order-claude-first)"
run_setup "$home_a" && add_herdr_hook "$home_a"
home_b="$(new_home order-herdr-first)"
add_herdr_hook "$home_b" && run_setup "$home_b"
diff <(jq -S . "$home_a/.claude/settings.json") <(jq -S . "$home_b/.claude/settings.json") > "$TMP_DIR/order.diff" \
  || fail "order: settings.json differs by run order" "$TMP_DIR/order.diff"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

echo "claude-setup tests passed"
