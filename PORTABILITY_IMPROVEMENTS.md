# Dotfiles Portability Improvements

This document outlines necessary improvements to make the dotfiles setup truly portable and easy to deploy on new machines.

## Current Issues

1. **Multiple installation scripts** (`install.sh`, `bootstrap.sh`) with overlapping functionality
2. **Hardcoded values** (hostname, timezone, paths) in configuration files
3. **Missing dependency management** for non-Homebrew systems
4. **Manual steps** not automated (Fisher installation, SSH setup)
5. **No rollback mechanism** if installation fails

## Improvement Areas

### 1. Unified Installation Script

**Priority:** High | **Complexity:** Medium

Consolidate installation into a single, intelligent script that handles all scenarios.

```bash
#!/usr/bin/env bash
# Proposed structure for unified installer

# Detect OS and architecture
detect_system() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    if [[ "$OS" == "Darwin" ]]; then
        if [[ "$ARCH" == "arm64" ]]; then
            BREW_PREFIX="/opt/homebrew"
        else
            BREW_PREFIX="/usr/local"
        fi
    elif [[ "$OS" == "Linux" ]]; then
        BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    fi
}

# Interactive setup for personal configuration
interactive_setup() {
    read -p "Enter your computer name: " COMPUTER_NAME
    read -p "Enter your Git name: " GIT_NAME
    read -p "Enter your Git email: " GIT_EMAIL
    read -p "Enter your timezone (e.g., Europe/Brussels): " TIMEZONE
}
```

### 2. Machine-Specific Configuration

**Priority:** High | **Complexity:** Low

Remove hardcoded personal values and use templates instead.

#### Create `.env.example`:
```bash
# Personal Configuration Template
COMPUTER_NAME="your-computer-name"
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
TIMEZONE="Europe/Brussels"
DEFAULT_SHELL="fish"  # Options: fish, zsh, bash
```

#### Update `macos/setup.sh`:
```bash
# Load configuration
source ~/.dotfiles/.env

# Use variables instead of hardcoded values
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
```

### 3. Dependencies Management

**Priority:** Medium | **Complexity:** Medium

Add version pinning and fallback installation methods.

#### Enhanced Brewfile with versions:
```ruby
# Core tools with specific versions
brew "git", args: ["HEAD"]
brew "fish", link: true
brew "atuin"
brew "mise"
brew "fzf", args: ["HEAD"]

# Fallback installation detection
unless system("command -v brew")
  puts "Homebrew not found, using alternative installation..."
end
```

### 4. SSH and Security Configuration

**Priority:** High | **Complexity:** Low

Create templates and generation scripts for sensitive configurations.

#### `ssh/config.template`:
```
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 120

Host github.com
    Hostname github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github

Host {{WORK_SERVER}}
    Hostname {{WORK_SERVER_IP}}
    User {{WORK_USERNAME}}
    IdentityFile ~/.ssh/id_rsa_work
```

#### SSH key generation script:
```bash
generate_ssh_keys() {
    echo "🔐 Generating SSH keys..."
    
    # Personal GitHub key
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519_github -N ""
    
    # Add to keychain
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github
    
    echo "📋 GitHub SSH public key:"
    cat ~/.ssh/id_ed25519_github.pub
    echo ""
    echo "Add this key to: https://github.com/settings/keys"
}
```

### 5. Shell Configuration Improvements

**Priority:** Medium | **Complexity:** Low

Make shell setup more robust and automatic.

#### Auto-install Fisher plugins:
```fish
# In fish/config.fish
if not functions -q fisher
    echo "Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    
    # Install plugins
    fisher install jethrokuan/z
    fisher install PatrickF1/fzf.fish
    fisher install franciscolourenco/done
    fisher install jorgebucaran/autopair.fish
end
```

### 6. Installation Workflow

**Priority:** High | **Complexity:** High

Create a robust, interactive installation process.

#### New `install.sh` structure:
```bash
#!/usr/bin/env bash

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Backup existing configurations
backup_existing() {
    BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    for file in ~/.gitconfig ~/.ssh/config ~/.config/fish; do
        if [[ -e "$file" ]]; then
            cp -r "$file" "$BACKUP_DIR/"
            log_info "Backed up $file"
        fi
    done
}

# Dry run mode
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    log_warn "DRY RUN MODE - No changes will be made"
fi

# Main installation flow
main() {
    log_info "Starting dotfiles installation..."
    
    # Pre-flight checks
    check_requirements
    
    # Backup existing configs
    backup_existing
    
    # Interactive setup
    if [[ ! -f ~/.dotfiles/.env ]]; then
        interactive_setup
    fi
    
    # Install dependencies
    install_homebrew
    install_packages
    
    # Configure system
    setup_shell
    setup_dotfiles
    setup_macos
    
    # Post-installation
    run_health_check
    show_next_steps
}

main "$@"
```

### 7. Documentation Structure

**Priority:** Low | **Complexity:** Low

Improve documentation for better onboarding.

```
.dotfiles/
├── README.md                 # Quick start guide
├── INSTALL.md               # Detailed installation
├── TROUBLESHOOTING.md       # Common issues and fixes
├── PORTABILITY_IMPROVEMENTS.md  # This document
└── docs/
    ├── macos.md            # macOS-specific setup
    ├── linux.md            # Linux-specific setup
    └── manual-steps.md     # Things that can't be automated
```

### 8. Testing and Validation

**Priority:** Medium | **Complexity:** High

Add automated testing for configurations.

#### Health check script (`bin/health_check`):
```bash
#!/usr/bin/env bash

check_command() {
    if command -v "$1" &> /dev/null; then
        echo "✓ $1 is installed"
        return 0
    else
        echo "✗ $1 is not installed"
        return 1
    fi
}

check_symlink() {
    if [[ -L "$1" && -e "$1" ]]; then
        echo "✓ $1 is properly linked"
        return 0
    else
        echo "✗ $1 is not properly linked"
        return 1
    fi
}

# Run checks
echo "🏥 Running health check..."
echo ""
echo "Commands:"
check_command git
check_command brew
check_command fish
check_command atuin
check_command mise

echo ""
echo "Symlinks:"
check_symlink ~/.gitconfig
check_symlink ~/.config/fish
check_symlink ~/.config/atuin
```

## Implementation Priority

### Phase 1: Critical (Do before new computer)
1. Create `.env.example` template
2. Remove hardcoded values from `macos/setup.sh`
3. Consolidate installation scripts
4. Add backup mechanism

### Phase 2: Important (Can do on new computer)
1. Add interactive setup wizard
2. Implement health checks
3. Create SSH key generation script
4. Add Fisher auto-installation

### Phase 3: Nice to Have (Future improvements)
1. Add Linux support
2. Create CI/CD testing
3. Add uninstall script
4. Implement dry-run mode fully

## Quick Fixes for Tomorrow

If you need to set up your new computer tomorrow with minimal changes:

1. **Create `.env` file** with your personal settings
2. **Run this sequence:**
   ```bash
   # Clone dotfiles
   git clone https://github.com/ferdinandsalis/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   
   # Create .env with your settings
   cat > .env << EOF
   COMPUTER_NAME="your-new-computer"
   GIT_USER_NAME="Your Name"
   GIT_USER_EMAIL="your@email.com"
   TIMEZONE="Europe/Brussels"
   EOF
   
   # Run bootstrap
   ./bootstrap.sh
   
   # Install Fisher plugins manually
   fish -c "fisher_install"
   
   # Generate SSH keys
   ssh-keygen -t ed25519 -C "your@email.com"
   ```

3. **Manual steps:**
   - Add SSH key to GitHub
   - Sign into Mac App Store
   - Configure any app-specific settings
   - Import any personal data/preferences

## Testing Checklist

Before considering the setup complete on a new machine:

- [ ] All dotfiles are properly symlinked
- [ ] Git commits work with correct author
- [ ] SSH access to GitHub works
- [ ] Fish shell is default and plugins work
- [ ] Atuin history search works (Ctrl+E)
- [ ] FZF search works (Ctrl+R)
- [ ] Homebrew packages are installed
- [ ] Mise/development tools are configured
- [ ] macOS preferences are applied
- [ ] All expected directories exist

## Notes

- Consider using [chezmoi](https://www.chezmoi.io/) or [GNU Stow](https://www.gnu.org/software/stow/) for more advanced dotfiles management
- The current Dotbot setup is good but could benefit from templates support
- Consider separating work-specific and personal configurations
- Add support for Linux/WSL for maximum portability