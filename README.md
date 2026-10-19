# My Dotfiles

크로스 플랫폼 개발 환경 설정 (macOS 중심)

## 포함된 도구

### 터미널
- **Ghostty** - GPU 가속 터미널
- **herdr** - 터미널 작업 공간 관리 (패널, 탭, 세션 유지, AI 에이전트 상태 표시)
- **tsk** - 터미널 작업 보드 (herdr, Claude Code와 연결)
- **Starship** - 프롬프트
- **zsh** - 쉘

### 에디터
- **Neovim (LazyVim)** - 터미널 에디터
- 행번호, 상대번호 설정
- OSC 52 클립보드 복사 (SSH로 접속해도 지금 보고 있는 기기의 클립보드로 복사)
- Ctrl+hjkl로 nvim 창 이동 (LazyVim 기본)

### 개발 도구
- **Git** + delta (diff 뷰어)
- **lazygit** - Git TUI
- **gh, glab** - GitHub / GitLab CLI
- **fzf, ripgrep, fd, bat, eza, tree** - CLI 도구
- **ast-grep** - 코드 구조 기준 검색·치환
- **yq** - YAML 처리 (JSON은 macOS 기본 `jq`)
- **coreutils** - GNU 명령 (`gtimeout` 등)
- **zoxide** - 자주 가는 디렉토리로 빠르게 이동
- **yazi** - 터미널 파일 관리자
- **btop** - 시스템 모니터
- **direnv** - 프로젝트별 환경변수 자동 전환
- **SDKMAN** - Java 버전 관리
- **node** - Node.js
- **go** - Go
- **uv** - Python 실행·패키지 관리
- **shellcheck** - 셸 스크립트 검사
- **OrbStack** - Docker 컨테이너, Linux VM

### macOS
- **AeroSpace** - 타일링 윈도우 매니저
- **Hammerspoon** - rcmd→F18 리맵, ESC 시 영문 전환, Shift+ESC 시 한글 전환
- **Raycast** - 런처
- **Tailscale** - 기기 사이 VPN (원격 작업)
- **Homebrew** - 패키지 관리

### 보안
- **gitleaks** - 비밀키 검사
- **pre-commit** - 커밋 전 검증

## 설치 (새 Mac)

### 1. Xcode Command Line Tools
```bash
xcode-select --install
```

### 2. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Dotfiles 클론
```bash
git clone https://github.com/testrace/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 4. 패키지 설치
```bash
brew bundle
```

### 5. Git 설정 (개인 정보)
```bash
cp git/.gitconfig.example git/.gitconfig
vim git/.gitconfig  # name, email 수정
```

### 6. SDKMAN + Java 설치
```bash
./sdkman-install.sh
```

### 7. 심볼릭 링크
```bash
stow ghostty
stow zsh
stow starship
stow nvim
stow git
stow aerospace
stow hammerspoon
rm ~/.sdkman/etc/config  # 6번 설치 스크립트가 만든 기본 config를 지우고 저장소 config로 연결
stow sdkman
```

- SDKMAN을 먼저 설치해야 `~/.sdkman`이 실제 폴더로 만들어진다. 순서를 바꾸면 SDKMAN과 JDK가 저장소 안에 설치되고, 설치 스크립트가 저장소의 config에 기본값을 덧붙인다.

### 8. herdr + tsk 설정
```bash
./herdr-setup.sh
```

- `herdr/.config/herdr/config.toml`을 연결하고, 파일 뷰어 플러그인 설치, herdr에 tsk 등록, Claude Code에 tsk 스킬과 herdr 연결 설치를 한 번에 한다
- 이미 된 단계는 건너뛰므로 여러 번 실행해도 안전하다

### 9. 쉘 재시작
```bash
source ~/.zshrc
```

### 10. direnv 사용
```bash
echo 'export FOO=bar' > .envrc
direnv allow
```

- 프로젝트 디렉토리에 들어가면 `.envrc`가 자동 적용됨
- 처음 보는 `.envrc`는 `direnv allow`로 한 번 승인해야 함

### 11. Pre-commit 훅
```bash
pre-commit install
```

### 12. AeroSpace 실행
```bash
open -a AeroSpace
# 접근성 권한 허용
```

## 폰트

- **JetBrains Mono Nerd Font** - 영문, 아이콘
- **Sarasa Gothic** - 한글 (Sarasa Term K 사용)

## 주의사항

- `git/.gitconfig`는 개인정보라 저장소에 없음
- `.gitconfig.example`을 복사해서 사용
- `stow git`는 `~/.config/git/ignore`도 연결하며 `.DS_Store` 등을 전역 무시함
- `sdkman/.sdkman/etc/config`로 SDKMAN 설정을 관리하며 `.sdkmanrc` 자동 전환이 켜져 있음
- herdr는 `config.toml`만 저장소에서 관리함. 같은 폴더의 로그, 소켓, 세션 기록은 저장소에 넣지 않음
- Pre-commit 훅이 민감정보 검사

## herdr 

- herdr와 tsk는 brew로 설치했으므로 `herdr update`, `tsk update` 대신 `brew upgrade`로 업데이트한다
- brew로 herdr를 업데이트한 뒤에는 `herdr server stop`으로 서버를 껐다가 다시 `herdr`를 실행해야 새 버전이 적용된다
- `config.toml`을 고친 뒤에는 `herdr server reload-config`로 바로 반영한다

## 테스트
```bash
bash tests/sdkman-install.test.sh
bash tests/herdr-setup.test.sh
nvim -l tests/hammerspoon-init.test.lua
```

## 업데이트
```bash
cd ~/dotfiles
git pull
brew bundle  # 새 패키지 설치
```
