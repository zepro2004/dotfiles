#!/bin/bash
set -e

echo "Starting install of zsh environment dependencies..."

# 1. Check if brew is installed, if not, install Homebrew (Linux version)
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zprofile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

# 2. Brew update & upgrade
brew update
brew upgrade

# 3. Install main tools from brew
brew install \
  fzf \
  zoxide \
  fd \
  eza \
  bat \
  zsh-autosuggestions \
  zsh-syntax-highlighting

# 4. oh-my-zsh installation (if not installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed."
fi

# 5. fzf-git installation (no brew package, manual clone)
if [ ! -d "$HOME/fzf-git.sh" ]; then
  echo "Installing fzf-git..."
  git clone https://github.com/junegunn/fzf-git.sh.git ~/fzf-git.sh
else
  echo "fzf-git already installed."
fi

# 6. sdkman installation (if not installed)
if [ ! -d "$HOME/.sdkman" ]; then
  echo "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
else
  echo "SDKMAN already installed."
fi

echo "Done installing all dependencies!"

echo "You may need to restart your shell or source your .zshrc to apply changes."
