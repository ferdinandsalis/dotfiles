#!/usr/bin/env bash

# Toggle between Catppuccin Latte (light) and Mocha (dark) themes

# Get the current theme from a state file
STATE_FILE="$HOME/.config/catppuccin-theme"
CURRENT_THEME=$(cat "$STATE_FILE" 2>/dev/null || echo "mocha")

# Toggle the theme
if [ "$CURRENT_THEME" = "mocha" ]; then
    NEW_THEME="latte"
    NEW_THEME_FULL="catppuccin-latte"
    
    # FZF colors for Latte theme
    FZF_COLORS="--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
--color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
--color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
    
    # Helix theme
    HELIX_THEME="catppuccin_latte"
    
    # Bat theme
    BAT_THEME="Catppuccin-latte"
else
    NEW_THEME="mocha"
    NEW_THEME_FULL="catppuccin-mocha"
    
    # FZF colors for Mocha theme
    FZF_COLORS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    
    # Helix theme
    HELIX_THEME="catppuccin_mocha"
    
    # Bat theme
    BAT_THEME="Catppuccin-mocha"
fi

# Update configurations

# 1. Ghostty
sed -i.bak "s/^theme = .*/theme = \"$NEW_THEME_FULL\"/" "$HOME/.dotfiles/ghostty/config"

# 2. Helix
sed -i.bak "s/^theme = .*/theme = \"$HELIX_THEME\"/" "$HOME/.dotfiles/helix/config.toml"

# 3. Bat
sed -i.bak "s/^--theme=.*/--theme=\"$BAT_THEME\"/" "$HOME/.dotfiles/bat/config"

# 4. Fish config - FZF colors
# Find and replace the FZF color line
if [ "$NEW_THEME" = "latte" ]; then
    # Escape the colors for sed
    sed -i.bak '/^--color=bg+:/s/.*/--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \\/' "$HOME/.dotfiles/fish/config.fish"
    sed -i.bak '/^--color=fg:/s/.*/--color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \\/' "$HOME/.dotfiles/fish/config.fish"
    sed -i.bak '/^--color=marker:/s/.*/--color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"/' "$HOME/.dotfiles/fish/config.fish"
    sed -i.bak 's/# Catppuccin Mocha theme for FZF/# Catppuccin Latte theme for FZF/' "$HOME/.dotfiles/fish/config.fish"
else
    sed -i.bak '/^--color=bg+:/s/.*/--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \\/' "$HOME/.dotfiles/fish/config.fish"
    sed -i.bak '/^--color=fg:/s/.*/--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \\/' "$HOME/.dotfiles/fish/config.fish"
    sed -i.bak '/^--color=marker:/s/.*/--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"/' "$HOME/.dotfiles/fish/config.fish"
    sed -i.bak 's/# Catppuccin Latte theme for FZF/# Catppuccin Mocha theme for FZF/' "$HOME/.dotfiles/fish/config.fish"
fi

# 5. LazyGit (if configured)
if [ -f "$HOME/.dotfiles/lazygit/config.yml" ]; then
    sed -i.bak "s/theme: .*/theme: $NEW_THEME/" "$HOME/.dotfiles/lazygit/config.yml"
fi

# 6. LazyDocker (if configured)
if [ -f "$HOME/.dotfiles/lazydocker/config.yml" ]; then
    sed -i.bak "s/theme: .*/theme: $NEW_THEME/" "$HOME/.dotfiles/lazydocker/config.yml"
fi

# Save the new theme state
echo "$NEW_THEME" > "$STATE_FILE"

# Clean up backup files
find "$HOME/.dotfiles" -name "*.bak" -delete

echo "Switched to Catppuccin $(echo $NEW_THEME | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}') theme!"
echo "Note: You may need to reload some applications for changes to take effect:"
echo "  - Ghostty: Cmd+Ctrl+Alt+Shift+A, then R (or restart)"
echo "  - Helix: :config-reload (or restart)"
echo "  - New terminal windows will use the updated theme"