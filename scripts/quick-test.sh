#!/usr/bin/env bash

# Quick test script for dotfiles - runs non-destructive tests only
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

echo "🧪 Quick Dotfiles Test (Non-Destructive)"
echo "========================================"
echo ""

ERRORS=0

# Test 1: Validate shell scripts syntax
log_info "Testing shell script syntax..."
for script in setup.sh scripts/*.sh; do
    if bash -n "$script" 2>/dev/null; then
        log_success "$script syntax is valid"
    else
        log_fail "$script has syntax errors"
        ((ERRORS++))
    fi
done

# Test 2: Check for required files
log_info "Checking required files..."
required_files=(
    "install.conf.yaml"
    "setup.sh"
    "README.md"
    "homebrew/Brewfile"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        log_success "$file exists"
    else
        log_fail "$file is missing"
        ((ERRORS++))
    fi
done

# Test 3: Validate YAML files
log_info "Validating YAML configuration..."
if command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('install.conf.yaml'))" 2>/dev/null && \
        log_success "install.conf.yaml is valid YAML" || \
        { log_fail "install.conf.yaml has invalid YAML"; ((ERRORS++)); }
else
    log_warn "Python3 not found, skipping YAML validation"
fi

# Test 4: Check Dotbot submodule
log_info "Checking Dotbot submodule..."
if [[ -f "dotbot/bin/dotbot" ]]; then
    log_success "Dotbot is present"
else
    log_fail "Dotbot submodule not initialized"
    ((ERRORS++))
fi

# Test 5: Test that scripts are executable
log_info "Checking script permissions..."
for script in setup.sh scripts/*.sh; do
    if [[ -x "$script" ]]; then
        log_success "$script is executable"
    else
        log_warn "$script is not executable (run: chmod +x $script)"
    fi
done

# Test 6: Test Dotbot configuration
log_info "Testing Dotbot configuration..."
# Dotbot doesn't have a dry-run option, so we just check if the config is parseable
if [[ -f "install.conf.yaml" ]] && [[ -f "dotbot/bin/dotbot" ]]; then
    log_success "Dotbot configuration files exist"
else
    log_fail "Dotbot configuration missing"
    ((ERRORS++))
fi

# Test 7: Check for common issues
log_info "Checking for common issues..."

# Check for hardcoded paths
if grep -r "/Users/ferdinand" --include="*.sh" --include="*.fish" . 2>/dev/null | grep -v "^Binary" | grep -v ".git"; then
    log_warn "Found hardcoded paths - these should be replaced with variables"
else
    log_success "No hardcoded paths found"
fi

# Check for missing dependencies in Brewfile
brewfile_commands=("git" "fish" "mise" "fzf" "bat" "eza" "ripgrep" "fd")
for cmd in "${brewfile_commands[@]}"; do
    if grep -q "$cmd" homebrew/Brewfile; then
        log_success "$cmd is in Brewfile"
    else
        log_warn "$cmd might be missing from Brewfile"
    fi
done

# Summary
echo ""
echo "========================================"
if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✨ All tests passed!${NC}"
    echo ""
    echo "Your dotfiles are ready for installation on a new machine."
    echo "Run ./setup.sh to install."
else
    echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
    echo ""
    echo "Please fix the issues above before installing on a new machine."
    exit 1
fi