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
  zsh-syntax-highlighting \
  ripgrep \
  tmux \
  lazygit \
  gh \
  btop \
  delta \
  duf \
  zsh-completions \
  docker \
  docker-compose \
  jq \
  tree \
  tldr

# Add zsh-completions init to .zshrc if missing
if ! grep -q "zsh-completions" ~/.zshrc; then
  echo "" >> ~/.zshrc
  echo "# zsh-completions initialization" >> ~/.zshrc
  echo 'if type brew &>/dev/null; then' >> ~/.zshrc
  echo '  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH' >> ~/.zshrc
  echo '  autoload -Uz compinit' >> ~/.zshrc
  echo '  compinit' >> ~/.zshrc
  echo 'fi' >> ~/.zshrc
fi

# Fix permissions to avoid zsh compinit warnings
chmod go-w "$(brew --prefix)/share"
chmod -R go-w "$(brew --prefix)/share/zsh"


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

# 7. fzf-tab installation
if [ ! -d "$HOME/.zsh/plugins/fzf-tab" ]; then
  echo "Installing fzf-tab..."
  mkdir -p ~/.zsh/plugins
  git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/plugins/fzf-tab
else
  echo "fzf-tab already installed."
fi

# 8. Add plugin sourcing to .zshrc if not present
if ! grep -q "fzf-tab" ~/.zshrc; then
  echo "" >> ~/.zshrc
  echo "# fzf-tab plugin" >> ~/.zshrc
  echo "source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" >> ~/.zshrc
fi

# 9. Docker post-install steps (Linux)
# Add current user to docker group if not already
if ! groups $USER | grep -q docker; then
  echo "Adding $USER to docker group (you may need to log out and back in)..."
  sudo groupadd docker 2>/dev/null || true
  sudo usermod -aG docker $USER
fi

# 10. Install distrobox
if ! command -v distrobox >/dev/null 2>&1; then
  echo "Installing distrobox..."
  brew install distrobox
else
  echo "distrobox already installed."
fi

# 10. Install distrobox
if ! command -v distrobox >/dev/null 2>&1; then
  echo "Installing distrobox..."
  brew install distrobox
else
  echo "distrobox already installed."
fi

# 11. Initialize distrobox (create a default container if you want)
# You can comment this out if you want to create manually later
# Example: Arch-based container
# distrobox-create --name arch-box --image archlinux:latest --yes
# distrobox-enter arch-box


echo "Done installing all dependencies!"

echo ""

echo "👉 You may need to restart your shell or run: source ~/.zshrc"

echo ""

echo "👉 You may also need to log out and back in for docker group changes to apply."

echo ""

sleep 2

echo "Enjoy your zsh environment! 🚀"
