# Starship 프롬프트
eval "$(starship init zsh)"

# fzf
eval "$(fzf --zsh)"

# zoxide
eval "$(zoxide init zsh)"

# 기본 설정
export EDITOR=nvim
export VISUAL=nvim

# Aliases (별도 파일)
source ~/.aliases

# 히스토리
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

export PATH="$HOME/.local/bin:$PATH"

export PRE_COMMIT_COLOR=never

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# zsh plugins
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
