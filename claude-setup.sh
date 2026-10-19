#!/usr/bin/env bash

# Claude Code 기본 설정을 연결한다. 여러 번 실행해도 안전하다.
# herdr-setup.sh보다 먼저 실행한다. 순서가 바뀌어도 settings.json 결과는 같다.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$DOTFILES_DIR/claude"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
STATUSLINE="$CLAUDE_DIR/statusline-command.sh"

# ~/.claude가 링크면 멈춘다. 링크를 따라가 다른 곳(예: 이 저장소)의 파일을 지우거나 덮어쓰게 된다.
refuse_linked_claude_dir() {
  if [[ -L "$CLAUDE_DIR" ]]; then
    echo "$CLAUDE_DIR 가 링크입니다 ($(readlink "$CLAUDE_DIR")). 일반 폴더로 바꾼 뒤 다시 실행하세요." >&2
    exit 1
  fi
}

# 1. CLAUDE.md를 저장소로 연결한다.
# 폴더를 먼저 만들어야 stow가 폴더 전체를 링크하지 않는다.
# 그러지 않으면 대화 기록, 플러그인 캐시가 저장소 안에 쌓인다.
refuse_linked_claude_dir
mkdir -p "$CLAUDE_DIR"

claude_md="$CLAUDE_DIR/CLAUDE.md"
if [[ -e "$claude_md" && ! -L "$claude_md" ]]; then
  if cmp -s "$claude_md" "$PACKAGE_DIR/.claude/CLAUDE.md"; then
    rm "$claude_md"
  else
    echo "$claude_md 파일이 저장소의 claude/.claude/CLAUDE.md와 다릅니다." >&2
    echo "내용을 저장소 파일에 합친 뒤 지우고 다시 실행하세요." >&2
    exit 1
  fi
fi

# settings.json이 망가져 있으면 아무것도 바꾸기 전에 멈춘다
if [[ -e "$SETTINGS" ]] && ! jq empty "$SETTINGS" 2> /dev/null; then
  echo "$SETTINGS 파일이 올바른 JSON이 아닙니다. 고친 뒤 다시 실행하세요." >&2
  exit 1
fi

stow --dir="$DOTFILES_DIR" --target="$HOME" claude
refuse_linked_claude_dir

# 2. 상태줄 스크립트는 링크하지 않고 복사한다. 내용이 다르면 먼저 백업한다.
if ! cmp -s "$PACKAGE_DIR/statusline-command.sh" "$STATUSLINE"; then
  if [[ -e "$STATUSLINE" ]]; then
    cp -p "$STATUSLINE" "$STATUSLINE.bak-$(date +%Y%m%d%H%M%S)"
  fi
  cp "$PACKAGE_DIR/statusline-command.sh" "$STATUSLINE"
fi
chmod 755 "$STATUSLINE"

# 3. settings.base.json을 settings.json에 합친다.
# 기본값에 있는 키는 기본값으로 맞추고, 나머지(herdr 훅, 다른 플러그인 등)는 그대로 둔다.
if [[ -e "$SETTINGS" ]]; then
  merged="$(jq -s '.[0] * .[1]' "$SETTINGS" "$PACKAGE_DIR/settings.base.json")"
else
  merged="$(jq . "$PACKAGE_DIR/settings.base.json")"
fi

if [[ ! -e "$SETTINGS" ]] || [[ "$(jq -S . "$SETTINGS")" != "$(jq -S . <<< "$merged")" ]]; then
  tmp="$(mktemp "$CLAUDE_DIR/settings.json.XXXXXX")"
  printf '%s\n' "$merged" > "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$SETTINGS"
fi

echo "Claude Code 설정을 마쳤습니다. 새 Claude Code 세션부터 적용됩니다."
