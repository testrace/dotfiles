#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
FAKE_BIN_DIR="$TMP_DIR/bin"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

mkdir -p "$FAKE_BIN_DIR"

# FAKE_STATE=fresh: 아무것도 설치되지 않은 새 Mac
# FAKE_STATE=done:  이미 모두 설치된 Mac
cat > "$FAKE_BIN_DIR/stow" <<'EOF'
#!/usr/bin/env bash
if [[ -d "$HOME/.config/herdr" && ! -L "$HOME/.config/herdr" ]]; then
  echo "stow $* (dir ready)" >> "$COMMAND_LOG"
else
  echo "stow $* (dir missing)" >> "$COMMAND_LOG"
fi
EOF

cat > "$FAKE_BIN_DIR/herdr" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
  "plugin list")
    if [[ "$FAKE_STATE" == done ]]; then
      echo '{"id":"cli:plugin","result":{"plugins":[{"plugin_id":"herdr-file-viewer"}],"type":"plugin_list"}}'
    else
      echo '{"id":"cli:plugin","result":{"plugins":[],"type":"plugin_list"}}'
    fi
    ;;
  "plugin install")
    echo "herdr $*" >> "$COMMAND_LOG"
    ;;
  "integration status")
    if [[ "$FAKE_STATE" == done ]]; then
      echo "claude: installed ($HOME/.claude/hooks/herdr-agent-state.sh)"
    else
      echo "claude: not installed ($HOME/.claude/hooks/herdr-agent-state.sh)"
    fi
    ;;
  "integration install")
    echo "herdr $*" >> "$COMMAND_LOG"
    ;;
  *)
    echo "unexpected herdr command: $*" >&2
    exit 98
    ;;
esac
EOF

cat > "$FAKE_BIN_DIR/tsk" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  "setup herdr --check")
    if [[ "$FAKE_STATE" == done ]]; then echo bound; else echo unbound; fi
    ;;
  "setup herdr")
    echo "tsk $*" >> "$COMMAND_LOG"
    ;;
  "setup claude")
    echo "tsk $*" >> "$COMMAND_LOG"
    if [[ "$FAKE_STATE" == done ]]; then
      echo "tsk setup: skill-exists" >&2
      exit 1
    fi
    ;;
  *)
    echo "unexpected tsk command: $*" >&2
    exit 98
    ;;
esac
EOF

chmod +x "$FAKE_BIN_DIR"/*

failures=0

run_case() {
  local name="$1" state="$2" expected_status="$3" expected_log="$4"
  local home="$TMP_DIR/home-$name"
  local log="$TMP_DIR/$name.log"
  mkdir -p "$home"
  : > "$log"

  if [[ -n "${5:-}" ]]; then
    "$5" "$home"
  fi

  local status=0
  PATH="$FAKE_BIN_DIR:$PATH" HOME="$home" FAKE_STATE="$state" COMMAND_LOG="$log" \
    bash "$ROOT_DIR/herdr-setup.sh" > "$TMP_DIR/$name.out" 2>&1 || status=$?

  local actual_log
  actual_log="$(cat "$log")"

  if [[ "$status" != "$expected_status" || "$actual_log" != "$expected_log" ]]; then
    failures=$((failures + 1))
    echo "FAIL: $name" >&2
    echo "  expected exit $expected_status, got $status" >&2
    echo "  expected commands:" >&2
    printf '%s\n' "$expected_log" | sed 's/^/    /' >&2
    echo "  actual commands:" >&2
    printf '%s\n' "$actual_log" | sed 's/^/    /' >&2
    echo "  script output:" >&2
    sed 's/^/    /' "$TMP_DIR/$name.out" >&2
  fi
}

existing_config_file() {
  mkdir -p "$1/.config/herdr"
  echo 'onboarding = false' > "$1/.config/herdr/config.toml"
}

run_case fresh fresh 0 "stow --dir=$ROOT_DIR --target=$TMP_DIR/home-fresh herdr (dir ready)
herdr plugin install -y smarzban/herdr-file-viewer
tsk setup herdr
tsk setup claude
herdr integration install claude"

run_case rerun done 0 "stow --dir=$ROOT_DIR --target=$TMP_DIR/home-rerun herdr (dir ready)
tsk setup claude"

run_case existing-config fresh 1 "" existing_config_file

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

echo "herdr-setup tests passed"
