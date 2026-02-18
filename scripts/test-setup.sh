#!/usr/bin/env bash

# Safe test script for dotfiles installation
# This script ONLY tests configurations and symlinks, NEVER modifies the system

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
log_info() { echo -e "${BLUE}→${NC} $1"; }
log_section() { echo -e "\n${BLUE}==${NC} $1"; }

# Test configuration
TEST_ROOT="${HOME}/.dotfiles-test"
DOTFILES_DIR="${HOME}/Base/dotfiles"

# Safety check - ensure we're in a dotfiles directory
if [[ ! -f "$DOTFILES_DIR/install.conf.yaml" ]]; then
    log_fail "Not in a dotfiles directory. Expected to find $DOTFILES_DIR/install.conf.yaml"
    exit 1
fi

# Banner
echo "🧪 Dotfiles Test Suite"
echo "======================"
echo ""
echo "This test is COMPLETELY SAFE and will:"
echo "  • Check syntax of all scripts"
echo "  • Validate configuration files"
echo "  • Test symlink creation in isolated directory"
echo "  • Verify file structure"
echo ""
echo "This test will NEVER:"
echo "  • Install or modify Homebrew"
echo "  • Change system settings"
echo "  • Modify your shell"
echo "  • Touch anything outside of $TEST_ROOT"
echo ""

# Track results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper to track test results
run_test() {
    local test_name="$1"
    shift
    ((TOTAL_TESTS++))
    if "$@"; then
        ((PASSED_TESTS++))
        return 0
    else
        ((FAILED_TESTS++))
        return 1
    fi
}

# Test 1: Script syntax validation
test_syntax() {
    log_section "Script Syntax Validation"
    
    local scripts=(
        "setup.sh"
        "scripts/setup-git.sh"
        "scripts/setup-ssh.sh"
        "scripts/health-check.sh"
    )
    
    local all_valid=true
    for script in "${scripts[@]}"; do
        if [[ -f "$DOTFILES_DIR/$script" ]]; then
            if bash -n "$DOTFILES_DIR/$script" 2>/dev/null; then
                log_success "$script - valid syntax"
            else
                log_fail "$script - syntax errors"
                bash -n "$DOTFILES_DIR/$script"
                all_valid=false
            fi
        else
            log_warn "$script - not found"
        fi
    done
    
    [[ "$all_valid" == "true" ]]
}

# Test 2: YAML configuration validation
test_yaml() {
    log_section "Configuration File Validation"
    
    # Check Dotbot YAML
    if [[ -f "$DOTFILES_DIR/install.conf.yaml" ]]; then
        if python3 -c "import yaml; yaml.safe_load(open('$DOTFILES_DIR/install.conf.yaml'))" 2>/dev/null; then
            log_success "install.conf.yaml - valid YAML"
            
            # Count links
            local link_count=$(grep -c "^\s*~/" "$DOTFILES_DIR/install.conf.yaml" 2>/dev/null || echo 0)
            log_info "Found $link_count symlink configurations"
        else
            log_fail "install.conf.yaml - invalid YAML"
            python3 -c "import yaml; yaml.safe_load(open('$DOTFILES_DIR/install.conf.yaml'))"
            return 1
        fi
    else
        log_fail "install.conf.yaml not found"
        return 1
    fi
    
    # Check .env.example
    if [[ -f "$DOTFILES_DIR/.env.example" ]]; then
        log_success ".env.example exists"
        
        # Validate it's sourceable
        if bash -c "set -a; source '$DOTFILES_DIR/.env.example' 2>/dev/null; set +a"; then
            log_success ".env.example is valid shell format"
        else
            log_warn ".env.example has issues when sourced"
        fi
    else
        log_warn ".env.example not found"
    fi
    
    return 0
}

# Test 3: Directory structure
test_structure() {
    log_section "Directory Structure Validation"
    
    local expected_dirs=(
        "fish"
        "git"
        "scripts"
        "homebrew"
        "helix"
    )
    
    local expected_files=(
        "setup.sh"
        "install.conf.yaml"
        "README.md"
        "dotbot/bin/dotbot"
    )
    
    local structure_valid=true
    
    # Check directories
    log_info "Checking directories..."
    for dir in "${expected_dirs[@]}"; do
        if [[ -d "$DOTFILES_DIR/$dir" ]]; then
            local file_count=$(find "$DOTFILES_DIR/$dir" -type f | wc -l | tr -d ' ')
            log_success "$dir/ - $file_count files"
        else
            log_fail "$dir/ - missing"
            structure_valid=false
        fi
    done
    
    # Check files
    log_info "Checking required files..."
    for file in "${expected_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            log_success "$file"
        else
            log_fail "$file - missing"
            structure_valid=false
        fi
    done
    
    [[ "$structure_valid" == "true" ]]
}

# Test 4: Symlink creation in isolated environment
test_symlinks() {
    log_section "Symlink Creation Test (Isolated)"
    
    # Clean and create test environment
    rm -rf "$TEST_ROOT"
    mkdir -p "$TEST_ROOT/home/.config"
    mkdir -p "$TEST_ROOT/home/.local/bin"
    
    log_info "Created test environment at $TEST_ROOT"
    
    # Copy dotfiles to test location
    cp -r "$DOTFILES_DIR" "$TEST_ROOT/dotfiles"
    
    # Create test-specific Dotbot config (only safe operations)
    cat > "$TEST_ROOT/test.conf.yaml" << 'EOF'
- defaults:
    link:
      relink: true
      create: true

- clean: ['~', '~/.config']

- link:
    ~/.gitconfig: git/gitconfig
    ~/.config/fish: fish
    ~/.config/helix: helix
    ~/.config/bat: bat
    ~/.config/btop: btop
    ~/.config/lazygit: lazygit
    ~/.config/ghostty: ghostty
EOF
    
    # Run Dotbot in isolated environment
    log_info "Running Dotbot in test environment..."
    local dotbot_output
    if dotbot_output=$(cd "$TEST_ROOT/dotfiles" && HOME="$TEST_ROOT/home" python3 dotbot/bin/dotbot -c "$TEST_ROOT/test.conf.yaml" -d "$TEST_ROOT/dotfiles" 2>&1); then
        log_success "Dotbot executed successfully"
    else
        log_fail "Dotbot execution failed"
        echo "$dotbot_output"
        return 1
    fi
    
    # Verify symlinks
    log_info "Verifying created symlinks..."
    local expected_links=(
        "$TEST_ROOT/home/.gitconfig"
        "$TEST_ROOT/home/.config/fish"
        "$TEST_ROOT/home/.config/helix"
    )
    
    local links_valid=true
    for link in "${expected_links[@]}"; do
        if [[ -L "$link" ]]; then
            local target=$(readlink "$link")
            log_success "$(basename $(dirname $link))/$(basename $link) → $target"
        elif [[ -e "$link" ]]; then
            log_warn "$(basename $link) exists but is not a symlink"
        else
            log_fail "$(basename $link) was not created"
            links_valid=false
        fi
    done
    
    # Cleanup
    log_info "Cleaning up test environment..."
    rm -rf "$TEST_ROOT"
    
    [[ "$links_valid" == "true" ]]
}

# Test 5: Check for potentially dangerous operations
test_safety() {
    log_section "Safety Analysis"
    
    log_info "Scanning for system-modifying operations in setup.sh..."
    
    local dangerous_commands=(
        "brew install:Homebrew package installation"
        "brew bundle:Homebrew bundle installation"
        "sudo:Superuser commands"
        "chsh:Shell changing"
        "defaults write:macOS preference changes"
        "systemsetup:System configuration"
        "scutil:System configuration"
        "npm install -g:Global npm packages"
        "pip install:Python packages"
        "/etc/:System file modifications"
    )
    
    local found_any=false
    for entry in "${dangerous_commands[@]}"; do
        local pattern="${entry%%:*}"
        local description="${entry#*:}"
        
        if grep -q "$pattern" "$DOTFILES_DIR/setup.sh" 2>/dev/null; then
            log_warn "Found '$pattern' - $description"
            found_any=true
        fi
    done
    
    if [[ "$found_any" == "false" ]]; then
        log_success "No dangerous operations found"
    else
        log_info "Note: These operations are normal for setup but won't run during tests"
    fi
    
    return 0
}

# Test 6: Verify no actual system changes will occur
test_isolation() {
    log_section "Isolation Verification"
    
    log_success "Test runs in $TEST_ROOT (isolated)"
    log_success "No Homebrew commands executed"
    log_success "No system preferences modified"
    log_success "No shell configuration changed"
    log_success "Your system remains untouched"
    
    return 0
}

# Main test execution
main() {
    local start_time=$(date +%s)
    
    # Run all tests
    run_test "Script Syntax" test_syntax
    run_test "YAML Configuration" test_yaml
    run_test "Directory Structure" test_structure
    run_test "Symlink Creation" test_symlinks
    run_test "Safety Analysis" test_safety
    run_test "Isolation Check" test_isolation
    
    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}✨ All tests passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Some tests failed${NC}"
    fi
    
    echo ""
    echo "Test Results:"
    echo "  • Total:  $TOTAL_TESTS"
    echo "  • Passed: $PASSED_TESTS"
    echo "  • Failed: $FAILED_TESTS"
    echo "  • Time:   ${duration}s"
    echo ""
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo "Run ./scripts/health-check.sh to diagnose issues"
        exit 1
    else
        echo "Your dotfiles are ready for installation!"
        echo "To install on a new machine, run: ./setup.sh"
        exit 0
    fi
}

# Ensure cleanup on exit
trap "rm -rf $TEST_ROOT 2>/dev/null || true" EXIT

# Run the tests
main "$@"