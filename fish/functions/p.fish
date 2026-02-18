function p --description "Smart project switcher with zoxide integration"
    # Use zoxide if available for smart sorting by frecency
    if command -v zoxide >/dev/null
        set -f zoxide_dirs (zoxide query -l | head -20)
    else
        set -f zoxide_dirs
    end
    
    # Define project directories (handle both ~/work and ~/Work)
    set -f project_dirs ~/Base/1-projects ~/Base/dotfiles ~/Documents
    
    # Find all git repositories (search up to 3 levels deep)
    set -f git_projects
    for dir in $project_dirs
        if test -d $dir
            # Use fd with max depth to avoid deep recursion
            set -a git_projects (fd -H -t d --max-depth 3 '^\.git$' $dir 2>/dev/null | string replace '/.git' '')
            # Also add direct subdirectories that have .git
            for subdir in $dir/*/
                if test -d "$subdir/.git"
                    set -a git_projects (realpath $subdir)
                end
            end
        end
    end
    
    # Combine and deduplicate directories
    set -f all_dirs (printf '%s\n' $zoxide_dirs $git_projects | sort -u)
    
    # Use FZF with enhanced preview (using bash for preview to avoid fish syntax issues)
    set -f selected (printf '%s\n' $all_dirs | fzf \
        --prompt="🚀 Project> " \
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --preview='bash -c "echo \"📁 {}\" && echo && \
                  if [ -d \"{}/.git\" ]; then \
                      echo \"📊 Git Status:\" && \
                      git -C {} status -sb 2>/dev/null | head -5 && \
                      echo && \
                      echo \"📝 Recent Commits:\" && \
                      git -C {} log --oneline -5 2>/dev/null; \
                  else \
                      ls -la {} | head -20; \
                  fi"' \
        --preview-window=right:60%:wrap \
        --header="↑↓ Navigate | Enter: CD | Ctrl-O: Open in editor | Ctrl-T: New tab" \
        --bind='ctrl-o:execute(hx {})+abort' \
        --bind='ctrl-t:execute(open -a "Ghostty" {})+abort')
    
    if test -n "$selected"
        # Update zoxide database
        if command -v zoxide >/dev/null
            zoxide add "$selected"
        end
        
        cd "$selected"
        
        # Clear screen and show project info
        clear
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📂 Switched to: $(basename $selected)"
        echo "📍 Path: $selected"
        
        # Show git info if available
        if test -d .git
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🌿 Branch: $(git branch --show-current 2>/dev/null)"
            set -f status_output (git status -s 2>/dev/null | head -3)
            if test -n "$status_output"
                echo "📝 Changes:"
                echo "$status_output"
            else
                echo "✨ Working tree clean"
            end
        end
        
        # Check for project-specific files
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if test -f package.json
            echo "📦 Node project detected"
            if test -f yarn.lock
                echo "   → Run: yarn install && yarn dev"
            else if test -f pnpm-lock.yaml
                echo "   → Run: pnpm install && pnpm dev"
            else
                echo "   → Run: npm install && npm run dev"
            end
        else if test -f Cargo.toml
            echo "🦀 Rust project detected"
            echo "   → Run: cargo build && cargo run"
        else if test -f go.mod
            echo "🐹 Go project detected"
            echo "   → Run: go build && go run ."
        else if test -f requirements.txt -o -f pyproject.toml -o -f uv.lock
            echo "🐍 Python project detected"
            if test -f uv.lock
                echo "   → Run: uv sync && uv run python main.py"
            else if test -f pyproject.toml
                echo "   → Run: uv sync"
            else
                echo "   → Run: uv pip install -r requirements.txt"
            end
        else if test -f Gemfile
            echo "💎 Ruby project detected"
            echo "   → Run: bundle install"
        end
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Run project-specific startup script if exists
        if test -f .project-init.fish
            echo "🚀 Running project initialization..."
            source .project-init.fish
        else if test -f .envrc
            echo "🔐 Environment file detected (.envrc)"
        end
        
        # Update terminal title
        echo -ne "\033]0;📂 $(basename $selected)\007"
    end
end