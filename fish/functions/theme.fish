function theme --description "Toggle or set Catppuccin theme"
    set -l arg $argv[1]

    if test -z "$arg"
        # No argument - toggle theme
        bash ~/Base/dotfiles/scripts/toggle-theme.sh

        # Reload fish config to apply FZF changes
        source ~/.config/fish/config.fish

    else if test "$arg" = "light" -o "$arg" = "latte"
        # Set light theme
        echo "latte" > ~/.config/catppuccin-theme
        bash ~/Base/dotfiles/scripts/toggle-theme.sh
        source ~/.config/fish/config.fish

    else if test "$arg" = "dark" -o "$arg" = "mocha"
        # Set dark theme
        echo "mocha" > ~/.config/catppuccin-theme
        bash ~/Base/dotfiles/scripts/toggle-theme.sh
        source ~/.config/fish/config.fish

    else if test "$arg" = "status"
        # Show current theme
        set -l current (cat ~/.config/catppuccin-theme 2>/dev/null || echo "mocha")
        echo "Current theme: Catppuccin $current"

    else
        echo "Usage: theme [light|dark|latte|mocha|status]"
        echo "  No arguments: Toggle between light and dark"
        echo "  light/latte:  Switch to Catppuccin Latte (light theme)"
        echo "  dark/mocha:   Switch to Catppuccin Mocha (dark theme)"
        echo "  status:       Show current theme"
    end
end
