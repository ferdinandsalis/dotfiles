#!/usr/bin/env bash

# macOS Permissions Setup Helper
# This script guides you through granting necessary permissions to apps after installation

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_step() { echo -e "${BLUE}→${NC} $1"; }
log_important() { echo -e "${MAGENTA}⭐${NC} $1"; }

echo "🔐 macOS Permissions Setup Helper"
echo "=================================="
echo ""
echo "This script will guide you through granting permissions to your apps."
echo "Many permissions require manual approval in System Settings."
echo ""
read -p "Press Enter to continue..."
echo ""

# Function to open System Settings to specific pane
open_settings() {
    local pane=$1
    echo "Opening System Settings → $pane..."
    open "x-apple.systempreferences:com.apple.preference.$pane"
}

# Check if an app is installed
check_app() {
    local app_name=$1
    if [ -d "/Applications/$app_name.app" ]; then
        return 0
    else
        return 1
    fi
}

# Karabiner-Elements permissions
setup_karabiner() {
    if check_app "Karabiner-Elements"; then
        echo ""
        log_important "Karabiner-Elements Permissions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        # Launch Karabiner to trigger permission prompts
        log_step "Launching Karabiner-Elements..."
        open -a "Karabiner-Elements" 2>/dev/null || true
        sleep 2

        echo ""
        log_warn "Grant these permissions in System Settings:"
        echo ""
        echo "1. Privacy & Security → Accessibility"
        echo "   ✓ Allow Karabiner-Elements"
        echo "   ✓ Allow karabiner_grabber"
        echo "   ✓ Allow karabiner_observer"
        echo ""
        echo "2. Privacy & Security → Input Monitoring"
        echo "   ✓ Allow Karabiner-EventViewer"
        echo "   ✓ Allow karabiner_grabber"
        echo ""

        read -p "Press Enter to open Privacy & Security settings..."
        open_settings "security"

        echo ""
        read -p "Press Enter after granting all Karabiner permissions..."

        # Set to launch at login
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Karabiner-Elements.app", hidden:true}' 2>/dev/null || true

        log_info "Karabiner-Elements setup complete"
    else
        log_warn "Karabiner-Elements not installed, skipping"
    fi
}

# Raycast permissions
setup_raycast() {
    if check_app "Raycast"; then
        echo ""
        log_important "Raycast Permissions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        log_step "Launching Raycast..."
        open -a "Raycast" 2>/dev/null || true
        sleep 2

        echo ""
        log_warn "Grant these permissions if prompted:"
        echo ""
        echo "1. Privacy & Security → Accessibility"
        echo "   ✓ Allow Raycast"
        echo ""
        echo "2. Privacy & Security → Screen Recording (if using window management)"
        echo "   ✓ Allow Raycast"
        echo ""

        read -p "Press Enter to continue..."

        log_info "Raycast setup complete"
        log_step "Remember to set your Raycast hotkey (default: ⌘ Space)"
    else
        log_warn "Raycast not installed, skipping"
    fi
}

# Terminal/Ghostty permissions
setup_terminal() {
    echo ""
    log_important "Terminal Emulator Permissions"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo ""
    log_warn "Grant these permissions for your terminal:"
    echo ""
    echo "1. Privacy & Security → Full Disk Access"

    if check_app "Ghostty"; then
        echo "   ✓ Allow Ghostty"
    fi

    echo "   ✓ Allow Terminal"
    echo "   ✓ Allow iTerm (if installed)"
    echo ""
    echo "2. Privacy & Security → Developer Tools"
    echo "   ✓ Allow your terminal apps"
    echo ""

    read -p "Press Enter to open Privacy & Security settings..."
    open_settings "security"

    echo ""
    read -p "Press Enter after granting terminal permissions..."

    log_info "Terminal permissions setup complete"
}

# VS Code permissions
setup_vscode() {
    if check_app "Visual Studio Code"; then
        echo ""
        log_important "Visual Studio Code Permissions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        echo ""
        log_warn "Grant these permissions if needed:"
        echo ""
        echo "1. Privacy & Security → Full Disk Access"
        echo "   ✓ Allow Code (for certain extensions)"
        echo ""
        echo "2. Privacy & Security → Accessibility"
        echo "   ✓ Allow Code (for certain extensions like VIM)"
        echo ""

        read -p "Press Enter to continue..."

        log_info "VS Code permissions setup complete"
    else
        log_warn "Visual Studio Code not installed, skipping"
    fi
}

# 1Password permissions
setup_1password() {
    if check_app "1Password"; then
        echo ""
        log_important "1Password Permissions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        log_step "Launching 1Password..."
        open -a "1Password" 2>/dev/null || true
        sleep 2

        echo ""
        log_warn "Configure these settings:"
        echo ""
        echo "1. Sign in to your account"
        echo ""
        echo "2. Enable browser integration:"
        echo "   Settings → Browser → Install browser extensions"
        echo ""
        echo "3. Enable CLI integration:"
        echo "   Settings → Developer → Integrate with 1Password CLI"
        echo ""
        echo "4. Enable SSH agent:"
        echo "   Settings → Developer → Use the SSH agent"
        echo ""
        echo "5. Enable Touch ID:"
        echo "   Settings → Security → Unlock with Touch ID"
        echo ""

        read -p "Press Enter after configuring 1Password..."

        log_info "1Password setup complete"
    else
        log_warn "1Password not installed, skipping"
    fi
}

# Screen recording permissions for Kap
setup_kap() {
    if check_app "Kap"; then
        echo ""
        log_important "Kap Screen Recorder Permissions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        echo ""
        log_warn "Grant these permissions:"
        echo ""
        echo "1. Privacy & Security → Screen Recording"
        echo "   ✓ Allow Kap"
        echo ""
        echo "2. Privacy & Security → Accessibility"
        echo "   ✓ Allow Kap"
        echo ""

        read -p "Press Enter to continue..."

        log_info "Kap setup complete"
    else
        log_warn "Kap not installed, skipping"
    fi
}

# Ice/Bartender menu bar permissions
setup_menubar() {
    if check_app "Ice"; then
        echo ""
        log_important "Ice (Menu Bar Manager) Permissions"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        log_step "Launching Ice..."
        open -a "Ice" 2>/dev/null || true
        sleep 2

        echo ""
        log_warn "Grant these permissions:"
        echo ""
        echo "1. Privacy & Security → Accessibility"
        echo "   ✓ Allow Ice"
        echo ""

        read -p "Press Enter to continue..."

        log_info "Ice setup complete"
    fi
}

# General macOS settings
setup_general() {
    echo ""
    log_important "General macOS Security Settings"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo ""
    log_step "Recommended security settings:"
    echo ""
    echo "1. Enable FileVault:"
    echo "   System Settings → Privacy & Security → FileVault → Turn On"
    echo ""
    echo "2. Enable Firewall:"
    echo "   System Settings → Network → Firewall → Turn On"
    echo ""
    echo "3. Configure Touch ID for sudo (optional):"
    echo "   Add 'auth sufficient pam_tid.so' to /etc/pam.d/sudo"
    echo ""
    echo "4. Set up Time Machine backups:"
    echo "   System Settings → General → Time Machine"
    echo ""

    read -p "Press Enter to continue..."
}

# Check all permissions
check_permissions() {
    echo ""
    log_important "Permission Status Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check for common permission issues
    log_step "Checking accessibility permissions..."
    echo "Apps with accessibility access:"
    sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
        "SELECT client FROM access WHERE service='kTCCServiceAccessibility' AND allowed=1;" 2>/dev/null || \
        log_warn "Cannot check (need root access)"

    echo ""
    log_step "Login items:"
    osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || \
        log_warn "Cannot check login items"

    echo ""
}

# Main flow
main() {
    setup_karabiner
    setup_raycast
    setup_terminal
    setup_vscode
    setup_1password
    setup_kap
    setup_menubar
    setup_general
    check_permissions

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "✨ Permission setup complete!"
    echo ""
    echo "📋 Final checklist:"
    echo "□ Karabiner-Elements working (test Caps Lock → Escape)"
    echo "□ Raycast hotkey configured"
    echo "□ Terminal has full disk access"
    echo "□ 1Password browser extension installed"
    echo "□ FileVault enabled"
    echo "□ Time Machine configured"
    echo ""
    echo "💡 Tips:"
    echo "• Restart apps after granting permissions"
    echo "• Some permissions only take effect after logout/login"
    echo "• Check System Settings → Privacy & Security for any pending approvals"
    echo ""
}

main "$@"