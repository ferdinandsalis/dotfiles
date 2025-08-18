#!/usr/bin/env bash

# Health check script to verify dotfiles installation
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_fail() { echo -e "${RED}✗${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_section() { echo -e "\n${BLUE}$1${NC}"; }

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Check command exists
check_command() {
    local cmd=$1
    local required=${2:-true}
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$cmd is installed"
        ((PASSED++))
        return 0
    else
        if [[ "$required" == "true" ]]; then
            log_fail "$cmd is not installed"
            ((FAILED++))
        else
            log_warn "$cmd is not installed (optional)"
            ((WARNINGS++))
        fi
        return 1
    fi
}

# Check symlink exists and is valid
check_symlink() {
    local link=$1
    local target=$2
    
    if [[ -L "$link" ]]; then
        if [[ -e "$link" ]]; then
            log_success "$link is properly linked"
            ((PASSED++))
            return 0
        else
            log_fail "$link is broken"
            ((FAILED++))
            return 1
        fi
    elif [[ -e "$link" ]]; then
        log_warn "$link exists but is not a symlink"
        ((WARNINGS++))
        return 1
    else
        log_fail "$link does not exist"
        ((FAILED++))
        return 1
    fi
}

# Check file exists
check_file() {
    local file=$1
    
    if [[ -f "$file" ]]; then
        log_success "$file exists"
        ((PASSED++))
        return 0
    else
        log_fail "$file does not exist"
        ((FAILED++))
        return 1
    fi
}

# Check directory exists
check_directory() {
    local dir=$1
    
    if [[ -d "$dir" ]]; then
        log_success "$dir exists"
        ((PASSED++))
        return 0
    else
        log_fail "$dir does not exist"
        ((FAILED++))
        return 1
    fi
}

# Check git configuration
check_git_config() {
    local key=$1
    local value=$(git config --global "$key" 2>/dev/null || echo "")
    
    if [[ -n "$value" ]]; then
        log_success "git config $key is set: $value"
        ((PASSED++))
        return 0
    else
        log_fail "git config $key is not set"
        ((FAILED++))
        return 1
    fi
}

# Main health check
main() {
    echo "🏥 Dotfiles Health Check"
    echo "========================"
    
    # System detection
    log_section "System Information:"
    echo "  OS: $(uname -s)"
    echo "  Architecture: $(uname -m)"
    echo "  Shell: $SHELL"
    
    # Core tools
    log_section "Core Tools:"
    check_command git
    check_command brew
    check_command curl
    check_command wget false
    
    # Shell
    log_section "Shell:"
    check_command fish
    check_command zsh
    check_command bash
    if [[ -f "/opt/homebrew/bin/fish" ]] || [[ -f "/usr/local/bin/fish" ]]; then
        if grep -q "fish" /etc/shells; then
            log_success "Fish is in /etc/shells"
            ((PASSED++))
        else
            log_fail "Fish is not in /etc/shells"
            ((FAILED++))
        fi
    fi
    
    # Development tools
    log_section "Development Tools:"
    check_command mise false
    check_command node false
    check_command python3
    check_command pip3 false
    check_command cargo false
    check_command rustc false
    
    # CLI tools
    log_section "CLI Tools:"
    check_command eza false
    check_command bat false
    check_command rg false  # ripgrep command
    check_command fd false
    check_command fzf false
    check_command zoxide false
    check_command gh false
    check_command lazygit false
    check_command lazydocker false
    check_command btop false
    check_command hx false  # helix command
    
    # Dotfiles symlinks
    log_section "Dotfiles Symlinks:"
    check_symlink ~/.gitconfig
    check_symlink ~/.config/fish
    check_symlink ~/.config/helix
    check_symlink ~/.config/btop
    check_symlink ~/.config/bat
    check_symlink ~/.config/lazygit
    check_symlink ~/.Brewfile
    
    # Configuration files
    log_section "Configuration Files:"
    check_file ~/.dotfiles/install.conf.yaml
    check_file ~/.dotfiles/setup.sh
    
    # Directories
    log_section "Directories:"
    check_directory ~/.dotfiles
    check_directory ~/.ssh
    check_directory ~/.local/bin
    check_directory ~/projects
    check_directory ~/work
    
    # Git configuration
    log_section "Git Configuration:"
    check_git_config user.name
    check_git_config user.email
    check_git_config init.defaultBranch
    
    # SSH keys
    log_section "SSH Keys:"
    if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]] || [[ -f ~/.ssh/id_ed25519_github ]]; then
        log_success "SSH keys found"
        ((PASSED++))
    else
        log_warn "No SSH keys found"
        ((WARNINGS++))
    fi
    
    # Summary
    log_section "Summary:"
    echo "  Passed: $PASSED"
    echo "  Failed: $FAILED"
    echo "  Warnings: $WARNINGS"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}✨ All critical checks passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some checks failed. Please review and fix the issues above.${NC}"
        exit 1
    fi
}

main "$@"