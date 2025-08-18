#!/usr/bin/env bash

# Test script for dotfiles installation
# Run this in a clean environment to test the setup process

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
log_test() { echo -e "${BLUE}TEST${NC} $1"; }

# Test modes
DRY_RUN=${DRY_RUN:-false}
TEST_DIR=${TEST_DIR:-"$HOME/.dotfiles-test"}
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run        Simulate without making changes"
    echo "  --docker         Test in Docker container"
    echo "  --vm             Test in VM (requires vagrant)"
    echo "  --local          Test locally with backup (default)"
    echo "  --clean          Clean up test environment"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --dry-run     # Test without making changes"
    echo "  $0 --docker      # Test in isolated Docker container"
    echo "  $0 --local       # Test locally with backups"
}

# Backup existing dotfiles
backup_existing() {
    log_info "Backing up existing dotfiles to $BACKUP_DIR..."
    
    local items=(
        "$HOME/.dotfiles"
        "$HOME/.gitconfig"
        "$HOME/.ssh/config"
        "$HOME/.config/fish"
        "$HOME/.config/atuin"
        "$HOME/.Brewfile"
    )
    
    mkdir -p "$BACKUP_DIR"
    
    for item in "${items[@]}"; do
        if [[ -e "$item" ]]; then
            cp -r "$item" "$BACKUP_DIR/" 2>/dev/null || true
            log_info "Backed up $item"
        fi
    done
}

# Restore from backup
restore_backup() {
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Restoring from backup..."
        
        # Remove test installations
        rm -rf "$HOME/.dotfiles"
        
        # Restore backed up files
        cp -r "$BACKUP_DIR"/* "$HOME/" 2>/dev/null || true
        
        log_info "Restored from backup"
    else
        log_warn "No backup found to restore"
    fi
}

# Test in Docker container
test_docker() {
    log_test "Testing in Docker container..."
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        return 1
    fi
    
    # Create a temporary directory in HOME (avoids permission issues)
    local temp_dir="$HOME/.dotfiles-docker-test"
    mkdir -p "$temp_dir"
    
    # Copy dotfiles to temp directory
    cp -r "$HOME/.dotfiles"/* "$temp_dir/" 2>/dev/null || true
    cp -r "$HOME/.dotfiles"/.[!.]* "$temp_dir/" 2>/dev/null || true
    
    # Create Dockerfile
    cat > "$temp_dir/Dockerfile" << 'EOF'
FROM ubuntu:22.04

# Install dependencies with retry logic
RUN apt-get update || apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    sudo \
    build-essential \
    ca-certificates \
    || apt-get install -y --fix-missing \
    curl \
    git \
    sudo \
    build-essential \
    ca-certificates

# Create test user
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/.dotfiles/

# Make scripts executable
RUN chmod +x /home/testuser/.dotfiles/setup.sh && \
    chmod +x /home/testuser/.dotfiles/scripts/*.sh || true

# Note: Can't run interactive setup in Docker build
# Would need to run interactively or with expect

CMD ["/bin/bash", "-c", "cd ~/.dotfiles && ./scripts/health-check.sh || true; bash"]
EOF

    # Build and run container
    log_info "Building Docker image..."
    if docker build -t dotfiles-test "$temp_dir"; then
        log_info "Running Docker container..."
        docker run -it --rm dotfiles-test
        
        # Cleanup
        docker rmi dotfiles-test 2>/dev/null || true
    else
        log_error "Docker build failed"
    fi
    
    # Cleanup temp directory
    rm -rf "$temp_dir"
}

# Test in Vagrant VM
test_vagrant() {
    log_test "Testing in Vagrant VM..."
    
    # Create Vagrantfile
    cat > /tmp/Vagrantfile << 'EOF'
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y curl git build-essential
  SHELL
  
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    git clone https://github.com/ferdinandsalis/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    ./setup.sh
  SHELL
end
EOF

    cd /tmp
    vagrant up
    vagrant ssh -c "cd ~/.dotfiles && ./scripts/health-check.sh"
    
    # Cleanup
    vagrant destroy -f
    rm Vagrantfile
}

# Test locally with safety measures
test_local() {
    log_test "Testing locally with backup..."
    
    # Backup existing setup
    backup_existing
    
    # Create test environment
    log_info "Creating test environment..."
    
    # Clone to test directory
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
    
    cp -r "$HOME/.dotfiles" "$TEST_DIR"
    
    # Run setup in test mode
    cd "$TEST_DIR"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "DRY RUN MODE - Not executing setup"
        
        # Just validate scripts
        bash -n setup.sh
        bash -n scripts/setup-git.sh
        bash -n scripts/setup-ssh.sh
        bash -n scripts/health-check.sh
        
        log_info "All scripts have valid syntax"
    else
        # Actually run setup
        ./setup.sh
        
        # Test helper scripts
        ./scripts/health-check.sh
    fi
}

# Unit tests for specific functions
run_unit_tests() {
    log_test "Running unit tests..."
    
    # Test architecture detection
    test_arch_detection() {
        source "$HOME/.dotfiles/setup.sh"
        detect_system
        
        if [[ -n "$BREW_PREFIX" ]]; then
            log_info "Architecture detection works: $BREW_PREFIX"
        else
            log_error "Architecture detection failed"
        fi
    }
    
    # Test idempotency
    test_idempotency() {
        log_test "Testing idempotency..."
        
        # Run setup twice
        cd "$TEST_DIR"
        ./setup.sh
        ./setup.sh
        
        log_info "Idempotency test passed"
    }
    
    test_arch_detection
    test_idempotency
}

# Integration tests
run_integration_tests() {
    log_test "Running integration tests..."
    
    # Test that all symlinks are created
    local expected_links=(
        "$HOME/.gitconfig"
        "$HOME/.config/fish"
        "$HOME/.config/atuin"
        "$HOME/.Brewfile"
    )
    
    for link in "${expected_links[@]}"; do
        if [[ -L "$link" ]]; then
            log_info "Symlink exists: $link"
        else
            log_error "Missing symlink: $link"
        fi
    done
    
    # Test that Fish plugins are installed
    if fish -c "functions -q fisher" 2>/dev/null; then
        log_info "Fisher is installed"
    else
        log_warn "Fisher not installed"
    fi
}

# Clean up test environment
cleanup() {
    log_info "Cleaning up test environment..."
    
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
    
    if [[ "$1" == "--restore" ]]; then
        restore_backup
    fi
    
    log_info "Cleanup complete"
}

# Main test orchestration
main() {
    case "${1:-}" in
        --dry-run)
            DRY_RUN=true
            test_local
            ;;
        --docker)
            test_docker
            ;;
        --vm|--vagrant)
            test_vagrant
            ;;
        --local)
            test_local
            run_unit_tests
            run_integration_tests
            ;;
        --clean)
            cleanup --restore
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            # Default: local test
            test_local
            run_unit_tests
            run_integration_tests
            
            echo ""
            log_info "Tests complete!"
            echo ""
            echo "To restore your original setup, run:"
            echo "  $0 --clean"
            ;;
    esac
}

# Handle cleanup on exit
trap cleanup EXIT

main "$@"