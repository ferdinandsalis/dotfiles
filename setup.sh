#!/usr/bin/env bash

# Setup script for dotfiles on a new macOS machine
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

echo "🚀 Starting dotfiles setup..."
echo ""

# Setup environment configuration
setup_env() {
    if [[ ! -f "$HOME/.dotfiles/.env" ]]; then
        if [[ -f "$HOME/.dotfiles/.env.example" ]]; then
            log_step "No .env file found. Let's create one..."
            echo ""
            echo "Please provide your configuration details:"
            
            read -p "Computer name (e.g., john-macbook): " computer_name
            read -p "Your full name for Git: " git_name
            read -p "Your email for Git: " git_email
            read -p "Your GitHub username: " github_user
            
            # Create .env file from template
            cp "$HOME/.dotfiles/.env.example" "$HOME/.dotfiles/.env"
            
            # Replace placeholders
            sed -i '' "s/your-computer-name/${computer_name}/g" "$HOME/.dotfiles/.env"
            sed -i '' "s/your-hostname/${computer_name}/g" "$HOME/.dotfiles/.env"
            sed -i '' "s/Your Name/${git_name}/g" "$HOME/.dotfiles/.env"
            sed -i '' "s/your.email@example.com/${git_email}/g" "$HOME/.dotfiles/.env"
            sed -i '' "s/your-github-username/${github_user}/g" "$HOME/.dotfiles/.env"
            
            log_info "Created .env file with your configuration"
        else
            log_warn "No .env.example template found, using defaults"
        fi
    else
        log_info "Found existing .env file"
    fi
    
    # Load the environment variables
    if [[ -f "$HOME/.dotfiles/.env" ]]; then
        set -a
        source "$HOME/.dotfiles/.env"
        set +a
    fi
}

# Detect system architecture
detect_system() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    if [[ "$OS" != "Darwin" ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
    
    if [[ "$ARCH" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
        log_info "Detected Apple Silicon Mac"
    else
        BREW_PREFIX="/usr/local"
        log_info "Detected Intel Mac"
    fi
    
    export PATH="$BREW_PREFIX/bin:$PATH"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    if ! xcode-select -p &> /dev/null; then
        log_step "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Press any key once Xcode installation is complete..."
        read -n 1
    else
        log_info "Xcode Command Line Tools already installed"
    fi
}

# Install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        eval "$($BREW_PREFIX/bin/brew shellenv)"
        
        # Add to shell profile for future sessions
        if [[ ! -f ~/.zprofile ]] || ! grep -q "$BREW_PREFIX/bin/brew shellenv" ~/.zprofile; then
            echo 'eval "$('$BREW_PREFIX'/bin/brew shellenv)"' >> ~/.zprofile
        fi
    else
        log_info "Homebrew already installed"
    fi
}

# Clone or update dotfiles
setup_dotfiles() {
    if [ ! -d "$HOME/.dotfiles" ]; then
        log_step "Cloning dotfiles repository..."
        git clone https://github.com/ferdinandsalis/dotfiles.git "$HOME/.dotfiles" || {
            log_error "Failed to clone dotfiles repository"
            exit 1
        }
    else
        log_info "Dotfiles already present"
        log_step "Updating dotfiles..."
        cd "$HOME/.dotfiles"
        git pull origin main || log_warn "Could not update dotfiles (local changes?)"
    fi
    
    cd "$HOME/.dotfiles"
    
    # Initialize submodules (Dotbot)
    log_step "Initializing Dotbot..."
    git submodule update --init --recursive
    
    # Run Dotbot to create symlinks
    log_step "Creating symlinks..."
    ./install
}

# Install Homebrew packages
install_packages() {
    log_step "Installing Homebrew packages..."
    
    if [ -f "$HOME/.Brewfile" ]; then
        brew bundle --file="$HOME/.Brewfile" || log_warn "Some packages failed to install"
    else
        log_error "Brewfile not found at ~/.Brewfile"
        log_warn "Run './install' first to create symlinks"
        return 1
    fi
}

# Configure development tools with Mise
setup_mise() {
    if command -v mise &> /dev/null; then
        log_step "Configuring Mise..."
        mise trust --all 2>/dev/null || true
        
        log_step "Installing development tools with Mise..."
        mise use --global node@lts 2>/dev/null || log_warn "Could not install Node.js"
        mise use --global python@latest 2>/dev/null || log_warn "Could not install Python"
        mise use --global yarn@latest 2>/dev/null || log_warn "Could not install Yarn"
        
        log_info "Mise setup complete!"
    else
        log_warn "Mise not found, skipping development tools setup"
    fi
}

# Setup Fish shell
setup_fish() {
    local fish_path="$BREW_PREFIX/bin/fish"
    
    if [ -f "$fish_path" ]; then
        # Add Fish to available shells
        if ! grep -q "$fish_path" /etc/shells; then
            log_step "Adding Fish to available shells..."
            echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
        fi
        
        # Prompt to set Fish as default
        echo ""
        read -p "Set Fish as your default shell? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_step "Setting Fish as default shell..."
            chsh -s "$fish_path"
            log_info "Fish is now your default shell"
            
            # Auto-install Fisher and plugins
            log_step "Installing Fisher and plugins..."
            "$fish_path" -c "
                if not functions -q fisher
                    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
                    fisher install jorgebucaran/fisher
                end

                echo 'Installing Fish plugins...'
                fisher install jethrokuan/z
                fisher install PatrickF1/fzf.fish
                fisher install franciscolourenco/done
                fisher install jorgebucaran/autopair.fish
                fisher install IlanCosman/tide@v6

                echo 'Configuring Tide prompt...'
                tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Many icons' --transient=Yes
            " || log_warn "Could not install Fisher plugins automatically"
        fi
    else
        log_warn "Fish shell not found, skipping shell configuration"
    fi
}

# Create necessary directories
create_directories() {
    log_step "Creating necessary directories..."
    
    directories=(
        "$HOME/.ssh/sockets"
        "$HOME/.local/bin"
        "$HOME/projects"
        "$HOME/work"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
    done
    
    # Set proper permissions
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    [ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"
    
    log_info "Directories created"
}

# Run macOS defaults (optional)
setup_macos() {
    if [ -f "$HOME/.dotfiles/macos/setup.sh" ]; then
        echo ""
        read -p "Apply macOS system preferences? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_step "Applying macOS preferences..."
            source "$HOME/.dotfiles/macos/setup.sh"
            log_info "macOS preferences applied"
        fi
    fi
}

# Main installation flow
main() {
    # Environment setup (should be first)
    setup_env
    
    # System detection
    detect_system
    
    # Core installation
    install_xcode_tools
    install_homebrew
    setup_dotfiles
    install_packages
    
    # Configuration
    setup_mise
    setup_fish
    create_directories
    setup_macos
    
    # Success message
    echo ""
    echo "✨ Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: exec $BREW_PREFIX/bin/fish"
    echo "2. Configure git: ./scripts/setup-git.sh"
    echo "3. Generate SSH keys: ./scripts/setup-ssh.sh"
    echo "4. Run health check: ./scripts/health-check.sh"
    echo ""
    echo "For detailed setup info, see: README.md"
}

# Run main function
main "$@"