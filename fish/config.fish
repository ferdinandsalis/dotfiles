# Fish Shell Configuration

# Environment Variables
set -gx EDITOR hx
set -gx VISUAL hx
set -gx PAGER less
set -gx LESS -R
set -gx RIPGREP_CONFIG_PATH ~/.ripgreprc
set -gx MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES none

# Path Management
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

# Mise (replacement for asdf and direnv)
if command -v mise >/dev/null
    mise activate fish | source
end

# Zoxide (smarter cd)
if command -v zoxide >/dev/null
    zoxide init fish | source
end


# FZF Configuration
if command -v fzf >/dev/null
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    
    # Catppuccin Mocha theme for FZF
    set -gx FZF_DEFAULT_OPTS "\
--height 40% --layout=reverse --border rounded \
--preview 'bat --style=numbers --color=always --line-range :500 {}' \
--preview-window=right:60%:wrap \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
end

# Source secrets if exists
# Note: Fish cannot directly source bash scripts.
# Consider converting ~/.environment.secret.sh to Fish syntax or using direnv

# Show tasks on terminal startup
function fish_greeting
    if command -v todo.sh >/dev/null
        t list
    end
end

# Interactive Shell Configuration
if status is-interactive
    # Custom FZF key bindings for macOS
    bind \co _fzf_search_projects
    bind --mode insert \co _fzf_search_projects
    
    # Project Management (primary commands)
    # p is defined as a function in ~/.config/fish/functions/p.fish
    # pnew is defined as a function  
    # pl is defined as a function
    
    # FZF aliases and functions
    alias fp="_fzf_search_projects"   # Find Project (legacy, use 'p' instead)
    alias fkill="_fzf_kill_process"   # Kill process interactively
    alias fbr="_fzf_git_branch"       # Switch git branches
    alias fco="_fzf_git_checkout"     # Checkout git commits/tags
    alias fdocker="_fzf_docker_containers"  # Manage Docker containers
    alias fnpm="_fzf_npm_scripts"     # Run npm scripts
    alias frg="_fzf_ripgrep_search"   # Interactive code search
    
    # Aliases
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -l --icons --group-directories-first"
    alias la="eza -la --icons --group-directories-first"
    alias lt="eza --tree --icons"
    alias cat="bat"
    alias grep="rg"
    alias find="fd"
    alias ps="procs"
    alias du="dust"
    alias top="btop"
    alias lzd="lazydocker"  # Docker TUI management
    alias vim="hx"
    alias vi="hx"
    alias t="todo.sh"

    # Git Aliases
    alias g="git"
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit"
    alias gp="git push"
    alias gl="git pull"
    alias gd="git diff"
    alias gco="git checkout"
    alias gb="git branch"
    alias glog="git log --oneline --graph --decorate"

    # Directory Navigation
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # Abbreviations (expand while typing)
    abbr --add gcm "git commit -m"
    abbr --add gca "git commit --amend"
    abbr --add gcan "git commit --amend --no-edit"
    abbr --add gcb "git checkout -b"
    abbr --add grhh "git reset --hard HEAD"
    abbr --add grsh "git reset --soft HEAD~1"
    abbr --add gst "git stash"
    abbr --add gstp "git stash pop"
    abbr --add gpr "git pull --rebase"
    abbr --add gfo "git fetch origin"

    # Set Vi key bindings (optional, comment out if you prefer default)
    # fish_vi_key_bindings

    # Catppuccin Mocha colors for Fish
    set -g fish_prompt_pwd_dir_length 3
    
    # Syntax Highlighting Colors (Catppuccin Mocha)
    set -g fish_color_normal cdd6f4
    set -g fish_color_command 89b4fa
    set -g fish_color_param f2cdcd
    set -g fish_color_keyword f38ba8
    set -g fish_color_quote a6e3a1
    set -g fish_color_redirection f5c2e7
    set -g fish_color_end fab387
    set -g fish_color_comment 6c7086
    set -g fish_color_error f38ba8
    set -g fish_color_gray 6c7086
    set -g fish_color_selection --background=313244
    set -g fish_color_search_match --background=313244
    set -g fish_color_option a6e3a1
    set -g fish_color_operator f5c2e7
    set -g fish_color_escape eba0ac
    set -g fish_color_autosuggestion 6c7086
    set -g fish_color_cancel f38ba8
    
    # Completion Pager Colors
    set -g fish_pager_color_progress 6c7086
    set -g fish_pager_color_prefix 89b4fa
    set -g fish_pager_color_completion cdd6f4
    set -g fish_pager_color_description 6c7086
end

# Keybindings
bind \cx\ce edit_command_buffer # Ctrl+X Ctrl+E to edit command in editor

# Auto-start SSH agent
if test -z "$SSH_AUTH_SOCK"
    eval (ssh-agent -c) >/dev/null
end
