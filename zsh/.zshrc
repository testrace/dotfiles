# Starship 프롬프트
eval "$(starship init zsh)"

# fzf
eval "$(fzf --zsh)"

# direnv
eval "$(direnv hook zsh)"

# 기본 설정
export EDITOR=nvim
export VISUAL=nvim
export PRE_COMMIT_COLOR=never
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Aliases (별도 파일)
source ~/.aliases

# 히스토리
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# zsh plugins
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zoxide
eval "$(zoxide init zsh)"
