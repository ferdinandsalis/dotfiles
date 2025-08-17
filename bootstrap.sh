#!/usr/bin/env bash

# Bootstrap script for setting up a new macOS machine
set -e

echo "🚀 Starting bootstrap process..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏸️  Press any key once installation is complete..."
    read -n 1
fi

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    echo "🔧 Configuring Homebrew..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Clone dotfiles if not already present
if [ ! -d "$HOME/.dotfiles" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone https://github.com/ferdinandsalis/dotfiles.git "$HOME/.dotfiles"
else
    echo "✅ Dotfiles already present"
fi

# Navigate to dotfiles directory
cd "$HOME/.dotfiles"

# Install Dotbot dependencies
echo "🔗 Installing Dotbot..."
git submodule update --init --recursive

# Run Dotbot
echo "🔗 Creating symlinks..."
./install

# Install Homebrew packages
echo "📦 Installing Homebrew packages..."
brew bundle --file="$HOME/.Brewfile"

# Install Mise (replacement for asdf and direnv)
echo "🔌 Setting up Mise..."
if ! command -v mise &> /dev/null; then
    echo "📦 Installing Mise..."
    brew install mise
fi

# Configure Mise
if command -v mise &> /dev/null; then
    echo "🔧 Configuring Mise..."
    mise trust --all || true
    
    # Install common development tools with Mise
    echo "📦 Installing development tools with Mise..."
    mise use --global node@lts || true
    mise use --global python@latest || true
    mise use --global yarn@latest || true
    
    echo "✅ Mise setup complete!"
fi

# Set Fish as default shell
if ! grep -q "/opt/homebrew/bin/fish" /etc/shells; then
    echo "🐟 Adding Fish to available shells..."
    echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
fi

# Check if current shell is Fish
if [[ "$SHELL" != "/opt/homebrew/bin/fish" ]]; then
    echo "🐟 Setting Fish as default shell..."
    chsh -s /opt/homebrew/bin/fish
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p ~/.ssh/sockets
mkdir -p ~/.local/bin
mkdir -p ~/projects
mkdir -p ~/work

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config 2>/dev/null || true

echo "✨ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: exec fish"
echo "2. In Fish shell, run: fisher_install"
echo "3. Configure git with your credentials:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your.email@example.com\""
echo "4. Add your SSH keys to ~/.ssh/"
echo "5. Review and customize configurations in ~/.dotfiles/"