#!/bin/bash

set -e

# --- Configuration ---
INSTALL_DIR="/opt/firefox"
SYMLINK_PATH="/usr/local/bin/firefox"
FIREFOX_LANG="en-US"
FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=${FIREFOX_LANG}"
TMP_TAR="/tmp/firefox-latest.tar.xz"

# Ensure cleanup on exit
trap 'rm -f "$TMP_TAR"' EXIT

# --- Functions ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_firefox_running() {
    pgrep firefox >/dev/null
}

# --- Pre-checks ---

echo "Starting Firefox Update Script..."

REQUIRED_COMMANDS=("curl" "wget" "awk" "tar" "grep" "sudo")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command_exists "$cmd"; then
        echo "Error: Required command '$cmd' not found. Please install it and try again."
        exit 1
    fi
done

# --- Get Current Installed Version ---
echo "Checking installed Firefox version in $INSTALL_DIR..."
if [ -x "$INSTALL_DIR/firefox" ]; then
    CURRENT_VERSION="$("$INSTALL_DIR/firefox" --version | awk '{print $3}')"
    echo "Currently installed version: $CURRENT_VERSION"
else
    CURRENT_VERSION="none"
    echo "No Firefox installation found in $INSTALL_DIR."
fi

# Get latest version info from Mozilla
echo "Fetching latest Firefox version from Mozilla..."
LATEST_VERSION=$(curl -s https://product-details.mozilla.org/1.0/firefox_versions.json | grep '"LATEST_FIREFOX_VERSION":' | cut -d '"' -f4)

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not retrieve latest Firefox version. Check your internet connection."
    exit 1
fi

echo "Latest Firefox version available: $LATEST_VERSION"

# --- Decide on update ---
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    if [ "$CURRENT_VERSION" != "none" ]; then
        echo "Firefox is already up to date ($CURRENT_VERSION)."
        exit 0
    fi
else
    echo "Update available: $CURRENT_VERSION → $LATEST_VERSION"
fi

# --- User confirmation ---
read -rp "Proceed with the update? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Update cancelled by user."
    exit 1
fi

# --- Firefox running check ---
if is_firefox_running; then
    echo "Warning: Firefox is currently running."
    read -rp "It’s recommended to close it first. Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Update cancelled. Please close Firefox and re-run the script."
        exit 1
    fi
    echo "Proceeding with update while Firefox may be running."
fi

# --- Download ---
echo "Downloading Firefox $LATEST_VERSION..."
if command_exists pv; then
    wget -O - "$FIREFOX_URL" | pv -pteb > "$TMP_TAR"
else
    wget -q --show-progress -O "$TMP_TAR" "$FIREFOX_URL"
fi

if [ ! -s "$TMP_TAR" ]; then
    echo "Error: Download failed or the file is empty."
    exit 1
fi
echo "Download complete."

# --- Backup and extract ---
BACKUP_DIR="${INSTALL_DIR}-backup-$(date +%Y%m%d%H%M%S)"
if [ -d "$INSTALL_DIR" ]; then
    echo "Backing up $INSTALL_DIR to $BACKUP_DIR"
    sudo mv "$INSTALL_DIR" "$BACKUP_DIR" || {
        echo "Error: Failed to backup existing installation."
        exit 1
    }
fi

echo "Extracting new Firefox to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR" 2>/dev/null || true
sudo tar -xf "$TMP_TAR" -C /opt/ || {
    echo "Error: Extraction failed. Reverting to backup if available."
    [ -d "$BACKUP_DIR" ] && sudo mv "$BACKUP_DIR" "$INSTALL_DIR"
    exit 1
}
echo "Extraction complete."

# --- Symlink ---
echo "Ensuring symlink at $SYMLINK_PATH..."
if [ ! -L "$SYMLINK_PATH" ] || [ "$(readlink -f "$SYMLINK_PATH")" != "$INSTALL_DIR/firefox" ]; then
    sudo ln -sf "$INSTALL_DIR/firefox" "$SYMLINK_PATH" || {
        echo "Error: Failed to update symlink. Consider linking manually."
    }
    echo "Symlink created or updated."
else
    echo "Symlink already correct."
fi

# --- Done ---
echo "--- Update complete! ---"
echo "Installed version:"
"$INSTALL_DIR/firefox" --version

echo
echo "If everything works, you can delete the backup:"
echo "sudo rm -rf \"$BACKUP_DIR\""
