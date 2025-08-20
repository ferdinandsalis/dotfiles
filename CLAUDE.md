# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with Dotbot for macOS systems. It contains configurations for Fish shell, modern CLI tools, and development environments.

## Key Commands

### Testing & Validation
```bash
# Run comprehensive test suite (non-destructive)
./scripts/quick-test.sh

# Validate specific components
bash -n setup.sh                    # Check shell script syntax
python3 -c "import yaml; yaml.safe_load(open('install.conf.yaml'))"  # Validate YAML

# Health check after installation
./scripts/health-check.sh
```

### Installation & Setup
```bash
# Full setup on new machine
./setup.sh

# Update symlinks only (after adding new configs)
./install

# Install/update Homebrew packages
brew bundle --file=~/.Brewfile

# Update all tools and packages (in Fish shell)
update
```

### Git Operations

#### Commit Guidelines
- Use conventional commit format: `type(scope): description`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
  - Example: `feat(fish): add new fzf keybinding`
  - Example: `fix(helix): correct TOML language server timeout`
- Keep commits atomic - one logical change per commit
- Write descriptive commit messages explaining why, not just what
- Do not mention AI assistance in commit messages

#### Security Checks
When committing changes to dotfiles, ensure no secrets are exposed. Check for:
- API tokens in config files
- SSH keys or passwords
- Personal information in git config

## Architecture & Structure

### Dotbot Symlink Management
The repository uses Dotbot (submodule in `dotbot/`) to manage symlinks. Configuration is in `install.conf.yaml`:
- Links are created with `relink: true` to update existing symlinks
- `force: true` is used for configs that may have been manually created
- The `clean` directive removes dead symlinks from home directory

### Configuration Loading Order
1. **Fish Shell**: `fish/config.fish` → `fish/conf.d/*.fish` → `fish/functions/*.fish`
2. **Mise**: Global config at `~/.config/mise/config.toml`, project-specific `.mise.toml`
3. **Git**: `git/gitconfig` includes `git/gitconfig.local` for machine-specific settings

### Theme Consistency
Uses Catppuccin themes across all tools:
- Fish: Catppuccin Mocha/Latte (colors defined in config.fish:121-145)
- Helix: Theme set in helix/config.toml:1
- FZF: Theme colors in fish/config.fish:34-41
- Ghostty: Theme in ghostty/config

### Environment Variable Management
- Fish shell exports in `fish/config.fish:3-9`
- Mise environment variables can be set globally or per-project
- `MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES=none` disables `.tool-versions` files

## Critical Dependencies

### Required for Setup
- Xcode Command Line Tools
- Homebrew (auto-detected for arm64/x86_64)
- Git (for cloning and submodules)

### Core Tools Managed by Mise
- Node.js (LTS version)
- Python (latest)
- Additional tools configured in `.mise.toml` per project

## Common Development Tasks

### Adding New Configuration
1. Create config file/directory in repository
2. Add link entry to `install.conf.yaml`
3. Run `./install` to create symlinks
4. Test with `./scripts/quick-test.sh`

### Updating Tools
```fish
# Update Mise-managed tools
mise upgrade

# Update Fisher plugins (Fish shell)
fisher update

# Update Homebrew packages
brew update && brew upgrade
```

### Debugging Issues
- Check symlinks: `ls -la ~/.config/`
- Verify Dotbot: `./dotbot/bin/dotbot -c install.conf.yaml`
- Test Fish config: `fish -c "source ~/.config/fish/config.fish"`
- Check Mise status: `mise doctor`

## Important File Locations
- Main setup script: `setup.sh`
- Dotbot config: `install.conf.yaml`
- Test suite: `scripts/quick-test.sh`
- Package list: `homebrew/Brewfile`
- Fish main config: `fish/config.fish`
- Helix config: `helix/config.toml`, `helix/languages.toml`