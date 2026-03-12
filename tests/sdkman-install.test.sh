#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
COMMAND_LOG="$TMP_DIR/commands.log"
FAKE_SDKMAN_DIR="$TMP_DIR/fake-sdkman"
FAKE_BIN_DIR="$TMP_DIR/bin"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

mkdir -p "$FAKE_SDKMAN_DIR/bin" "$FAKE_BIN_DIR"

cat > "$FAKE_SDKMAN_DIR/bin/sdkman-init.sh" <<'EOF'
sdk() {
  case "$1" in
    list)
      cat <<'LIST'
================================================================================
Available Java Versions for macOS ARM 64bit
================================================================================
 Vendor        | Use | Version      | Dist    | Status     | Identifier
--------------------------------------------------------------------------------
 Temurin       |     | 25.0.2       | tem     |            | 25.0.2-tem
               |     | 25.0.1       | tem     |            | 25.0.1-tem
               |     | 21.0.10      | tem     |            | 21.0.10-tem
               |     | 21.0.9       | tem     |            | 21.0.9-tem
--------------------------------------------------------------------------------
LIST
      ;;
    install)
      printf 'sdk install %s %s\n' "$2" "$3" >> "$COMMAND_LOG"
      ;;
    default)
      printf 'sdk default %s %s\n' "$2" "$3" >> "$COMMAND_LOG"
      ;;
    *)
      echo "unexpected sdk command: $*" >&2
      return 1
      ;;
  esac
}
EOF

cat > "$FAKE_BIN_DIR/curl" <<'EOF'
#!/usr/bin/env bash

echo "curl should not be called in this test" >&2
exit 99
EOF

chmod +x "$FAKE_BIN_DIR/curl"

PATH="$FAKE_BIN_DIR:$PATH" \
SDKMAN_DIR="$FAKE_SDKMAN_DIR" \
COMMAND_LOG="$COMMAND_LOG" \
bash "$ROOT_DIR/sdkman-install.sh"

EXPECTED_OUTPUT=$'sdk install java 21.0.10-tem\nsdk install java 25.0.2-tem\nsdk default java 25.0.2-tem\n'
ACTUAL_OUTPUT="$(cat "$COMMAND_LOG" 2>/dev/null || true)"

if [[ "${ACTUAL_OUTPUT}"$'\n' != "$EXPECTED_OUTPUT" ]]; then
  echo "Unexpected SDKMAN commands" >&2
  echo "Expected:" >&2
  printf '%s' "$EXPECTED_OUTPUT" >&2
  echo "Actual:" >&2
  printf '%s\n' "$ACTUAL_OUTPUT" >&2
  exit 1
fi
