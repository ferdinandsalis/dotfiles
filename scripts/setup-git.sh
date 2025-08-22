#!/usr/bin/env bash

# Git configuration script
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

echo "🔧 Git Configuration Setup"
echo ""

# Load environment variables if available
if [[ -f "$HOME/.dotfiles/.env" ]]; then
    set -a
    source "$HOME/.dotfiles/.env"
    set +a
elif [[ -f "$HOME/.env" ]]; then
    set -a
    source "$HOME/.env"
    set +a
fi

# Generate git config from template if available
generate_from_template() {
    if [[ -f "$HOME/.dotfiles/git/gitconfig.template" ]] && [[ -f "$HOME/.dotfiles/.env" ]]; then
        log_step "Generating git config from template..."
        
        # Copy template
        cp "$HOME/.dotfiles/git/gitconfig.template" "$HOME/.dotfiles/git/gitconfig"
        
        # Replace placeholders with environment variables
        sed -i '' "s/{{DOTFILES_GIT_NAME}}/${DOTFILES_GIT_NAME}/g" "$HOME/.dotfiles/git/gitconfig"
        sed -i '' "s/{{DOTFILES_GIT_EMAIL}}/${DOTFILES_GIT_EMAIL}/g" "$HOME/.dotfiles/git/gitconfig"
        sed -i '' "s/{{DOTFILES_GITHUB_USER}}/${DOTFILES_GITHUB_USER}/g" "$HOME/.dotfiles/git/gitconfig"
        
        log_info "Generated git config from template"
        return 0
    fi
    return 1
}

# Check if git config already exists
check_existing() {
    local name=$(git config --global user.name 2>/dev/null || echo "")
    local email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$name" ]] && [[ -n "$email" ]]; then
        log_info "Existing Git configuration found:"
        echo "  Name: $name"
        echo "  Email: $email"
        echo ""
        read -p "Update configuration? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing configuration"
            return 1
        fi
    fi
    return 0
}

# Configure git user
configure_user() {
    read -p "Enter your full name: " name
    if [[ -z "$name" ]]; then
        log_error "Name is required"
        exit 1
    fi
    
    read -p "Enter your email: " email
    if [[ -z "$email" ]]; then
        log_error "Email is required"
        exit 1
    fi
    
    log_step "Setting Git user configuration..."
    git config --global user.name "$name"
    git config --global user.email "$email"
    log_info "Git user configured"
}

# Configure git settings
configure_settings() {
    log_step "Configuring Git settings..."
    
    # Core settings
    git config --global init.defaultBranch main
    git config --global core.editor "hx"  # Use Helix as default editor
    git config --global core.autocrlf input
    git config --global core.ignorecase false
    
    # Merge and rebase settings
    git config --global merge.conflictstyle diff3
    git config --global pull.rebase true
    git config --global rebase.autoStash true
    
    # Push settings
    git config --global push.default current
    git config --global push.autoSetupRemote true
    
    # Diff settings
    git config --global diff.colorMoved zebra
    
    # Alias settings (useful shortcuts)
    git config --global alias.st "status -sb"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.cm "commit -m"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.visual "!gitk"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    log_info "Git settings configured"
}

# Configure GitHub CLI if installed
configure_github_cli() {
    if command -v gh &> /dev/null; then
        echo ""
        read -p "Configure GitHub CLI? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_step "Configuring GitHub CLI..."
            gh auth login || log_warn "GitHub CLI configuration cancelled"
        fi
    else
        log_warn "GitHub CLI (gh) not found - skipping"
    fi
}

# Show configuration
show_config() {
    echo ""
    log_info "Current Git configuration:"
    echo ""
    echo "User:"
    echo "  Name: $(git config --global user.name)"
    echo "  Email: $(git config --global user.email)"
    echo ""
    echo "Core:"
    echo "  Editor: $(git config --global core.editor)"
    echo "  Default branch: $(git config --global init.defaultBranch)"
    echo ""
    echo "Aliases configured:"
    git config --get-regexp alias | sed 's/alias./ - /g'
}

# Main flow
main() {
    # Try to generate from template first
    if generate_from_template; then
        log_info "Using configuration from .env file"
    elif check_existing; then
        configure_user
    fi
    
    configure_settings
    configure_github_cli
    show_config
    
    echo ""
    log_info "Git configuration complete!"
    echo ""
    echo "Next steps:"
    echo "1. Test git with: git config --list"
    echo "2. Clone a repository to test your setup"
    echo "3. Make sure your SSH keys are configured: ./scripts/setup-ssh.sh"
}

main "$@"