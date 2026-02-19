#!/usr/bin/env bash

# Health check script to verify dotfiles installation
# Note: Don't use 'set -e' as we want to run all checks even if some fail

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

# Detect Homebrew prefix
detect_brew_prefix() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "/opt/homebrew"
    else
        echo "/usr/local"
    fi
}

BREW_PREFIX=$(detect_brew_prefix)

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

# Check command with version
check_command_version() {
    local cmd=$1
    local version_flag=${2:---version}
    local required=${3:-false}
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd $version_flag 2>&1 | head -1)
        log_success "$cmd is installed: $version"
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
    local expected_target=${2:-}
    
    if [[ -L "$link" ]]; then
        if [[ -e "$link" ]]; then
            if [[ -n "$expected_target" ]]; then
                local actual_target=$(readlink "$link")
                if [[ "$actual_target" == *"$expected_target"* ]]; then
                    log_success "$link → $expected_target"
                    ((PASSED++))
                else
                    log_warn "$link points to $actual_target, expected $expected_target"
                    ((WARNINGS++))
                fi
            else
                log_success "$link is properly linked"
                ((PASSED++))
            fi
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

# Check if Fish is default shell
check_default_shell() {
    local current_shell=$(basename "$SHELL")
    local expected_shell=${1:-fish}
    
    if [[ "$current_shell" == "$expected_shell" ]]; then
        log_success "Default shell is $expected_shell"
        ((PASSED++))
        return 0
    else
        log_warn "Default shell is $current_shell, not $expected_shell"
        ((WARNINGS++))
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
    echo "  Homebrew prefix: $BREW_PREFIX"
    echo "  Shell: $SHELL"
    echo "  User: $USER"
    echo "  Home: $HOME"
    
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
    
    # Check if Fish is in /etc/shells
    if [[ -f "$BREW_PREFIX/bin/fish" ]]; then
        if grep -q "$BREW_PREFIX/bin/fish" /etc/shells; then
            log_success "Fish is in /etc/shells"
            ((PASSED++))
        else
            log_warn "Fish is not in /etc/shells (run: echo $BREW_PREFIX/bin/fish | sudo tee -a /etc/shells)"
            ((WARNINGS++))
        fi
    fi
    
    # Check default shell
    check_default_shell fish
    
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
    check_command rg false  # ripgrep
    check_command fd false
    check_command fzf false
    check_command zoxide false
    check_command gh false
    check_command lazygit false
    check_command lazydocker false
    check_command btop false
    check_command hx false  # helix
    check_command delta false
    
    # Dotfiles symlinks
    log_section "Dotfiles Symlinks:"
    check_symlink ~/.gitconfig "Base/dotfiles/git/gitconfig"
    check_symlink ~/.config/fish "Base/dotfiles/fish"
    check_symlink ~/.config/helix "Base/dotfiles/helix"
    check_symlink ~/.config/btop "Base/dotfiles/btop"
    check_symlink ~/.config/bat "Base/dotfiles/bat"
    check_symlink ~/.config/lazygit "Base/dotfiles/lazygit"
    check_symlink ~/.config/ghostty "Base/dotfiles/ghostty"
    check_symlink ~/.Brewfile "Base/dotfiles/homebrew/Brewfile"
    
    # Configuration files
    log_section "Configuration Files:"
    check_file ~/Base/dotfiles/install.conf.yaml
    check_file ~/Base/dotfiles/setup.sh
    check_file ~/Base/dotfiles/.env.example
    
    # Check for .env file
    if [[ -f ~/Base/dotfiles/.env ]]; then
        log_success ".env file exists (personal configuration)"
        ((PASSED++))
    else
        log_warn ".env file not found (copy from .env.example and configure)"
        ((WARNINGS++))
    fi
    
    # Directories
    log_section "Directories:"
    check_directory ~/Base/dotfiles
    check_directory ~/Base
    check_directory ~/.ssh
    check_directory ~/.local/bin
    
    # Git configuration
    log_section "Git Configuration:"
    check_git_config user.name
    check_git_config user.email
    check_git_config init.defaultBranch
    check_git_config core.editor
    
    # SSH keys
    log_section "SSH Keys:"
    local ssh_key_found=false
    for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ed25519_github; do
        if [[ -f "$key" ]]; then
            log_success "SSH key found: $(basename $key)"
            ((PASSED++))
            ssh_key_found=true
            break
        fi
    done
    
    if [[ "$ssh_key_found" == "false" ]]; then
        log_warn "No SSH keys found (run: ./scripts/setup-ssh.sh)"
        ((WARNINGS++))
    fi
    
    # Fish plugins (if Fish is installed)
    if command -v fish &> /dev/null; then
        log_section "Fish Plugins:"
        if fish -c "functions -q fisher" 2>/dev/null; then
            log_success "Fisher is installed"
            ((PASSED++))
            
            # Check for common plugins
            for plugin in "tide" "fzf" "z" "autopair"; do
                if fish -c "functions -q _tide_init || functions -q fzf_configure_bindings || functions -q __z || functions -q _autopair_backspace" 2>/dev/null; then
                    log_success "Fish plugins appear to be installed"
                    ((PASSED++))
                    break
                fi
            done
        else
            log_warn "Fisher is not installed"
            ((WARNINGS++))
        fi
    fi
    
    # Summary
    log_section "Summary:"
    echo "  Passed: $PASSED"
    echo "  Failed: $FAILED"
    echo "  Warnings: $WARNINGS"
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            echo -e "${GREEN}✨ Perfect! All checks passed!${NC}"
        else
            echo -e "${GREEN}✅ All critical checks passed!${NC}"
            echo -e "${YELLOW}⚠️  Some optional items need attention (see warnings above)${NC}"
        fi
        exit 0
    else
        echo -e "${RED}❌ Some checks failed. Please review and fix the issues above.${NC}"
        echo ""
        echo "Common fixes:"
        echo "  • Run ./setup.sh to install missing components"
        echo "  • Run ./scripts/setup-git.sh to configure git"
        echo "  • Run ./scripts/setup-ssh.sh to generate SSH keys"
        echo "  • Copy .env.example to .env and configure your settings"
        exit 1
    fi
}

main "$@"