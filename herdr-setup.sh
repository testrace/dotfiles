#!/usr/bin/env bash

# herdr 설정을 연결하고 tsk, Claude Code와 이어 준다. 여러 번 실행해도 안전하다.
# herdr와 tsk는 brew로 설치한다 (brew bundle). 업데이트도 brew upgrade로 한다.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERDR_CONFIG_DIR="$HOME/.config/herdr"
HERDR_CONFIG_FILE="$HERDR_CONFIG_DIR/config.toml"

# ~/.config/herdr가 링크면 멈춘다. 링크를 따라가 다른 곳(예: 이 저장소)의 파일을 지우거나 덮어쓰게 된다.
refuse_linked_config_dir() {
  if [[ -L "$HERDR_CONFIG_DIR" ]]; then
    echo "$HERDR_CONFIG_DIR 가 링크입니다 ($(readlink "$HERDR_CONFIG_DIR")). 일반 폴더로 바꾼 뒤 다시 실행하세요." >&2
    exit 1
  fi
}
refuse_linked_config_dir

# 1. config.toml만 저장소로 연결한다.
# 폴더를 먼저 만들어야 stow가 폴더 전체를 링크하지 않는다.
# 그러지 않으면 herdr의 로그, 소켓, 세션 기록이 저장소 안에 쌓인다.
if [[ -e "$HERDR_CONFIG_FILE" && ! -L "$HERDR_CONFIG_FILE" ]]; then
  echo "$HERDR_CONFIG_FILE 파일이 이미 있습니다." >&2
  echo "저장소의 herdr/.config/herdr/config.toml과 합친 뒤 지우고 다시 실행하세요." >&2
  exit 1
fi
mkdir -p "$HERDR_CONFIG_DIR"

# 출력을 변수에 먼저 담는다. `herdr ... | grep -q`는 grep이 먼저 끝나면
# herdr가 SIGPIPE로 종료되고, pipefail 때문에 조건이 거짓이 된다.
plugin_missing() {
  local output
  output="$(herdr plugin list --plugin "$1" --json)"
  [[ "$output" == *'"plugins":[]'* ]]
}

# 2. herdr에 tsk 보드 플러그인 등록
# tsk는 링크된 config.toml을 열지 않으므로 stow보다 먼저 실행한다.
# tsk가 만든 config.toml은 지운다. 저장소 config.toml에 tsk 단축키가 이미 들어 있다.
if plugin_missing herdr-tsk; then
  rm -f "$HERDR_CONFIG_FILE"
  tsk setup herdr
  rm -f "$HERDR_CONFIG_FILE"
fi

stow --dir="$DOTFILES_DIR" --target="$HOME" herdr
refuse_linked_config_dir

# 3. 파일 뷰어 플러그인
if plugin_missing herdr-file-viewer; then
  herdr plugin install -y smarzban/herdr-file-viewer
fi

# 4. Claude Code에 tsk 스킬 설치 (이미 있으면 skill-exists로 거절되며, 그건 정상)
if ! claude_output="$(tsk setup claude 2>&1)"; then
  if [[ "$claude_output" != *skill-exists* ]]; then
    echo "$claude_output" >&2
    exit 1
  fi
fi

# 5. Claude Code가 작업 중인지 herdr에 알려 주는 연결 (대화 복원에도 필요)
integration_status="$(herdr integration status)"
if ! grep -q '^claude: current' <<< "$integration_status"; then
  herdr integration install claude
fi

echo "herdr 설정을 마쳤습니다. 실행 중인 herdr에 반영하려면: herdr server reload-config"
