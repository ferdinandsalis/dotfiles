#!/usr/bin/env bash

# Export script for app settings before migration
# This script exports Raycast and VS Code settings for backup

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_step() { echo -e "${BLUE}→${NC} $1"; }

# Create backup directory
BACKUP_DIR="$HOME/Base/dotfiles/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔄 Exporting app settings to: $BACKUP_DIR"
echo ""

# Export Raycast settings
export_raycast() {
    log_step "Exporting Raycast settings..."

    if [ -d "$HOME/Library/Application Support/com.raycast.macos" ]; then
        # Export Raycast preferences
        cp -R "$HOME/Library/Application Support/com.raycast.macos" "$BACKUP_DIR/raycast-support" 2>/dev/null || true
        log_info "Exported Raycast application support"
    fi

    if [ -d "$HOME/Library/Preferences" ]; then
        # Export Raycast preferences plist
        cp "$HOME/Library/Preferences/com.raycast.macos.plist" "$BACKUP_DIR/" 2>/dev/null || true
        log_info "Exported Raycast preferences"
    fi

    # List installed Raycast extensions
    if command -v ray &> /dev/null; then
        ray list-extensions > "$BACKUP_DIR/raycast-extensions.txt" 2>/dev/null || true
        log_info "Exported Raycast extensions list"
    else
        log_warn "Raycast CLI not found, skipping extensions list"
    fi

    # Export Raycast hotkeys and snippets
    if [ -f "$HOME/Library/Application Support/com.raycast.macos/hotkeys.json" ]; then
        cp "$HOME/Library/Application Support/com.raycast.macos/hotkeys.json" "$BACKUP_DIR/raycast-hotkeys.json" 2>/dev/null || true
        log_info "Exported Raycast hotkeys"
    fi

    if [ -f "$HOME/Library/Application Support/com.raycast.macos/snippets.json" ]; then
        cp "$HOME/Library/Application Support/com.raycast.macos/snippets.json" "$BACKUP_DIR/raycast-snippets.json" 2>/dev/null || true
        log_info "Exported Raycast snippets"
    fi

    # Create import instructions
    cat > "$BACKUP_DIR/raycast-import-instructions.md" << 'EOF'
# Raycast Settings Import Instructions

## On New Mac:

1. Install Raycast: `brew install --cask raycast`
2. Open Raycast and complete initial setup
3. Import settings:
   - Go to Raycast Preferences → Advanced → Import/Export
   - Select the backup files from this directory
4. Sign in to Raycast account to sync extensions
5. Review and reinstall extensions from `raycast-extensions.txt`

## Files in this backup:
- `raycast-support/` - Full application support directory
- `com.raycast.macos.plist` - Preferences file
- `raycast-extensions.txt` - List of installed extensions
- `raycast-hotkeys.json` - Custom hotkeys
- `raycast-snippets.json` - Custom snippets
EOF

    log_info "Created Raycast import instructions"
}

# Export VS Code settings
export_vscode() {
    log_step "Exporting VS Code settings..."

    if command -v code &> /dev/null; then
        # Export extensions list
        code --list-extensions > "$BACKUP_DIR/vscode-extensions.txt"
        log_info "Exported VS Code extensions list"

        # Export settings
        if [ -f "$HOME/Library/Application Support/Code/User/settings.json" ]; then
            cp "$HOME/Library/Application Support/Code/User/settings.json" "$BACKUP_DIR/vscode-settings.json"
            log_info "Exported VS Code settings"
        fi

        # Export keybindings
        if [ -f "$HOME/Library/Application Support/Code/User/keybindings.json" ]; then
            cp "$HOME/Library/Application Support/Code/User/keybindings.json" "$BACKUP_DIR/vscode-keybindings.json"
            log_info "Exported VS Code keybindings"
        fi

        # Export snippets
        if [ -d "$HOME/Library/Application Support/Code/User/snippets" ]; then
            cp -R "$HOME/Library/Application Support/Code/User/snippets" "$BACKUP_DIR/vscode-snippets"
            log_info "Exported VS Code snippets"
        fi

        # Create install script for new machine
        cat > "$BACKUP_DIR/vscode-install-extensions.sh" << 'EOF'
#!/usr/bin/env bash
# Install VS Code extensions from backup

if ! command -v code &> /dev/null; then
    echo "VS Code CLI not found. Please install VS Code first."
    exit 1
fi

echo "Installing VS Code extensions..."
while IFS= read -r extension; do
    echo "Installing: $extension"
    code --install-extension "$extension"
done < vscode-extensions.txt

echo "✅ All extensions installed!"
echo ""
echo "Next steps:"
echo "1. Copy vscode-settings.json to ~/Library/Application Support/Code/User/settings.json"
echo "2. Copy vscode-keybindings.json to ~/Library/Application Support/Code/User/keybindings.json"
echo "3. Copy vscode-snippets/* to ~/Library/Application Support/Code/User/snippets/"
EOF
        chmod +x "$BACKUP_DIR/vscode-install-extensions.sh"
        log_info "Created VS Code extension install script"

    else
        log_warn "VS Code CLI not found, skipping VS Code export"
    fi
}

# Export 1Password CLI configuration
export_1password() {
    log_step "Checking 1Password CLI configuration..."

    if command -v op &> /dev/null; then
        # Check if signed in
        if op account list &> /dev/null; then
            op account list > "$BACKUP_DIR/1password-accounts.txt"
            log_info "Exported 1Password account list"

            cat > "$BACKUP_DIR/1password-setup.md" << 'EOF'
# 1Password CLI Setup

## On New Mac:

1. Install 1Password and 1Password CLI:
   ```bash
   brew install --cask 1password 1password-cli
   ```

2. Sign in to your accounts listed in `1password-accounts.txt`

3. Enable CLI integration:
   - Open 1Password → Settings → Developer
   - Enable "Integrate with 1Password CLI"
   - Enable "Use the SSH agent"

4. Configure git to use 1Password for signing:
   ```bash
   git config --global gpg.format ssh
   git config --global user.signingkey "YOUR_SSH_KEY_FROM_1PASSWORD"
   git config --global commit.gpgsign true
   ```
EOF
            log_info "Created 1Password setup instructions"
        else
            log_warn "1Password CLI not signed in"
        fi
    else
        log_warn "1Password CLI not installed"
    fi
}

# Export SSH configuration (not keys, just config)
export_ssh_config() {
    log_step "Exporting SSH configuration..."

    if [ -f "$HOME/.ssh/config" ]; then
        cp "$HOME/.ssh/config" "$BACKUP_DIR/ssh-config"
        log_info "Exported SSH config (keys not included for security)"

        cat > "$BACKUP_DIR/ssh-setup.md" << 'EOF'
# SSH Setup Instructions

## On New Mac:

1. Copy `ssh-config` to `~/.ssh/config`
2. Set correct permissions:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/config
   ```

3. Generate new SSH keys or restore from secure backup:
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```

4. Add to SSH agent:
   ```bash
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```

5. Add public key to GitHub, GitLab, etc.

Note: For security, SSH private keys are NOT included in this backup.
Transfer them separately via secure method or use 1Password SSH agent.
EOF
        log_info "Created SSH setup instructions"
    fi
}

# Main export flow
main() {
    export_raycast
    echo ""
    export_vscode
    echo ""
    export_1password
    echo ""
    export_ssh_config
    echo ""

    # Create master README
    cat > "$BACKUP_DIR/README.md" << EOF
# App Settings Backup
Created: $(date)

## Contents:
- Raycast settings and extensions
- VS Code settings, extensions, and snippets
- 1Password CLI configuration
- SSH configuration (no keys)

## Quick Setup on New Mac:

1. Run the main dotfiles setup:
   \`\`\`bash
   cd ~/Base/dotfiles
   ./setup.sh
   \`\`\`

2. Import app settings from this backup

3. Grant necessary permissions (see setup-permissions.sh)

## Individual app instructions:
- See \`raycast-import-instructions.md\`
- See \`vscode-install-extensions.sh\`
- See \`1password-setup.md\`
- See \`ssh-setup.md\`
EOF

    log_info "Created master README"

    echo ""
    echo "✨ Export complete!"
    echo "📁 Backup location: $BACKUP_DIR"
    echo ""
    echo "📋 Next steps:"
    echo "1. Review the exported settings in the backup directory"
    echo "2. Copy this backup to your new Mac or cloud storage"
    echo "3. Run setup-permissions.sh after installing apps on new Mac"
}

main "$@"