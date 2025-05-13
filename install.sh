# ~/dotfiles/install.sh
#!/bin/bash
BASEDIR=$(dirname "$0") # Gets the directory where the script is located

# Create symlinks
ln -sf "$BASEDIR/bashrc" ~/.bashrc
mkdir -p ~/.config/nvim
ln -sf "$BASEDIR/.config/nvim/init.vim" ~/.config/nvim/init.vim
# Add more links here...
mkdir -p ~/Documents/AutoHotkey # Ensure target directory exists
ln -sf "$BASEDIR/autohotkey/MyScript.ahk" ~/Documents/AutoHotkey/MyScript.ahk

echo "Dotfiles symlinked!"
