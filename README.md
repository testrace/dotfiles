# My Dotfiles

크로스 플랫폼 개발 환경 설정 (macOS 중심)

## 포함된 도구

### 터미널
- **Ghostty** - GPU 가속 터미널
- **tmux** - 세션 관리
- **Starship** - 프롬프트
- **zsh** - 쉘

### 에디터
- **Neovim (LazyVim)** - 터미널 에디터
- 행번호, 상대번호 설정
- 시스템 클립보드 연동
- vim-tmux-navigator (Ctrl+hjkl로 nvim/tmux 패널 이동)

### 개발 도구
- **Git** + delta (diff 뷰어)
- **lazygit** - Git TUI
- **fzf, ripgrep, fd, bat, eza** - CLI 도구
- **direnv** - 프로젝트별 환경변수 자동 전환
- **SDKMAN** - Java 버전 관리

### macOS
- **AeroSpace** - 타일링 윈도우 매니저
- **Hammerspoon** - rcmd→F18 리맵, ESC 시 영문 전환
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
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 4. 패키지 설치
```bash
brew bundle
brew install stow
```

### 5. Git 설정 (개인 정보)
```bash
cp git/.gitconfig.example git/.gitconfig
vim git/.gitconfig  # name, email 수정
```

### 6. 심볼릭 링크
```bash
stow ghostty
stow zsh
stow starship
stow tmux
stow nvim
stow git
stow aerospace
stow hammerspoon
stow sdkman
```

### 7. SDKMAN + Java 설치
```bash
./sdkman-install.sh
```

### 8. tmux 플러그인 설치
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux
# tmux 안에서 Ctrl+b I (Shift+i) 로 플러그인 설치
```

### 9. 쉘 재시작
```bash
source ~/.zshrc
```

### 9-1. direnv 사용
```bash
echo 'export FOO=bar' > .envrc
direnv allow
```

- 프로젝트 디렉토리에 들어가면 `.envrc`가 자동 적용됨
- 처음 보는 `.envrc`는 `direnv allow`로 한 번 승인해야 함

### 10. Pre-commit 훅
```bash
pre-commit install
```

### 11. AeroSpace 실행
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
- Pre-commit 훅이 민감정보 검사

## tmux 플러그인

- **tmux-sensible** - 합리적인 기본 설정
- **tmux-resurrect** - 세션 저장/복원
- **tmux-continuum** - 자동 세션 저장
- **catppuccin/tmux** - Frappe 테마

## 업데이트
```bash
cd ~/dotfiles
git pull
brew bundle  # 새 패키지 설치
```
