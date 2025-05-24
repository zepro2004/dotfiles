#!/bin/bash

set -e

# --- Configuration ---
INSTALL_DIR="/opt/firefox"
SYMLINK_PATH="/usr/local/bin/firefox"
FIREFOX_LANG="en-US"
FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=${FIREFOX_LANG}"
TMP_TAR="/tmp/firefox-latest.tar.xz"

# --- Command line options ---
AUTO_MODE=false
if [[ "$1" == "--auto" || "$1" == "-y" ]]; then
    AUTO_MODE=true
fi

# --- Functions ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_firefox_running() {
    pgrep firefox >/dev/null
}

# --- Pre-checks ---

echo "Starting Firefox Update Script..."

REQUIRED_COMMANDS=("curl" "wget" "awk" "tar" "grep")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command_exists "$cmd"; then
        echo "Error: Required command '$cmd' not found. Please install it and try again."
        exit 1
    fi
done

# --- Get Current Installed Version ---
echo "Checking installed Firefox version in $INSTALL_DIR..."
if [ -x "$INSTALL_DIR/firefox" ]; then
    CURRENT_VERSION=$("$INSTALL_DIR/firefox" --version | awk '{print $3}')
    echo "Currently installed version: $CURRENT_VERSION"
else
    CURRENT_VERSION="none"
    echo "No Firefox installation found in $INSTALL_DIR."
fi

# --- Get Latest Firefox Version ---
echo "Fetching latest Firefox version from Mozilla..."
LATEST_VERSION=$(curl -s https://product-details.mozilla.org/1.0/firefox_versions.json | grep '"LATEST_FIREFOX_VERSION":' | cut -d '"' -f4)

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not retrieve latest Firefox version. Please check your connection."
    exit 1
fi

echo "Latest Firefox version: $LATEST_VERSION"

# --- Check if update is needed ---
if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
    echo "Firefox is already up to date."
    exit 0
fi

echo "Update available: $CURRENT_VERSION -> $LATEST_VERSION"

# --- Confirm update (if not in auto mode) ---
if ! $AUTO_MODE; then
    read -p "Do you want to proceed with the update? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Update cancelled by user."
        exit 1
    fi
else
    echo "Auto mode enabled: Proceeding without confirmation..."
fi

# --- Check if Firefox is running ---
if is_firefox_running; then
    if ! $AUTO_MODE; then
        echo "Warning: Firefox is currently running."
        read -p "It is recommended to close Firefox. Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Update cancelled."
            exit 1
        fi
    else
        echo "Warning: Firefox is running. Proceeding anyway due to auto mode."
    fi
fi

# --- Download and extract ---
echo "Downloading Firefox $LATEST_VERSION..."
if command_exists pv; then
    wget -O - "$FIREFOX_URL" | pv -pteb > "$TMP_TAR"
else
    wget -q --show-progress -O "$TMP_TAR" "$FIREFOX_URL"
fi

if [ ! -s "$TMP_TAR" ]; then
    echo "Error: Download failed or file is empty."
    exit 1
fi

# Backup and replace
BACKUP_DIR="${INSTALL_DIR}-backup-$(date +%Y%m%d%H%M%S)"
if [ -d "$INSTALL_DIR" ]; then
    echo "Backing up to $BACKUP_DIR"
    mv "$INSTALL_DIR" "$BACKUP_DIR"
fi

echo "Extracting new Firefox to /opt..."
rm -rf "$INSTALL_DIR" 2>/dev/null || true
tar -xf "$TMP_TAR" -C /opt/

# Clean up
rm -f "$TMP_TAR"

# Ensure symlink
echo "Ensuring symlink at $SYMLINK_PATH..."
if [ ! -L "$SYMLINK_PATH" ] || [ "$(readlink -f "$SYMLINK_PATH")" != "$INSTALL_DIR/firefox" ]; then
    ln -sf "$INSTALL_DIR/firefox" "$SYMLINK_PATH"
    echo "Symlink updated."
else
    echo "Symlink already correct."
fi

echo "--- Firefox update complete ---"
"$INSTALL_DIR/firefox" --version

if ! $AUTO_MODE; then
    echo ""
    echo "You can remove the backup manually when you're sure everything works:"
    echo "  sudo rm -rf $BACKUP_DIR"
fi
