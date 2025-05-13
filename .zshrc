# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(starship init zsh)"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# fzf-git
source ~/fzf-git.sh/fzf-git.sh

# Syntax Highlighting
source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable underline for paths
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=none,underline=no'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=none,underline=no'

# History settings for zsh
HISTFILE=~/.zsh_history   # File to store history
HISTSIZE=10000            # Number of commands to keep in memory
SAVEHIST=10000            # Number of commands to save to file
setopt append_history     # Append history instead of overwriting
setopt share_history      # Share history across all sessions

# General Aliases
alias ll='eza -lah'  # List all files in long format with human-readable file sizes
alias la='eza -A'    # List all files except '.' and '..'
alias l='eza -l'     # Simple long listing

# Navigation
alias ..='cd ..'     # Go up one directory
alias ...='cd ../..' # Go up two directories
alias ~='cd ~'       # Go to home directory
alias c='clear'      # Clear the terminal screen
alias back='cd -'    # Go back to the previous directory
alias cd..='cd ..'   # Aliased cd ..
alias cdd='cd ~/Documents'  # Go to Documents folder

# File Management
alias rm='rm -i'      # Ask for confirmation before removing files
alias cp='cp -i'      # Ask for confirmation before overwriting files
alias mv='mv -i'      # Ask for confirmation before overwriting files
alias mkdir='mkdir -p' # Make parent directories as needed

# Viewing Files
alias cat='bat'       # Use `bat` instead of `cat` for syntax highlighting
alias head='head -n 20' # Show the first 20 lines of a file by default
alias tail='tail -n 20' # Show the last 20 lines of a file by default
alias less='less -F -X'  # Exit if the output fits on one screen

# System Information
alias df='df -h'      # Display disk space in human-readable format
alias du='du -h'      # Display disk usage in human-readable format
alias free='free -h'  # Show memory usage in human-readable format
alias top='htop'      # Use `htop` instead of `top` (if installed)
alias ps='ps aux'     # Display all processes with more detail
alias grep='grep --color=auto'  # Highlight search results in `grep`

# Networking
alias ipconfig='ifconfig'  # Use `ifconfig` instead of `ipconfig`
alias ports='netstat -tuln' # Show all active ports and services
alias ping='ping -c 5'      # Ping 5 times instead of default 4
alias wget='wget -c'        # Continue downloading files if interrupted

# Git Aliases
alias g='git'                  # Shortcut for `git`
alias gs='git status'           # Git status
alias ga='git add'              # Git add
alias gc='git commit'           # Git commit
alias gca='git commit --amend'  # Amend the last commit
alias gco='git checkout'       # Git checkout
alias gl='git log --oneline'   # Short git log
alias glg='git log --graph --oneline --decorate --all' # Git log with graph
alias gp='git push'             # Git push
alias gpull='git pull'          # Git pull
alias gcl='git clone'           # Git clone

# Miscellaneous
alias path='echo $PATH'   # Print the $PATH variable
alias h='history'         # Display history
alias e='exit'            # Exit the terminal session
alias zshrc='nvim ~/.zshrc' # Edit .zshrc quickly
alias v='nvim'           # Use `nvim` instead of `vim` (if installed)
alias update='sudo dnf upgrade -y'

#Added apps
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias cd="z"
alias cat="bat"


# ----- Bat (better cat) -----

export BAT_THEME=tokyonight_night

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}
source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
