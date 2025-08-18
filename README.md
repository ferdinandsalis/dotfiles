# Dotfiles

Personal dotfiles managed with [Dotbot](https://github.com/anishathalye/dotbot).

## Features

- 🐟 Fish shell configuration with useful functions and abbreviations
- 🎨 Catppuccin theme for terminal applications (Ghostty, Helix)
- 🛠️ Development tool configurations (Git, NPM, Cargo, EditorConfig)
- ⚡ Modern CLI tools (eza, bat, ripgrep, fd, btop, etc.)
- 📦 Homebrew package management
- 🔧 Mise for runtime version management (replaces asdf and direnv)

## Installation

### Quick Start (New Machine)

```bash
# Clone and run setup
git clone https://github.com/ferdinandsalis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The setup script will:
- ✅ Install Xcode Command Line Tools
- ✅ Install Homebrew (with architecture detection)
- ✅ Create symlinks via Dotbot
- ✅ Install all packages from Brewfile
- ✅ Configure Mise for development tools
- ✅ Set up Fish shell with plugins
- ✅ Create necessary directories
- ✅ Optionally apply macOS preferences

### Post-Installation

After the main setup, run these helper scripts as needed:

```bash
# Configure Git
./scripts/setup-git.sh

# Generate SSH keys
./scripts/setup-ssh.sh

# Verify installation
./scripts/health-check.sh
```

### Manual Installation

If you prefer to run steps individually:

1. **Install Homebrew:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Clone dotfiles:**
```bash
git clone https://github.com/ferdinandsalis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

3. **Create symlinks:**
```bash
./install  # This runs Dotbot
```

4. **Install packages:**
```bash
brew bundle --file=~/.Brewfile
```

5. **Configure shell:**
```bash
# Add Fish to shells
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Install Fisher plugins (in Fish)
fisher_install
```

6. **Set up development tools:**
```bash
mise use --global node@lts
mise use --global python@latest
```

## Structure

```
.dotfiles/
├── fish/           # Fish shell configuration
│   ├── config.fish # Includes Mise activation
│   └── functions/  # Custom Fish functions
├── git/            # Git configuration
├── helix/          # Helix editor config
├── ghostty/        # Ghostty terminal config
├── ssh/            # SSH configuration
├── cargo/          # Rust/Cargo config
├── homebrew/       # Brewfile for packages
├── bootstrap.sh    # Setup script with Mise config
└── install.conf.yaml # Dotbot configuration
```

## Key Bindings

### Fish Shell
- `Ctrl+R`: Clear screen
- `Ctrl+X Ctrl+E`: Edit command in editor

## Useful Commands

### Fish Functions
- `mkcd <dir>`: Create and enter directory
- `backup <file>`: Create timestamped backup
- `extract <archive>`: Extract various archive formats
- `ports`: Show processes listening on ports
- `update`: Update system packages and tools

### Aliases
- `ls`, `ll`, `la`: Enhanced directory listing with eza
- `cat`: Better cat with bat
- `grep`: Ripgrep
- `find`: fd
- `ps`: procs
- `du`: dust
- `top`: btop

## Configuration Files

- **Fish**: `~/.config/fish/config.fish`
- **Git**: `~/.gitconfig`
- **SSH**: `~/.ssh/config`
- **Helix**: `~/.config/helix/config.toml`
- **Ghostty**: `~/.config/ghostty/config`
- **Ripgrep**: `~/.ripgreprc`
- **fd**: `~/.fdignore`
- **Mise**: `~/.config/mise/config.toml` (auto-created)
- **Mise local**: `.mise.toml` or `.mise.local.toml` in project directories

## Updating

To update dotfiles:
```bash
cd ~/.dotfiles
git pull
./install
```

To update packages:
```fish
update  # Custom Fish function
```

To update Mise tools:
```bash
mise upgrade  # Update all global tools
mise ls       # List installed tools
mise doctor   # Check Mise configuration
```

## Mise Usage

Mise is a polyglot runtime manager that replaces tools like asdf, nvm, rbenv, and direnv.

### Global Tool Management
```bash
# Install tools globally
mise use --global node@latest
mise use --global python@3.12
mise use --global rust@stable

# List available versions
mise ls-remote node
mise ls-remote python
```

### Project-Specific Versions
```bash
# In a project directory
mise use node@20.11.0
mise use python@3.11

# This creates a .mise.toml file
# Mise automatically activates when entering the directory
```

### Environment Variables
```bash
# Set project-specific env vars in .mise.toml
[env]
DATABASE_URL = "postgresql://localhost/myapp"
NODE_ENV = "development"
```

## License

MIT
