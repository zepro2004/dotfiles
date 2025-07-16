# ============================
#   Homebrew Path Setup (Linuxbrew)
# ============================
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi


# ============================
#   SDKMAN Initialization
# ============================
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ============================
#   Oh My Zsh Setup
# ============================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ============================
#   Command Path Setup
# ============================
export PATH="$HOME/.cargo/bin:$PATH"

# ============================
#   History Configuration
# ============================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_all_dups
zstyle ':history:' max-stored-size 1000000

# ============================
#   Alias Definitions
# ============================
# File system
#
# File listing aliases (clean, with icons, and structure)
alias ll='eza -l --header --git --icons=always --group-directories-first -a'
alias la='eza -a --icons=always --group-directories-first'
alias l='eza -l --header --icons=always --group-directories-first'
alias ls="eza -l --git --icons=always --group-directories-first --color=always"
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias c='clear'
alias back='cd -'
alias cd..='cd ..'
alias cd="z"
alias cdd='cd ~/Documents'

# Viewing files
alias cat='bat'
alias head='head -n 20'
alias tail='tail -n 20'
alias less='less -F -X'

# System info
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias top='htop'
alias ps='ps aux'
alias grep='grep --color=auto'
alias cpu='lscpu'

# Network
alias ipconfig='ifconfig'
alias ports='netstat -tuln'
alias ping='ping -c 5'
alias wget='wget -c'
alias ip='ip a'
alias myip='curl ifconfig.me'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gco='git checkout'
alias gl='git log --oneline'
alias glg='git log --graph --oneline --decorate --all'
alias gp='git push'
alias gpull='git pull'
alias gcl='git clone'
alias lg='lazygit'
alias gd='git diff'
alias gb='git branch'
alias gcm='git commit -m'

# Other handy aliases
alias path='echo $PATH'
alias h='history'
alias e='exit'
alias zshrc='nvim ~/.zshrc'
alias v='nvim'
alias update='sudo dnf upgrade -y'
alias reload='source ~/.zshrc'

export BAT_THEME=OneHalfDark

# ============================
#   FZF Configuration
# ============================
# Default commands
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Completion generators
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Colors
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"
export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# Preview command for FZF
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Custom fzf run function
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ============================
#   zoxide Setup
# ============================
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ============================
#   zsh-autosuggestions + zsh-syntax-highlighting (eager load)
# ============================
if [[ -f /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  # Optional styling tweaks
  (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[path]='fg=none,underline=no'
  ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=none,underline=no'
fi


# ============================
#   Lazy Loading Functions
# ============================

# Lazy-load fzf and its completions/bindings
fzf_init() {
  unset -f fzf_init
  if command -v fzf >/dev/null 2>&1; then
    [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
    [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook -Uz preexec fzf_init

# Lazy-load fzf-git if available
fzf_git_init() {
  unset -f fzf_git_init
  [[ -f ~/fzf-git.sh/fzf-git.sh ]] && source ~/fzf-git.sh/fzf-git.sh
}
add-zsh-hook -Uz preexec fzf_git_init

# Lazy-load fzf-tab plugin if available
fzf_tab_init() {
  unset -f fzf_tab_init
  [[ -f ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]] && source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
}
add-zsh-hook -Uz preexec fzf_tab_init

# ============================
#   Completion System
# ============================
if command -v brew >/dev/null 2>&1; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit

  # Enable compinit caching to speed up shell startup
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path ~/.zsh/cache/.zcompdump

  compinit
fi

# ============================
#   tmux Session Management
# ============================
#if [[ -n $PS1 ]] && command -v tmux >/dev/null 2>&1; then
#  if [[ -z "$TMUX" ]]; then
#    if tmux has-session -t Home 2>/dev/null; then
#      tmux attach -t Home
#    else
#      tmux new-session -s Home \; run-shell '~/.tmux/plugins/tmux-resurrect/scripts/restore.sh'
#    fi
#  fi
#fi
#alias home="tmux attach-session -t Home"

# ====================================
#   1Password SSH Agent Bridge for WSL  
# ====================================
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

if is_wsl; then
  AGENT_SOCK="$HOME/.ssh/agent.sock"
  RELAY_SCRIPT="$HOME/.ssh/1password-ssh-relay.sh"

  export SSH_AUTH_SOCK="$AGENT_SOCK"

  start_ssh_relay() {
    if ! pgrep -f "$(basename "$RELAY_SCRIPT")" >/dev/null 2>&1; then
      echo "Starting 1Password SSH agent relay..."
      nohup "$RELAY_SCRIPT" >/dev/null 2>&1 &
    fi
  }

  if [[ -z "$TMUX" ]]; then
    if [[ ! -S "$AGENT_SOCK" ]] || ! timeout 1 ssh-add -l >/dev/null 2>&1; then
      start_ssh_relay
    fi
  fi
fi

# ============================
#   Atuin History Management
eval "$(atuin init zsh)"
alias history='atuin history list'
alias fc='atuin search'

# Bind Up/Down arrow to fuzzy match history with current input
autoload -U up-line-or-search
autoload -U down-line-or-search

zle -N _atuin_up_search up-line-or-search
zle -N _atuin_down_search down-line-or-search

bindkey '^[[A' _atuin_up_search   # Up Arrow
bindkey '^[[B' _atuin_down_search # Down Arrow
