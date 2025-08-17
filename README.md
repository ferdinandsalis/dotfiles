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

### Prerequisites

1. Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install Git:
```bash
brew install git
```

### Setup

1. Clone this repository:
```bash
git clone https://github.com/ferdinandsalis/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the installation script:
```bash
./install
```

3. Install Homebrew packages:
```bash
brew bundle --file=~/.Brewfile
```

4. Set Fish as default shell:
```bash
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

5. Install Fisher package manager and plugins (run in Fish shell):
```fish
fisher_install
```

6. Configure Mise for runtime management:
```bash
# Mise is automatically configured in bootstrap.sh
# To manually install global tools:
mise use --global node@lts
mise use --global python@latest
mise use --global yarn@latest

# For project-specific versions, use in project directory:
mise use node@20
mise use python@3.12
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
