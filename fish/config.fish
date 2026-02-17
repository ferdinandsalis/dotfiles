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
    # Show pending reminders
    if command -v remi >/dev/null
        set -l remi_output (python3 -c "
import json, subprocess
r = subprocess.run(['remi', 'ls', '--json'], capture_output=True, text=True)
if r.returncode == 0 and r.stdout.strip():
    items = json.loads(r.stdout)
    if items:
        DIM = '\033[38;2;108;112;134m'
        TITLE = '\033[38;2;205;214;244m'
        TAG = '\033[38;2;137;180;250m'
        DUE = '\033[38;2;249;226;175m'
        LABEL = '\033[38;2;137;180;250m'
        FLAG = '\033[38;2;243;139;168m'
        R = '\033[0m'
        print(f'{LABEL}📋 {len(items)} pending:{R}')
        for item in items[:3]:
            parts = []
            if item.get('flagged'): parts.append(f'{FLAG}🚩{R}')
            parts.append(f'{TITLE}{item[\"title\"]}{R}')
            if item.get('dueDate'): parts.append(f'{DUE}{item[\"dueDate\"][:10]}{R}')
            tags = item.get('tags', [])
            if tags: parts.append(f'{TAG}{\" \".join(\"#\" + t for t in tags)}{R}')
            print('  ' + '  '.join(parts))
        if len(items) > 3:
            print(f'  {DIM}... and {len(items) - 3} more{R}')
" 2>/dev/null)
        if test -n "$remi_output"
            for line in $remi_output
                echo "$line"
            end
        end
    end

    # Show upcoming calendar events (today's remaining, or tomorrow's)
    if command -v cali >/dev/null
        set -l output (python3 -c "
import json, subprocess, sys
from datetime import datetime

def get_events(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    return json.loads(r.stdout) if r.returncode == 0 and r.stdout.strip() else []

def format_events(events, now_str=None):
    if now_str:
        events = [e for e in events if e['allDay'] or e['start'][11:16] >= now_str or e['end'][11:16] > now_str]
    lines = []
    for e in events[:3]:
        if e['allDay']:
            lines.append(f'  {ALLDAY}all-day{R}  {TITLE}{e[\"summary\"]}{R}')
        else:
            lines.append(f'  {TIME}{e[\"start\"][11:16]}{R}  {TITLE}{e[\"summary\"]}{R}')
    return lines

DIM = '\033[38;2;108;112;134m'  # overlay0
TIME = '\033[38;2;249;226;175m'  # yellow
TITLE = '\033[38;2;205;214;244m'  # text
ALLDAY = '\033[38;2;245;194;231m'  # pink
LABEL = '\033[38;2;137;180;250m'  # blue
R = '\033[0m'

now = datetime.now().strftime('%H:%M')
today = get_events(['cali', 'today', '--json'])
lines = format_events(today, now)
if lines:
    print(f'{LABEL}📅 Today:{R}')
    print('\n'.join(lines))
else:
    tomorrow = get_events(['cali', 'tomorrow', '--json'])
    lines = format_events(tomorrow)
    if lines:
        print(f'{LABEL}📅 Tomorrow:{R}')
        print('\n'.join(lines))
" 2>/dev/null)
        if test -n "$output"
            for line in $output
                echo "$line"
            end
        end
    end

end

# Interactive Shell Configuration
if status is-interactive
    # Custom FZF key bindings for macOS
    bind \co _fzf_search_projects
    bind --mode insert \co _fzf_search_projects
    
    # FZF aliases
    alias fp="_fzf_search_projects"
    alias fkill="_fzf_kill_process"
    alias fbr="_fzf_git_branch"
    alias fco="_fzf_git_checkout"
    alias fdocker="_fzf_docker_containers"
    alias fnpm="_fzf_npm_scripts"
    alias frg="_fzf_ripgrep_search"
    
    # Tool aliases
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
    alias t="remi ls"

    # Git Aliases
    alias g="git"
    alias gs="git st"
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

    # Note-taking abbreviations
    abbr --add nn "n"          # Quick note access
    abbr --add td "today"      # Today's daily note
    abbr --add nt "ntag"       # Search by tags
    abbr --add nl "nlink"      # Wiki-style links

    # Calendar abbreviations
    abbr --add tc "tcal"       # Today's calendar
    abbr --add cala "cal-add"  # Add calendar event
    abbr --add calf "cal-search" # Find calendar events

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

# GPG TTY for signing
set -x GPG_TTY (tty)

# Antigravity CLI
fish_add_path /Users/ferdinand/.antigravity/antigravity/bin
