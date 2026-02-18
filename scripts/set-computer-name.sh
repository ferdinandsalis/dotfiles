#!/usr/bin/env bash

# Set computer name from .env configuration
set -e

# Load environment variables
if [[ -f "$HOME/Base/dotfiles/.env" ]]; then
    set -a
    source "$HOME/Base/dotfiles/.env"
    set +a
else
    echo "Error: .env file not found at $HOME/Base/dotfiles/.env"
    exit 1
fi

# Check if variables are set
if [[ -z "$DOTFILES_COMPUTER_NAME" ]] || [[ -z "$DOTFILES_HOSTNAME" ]]; then
    echo "Error: DOTFILES_COMPUTER_NAME or DOTFILES_HOSTNAME not set in .env"
    exit 1
fi

echo "Setting computer name to: $DOTFILES_COMPUTER_NAME"
echo "Setting hostname to: $DOTFILES_HOSTNAME"
echo ""

# Create LocalHostName without dots (required by macOS)
LOCAL_HOSTNAME=$(echo "$DOTFILES_HOSTNAME" | sed 's/\./-/g')

# Set the computer names (requires sudo)
sudo scutil --set ComputerName "$DOTFILES_COMPUTER_NAME"
sudo scutil --set HostName "$DOTFILES_HOSTNAME"
sudo scutil --set LocalHostName "$LOCAL_HOSTNAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$DOTFILES_COMPUTER_NAME"

echo ""
echo "✅ Computer name updated successfully!"
echo "   ComputerName: $(scutil --get ComputerName)"
echo "   HostName: $(scutil --get HostName)"
echo "   LocalHostName: $(scutil --get LocalHostName)"