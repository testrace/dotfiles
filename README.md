# My Dotfiles

크로스 플랫폼 개발 환경 설정 (macOS 중심)

## 포함된 도구

### 터미널
- **WezTerm** - GPU 가속 터미널
- **tmux** - 세션 관리
- **Starship** - 프롬프트
- **zsh** - 쉘

### 에디터
- **Neovim (LazyVim)** - 터미널 에디터
- 행번호, 상대번호 설정

### 개발 도구
- **Git** + delta (diff 뷰어)
- **lazygit** - Git TUI
- **fzf, ripgrep, fd, bat, eza** - CLI 도구

### macOS
- **AeroSpace** - 타일링 윈도우 매니저
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
stow wezterm
stow zsh
stow starship
stow tmux
stow nvim
stow git
stow aerospace
```

### 7. 쉘 재시작
```bash
source ~/.zshrc
```

### 8. Pre-commit 훅
```bash
pre-commit install
```

### 9. AeroSpace 실행
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
- Pre-commit 훅이 민감정보 검사

## 업데이트
```bash
cd ~/dotfiles
git pull
brew bundle  # 새 패키지 설치
```
