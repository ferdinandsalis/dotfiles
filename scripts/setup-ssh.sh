#!/usr/bin/env bash

# SSH key generation and setup script
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

echo "🔐 SSH Key Setup"
echo ""

# Get user information
read -p "Enter your email for SSH keys: " email
if [[ -z "$email" ]]; then
    log_error "Email is required"
    exit 1
fi

# Create SSH directory if it doesn't exist
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh

# Generate GitHub SSH key
generate_github_key() {
    local key_file="$HOME/.ssh/id_ed25519_github"
    
    if [[ -f "$key_file" ]]; then
        log_warn "GitHub SSH key already exists at $key_file"
        read -p "Overwrite existing key? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    log_step "Generating GitHub SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    
    # Add to keychain on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_step "Adding key to macOS keychain..."
        ssh-add --apple-use-keychain "$key_file"
    else
        ssh-add "$key_file"
    fi
    
    log_info "GitHub SSH key generated"
    echo ""
    echo "📋 Add this public key to GitHub (https://github.com/settings/keys):"
    echo ""
    cat "${key_file}.pub"
    echo ""
    
    # Copy to clipboard on macOS
    if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
        cat "${key_file}.pub" | pbcopy
        log_info "Public key copied to clipboard!"
    fi
}

# Generate personal SSH key
generate_personal_key() {
    local key_file="$HOME/.ssh/id_ed25519"
    
    if [[ -f "$key_file" ]]; then
        log_warn "Personal SSH key already exists at $key_file"
        read -p "Overwrite existing key? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    log_step "Generating personal SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    
    # Add to keychain on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        ssh-add --apple-use-keychain "$key_file"
    else
        ssh-add "$key_file"
    fi
    
    log_info "Personal SSH key generated"
}

# Test GitHub connection
test_github() {
    echo ""
    read -p "Test GitHub SSH connection? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_step "Testing GitHub connection..."
        ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && \
            log_info "GitHub connection successful!" || \
            log_warn "GitHub connection failed - make sure to add your public key to GitHub"
    fi
}

# Main flow
main() {
    echo "Select keys to generate:"
    echo "1) GitHub only"
    echo "2) Personal only"
    echo "3) Both"
    echo ""
    read -p "Choice (1-3): " choice
    
    case $choice in
        1)
            generate_github_key
            ;;
        2)
            generate_personal_key
            ;;
        3)
            generate_github_key
            generate_personal_key
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
    
    # Test connection
    test_github
    
    echo ""
    log_info "SSH setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Add public keys to relevant services"
    echo "2. Test connections with: ssh -T git@github.com"
    echo "3. Review ~/.ssh/config for any custom settings"
}

main "$@"