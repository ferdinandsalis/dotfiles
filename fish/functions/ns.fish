function ns --description "Search notes with ripgrep and fzf"
    set -f notes_dir ~/notes
    
    # If no argument provided, start interactive search
    if test (count $argv) -eq 0
        # Use fzf with ripgrep reload binding (start empty)  
        printf "" | fzf \
            --bind='change:reload(test -n {q} && rg --type=md --line-number --no-heading --color=always {q} '$notes_dir' 2>/dev/null || true)' \
            --ansi \
            --prompt="🔍 Search> " \
            --height=70% \
            --layout=reverse \
            --border=rounded \
            --delimiter=: \
            --preview='bat --style=numbers --color=always --highlight-line={2} {1} 2>/dev/null || cat {1}' \
            --preview-window=right:60%:wrap \
            --header="Type to search | ↑↓ Navigate | Enter: Open at line | Ctrl-O: Open file" \
            --bind='enter:execute(
                file=$(echo {} | cut -d: -f1)
                line=$(echo {} | cut -d: -f2)
                hx "$file:$line"
            )+abort' \
            --bind='ctrl-o:execute(
                file=$(echo {} | cut -d: -f1)
                hx "$file"
            )+abort' \
            --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
            --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
            --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
        return
    end
    
    # Search with provided query
    set -f query (string join " " $argv)
    echo "🔍 Searching for: '$query'"
    echo
    
    # Use ripgrep to find matches and pipe through fzf
    rg --type=md --line-number --no-heading --color=always "$query" "$notes_dir" 2>/dev/null | \
    fzf --ansi \
        --prompt="🎯 Results> " \
        --height=70% \
        --layout=reverse \
        --border=rounded \
        --delimiter=: \
        --query="$query" \
        --preview='bat --style=numbers --color=always --highlight-line={2} {1} 2>/dev/null || cat {1}' \
        --preview-window=right:60%:wrap \
        --header="↑↓ Navigate | Enter: Open at line | Ctrl-O: Open file" \
        --bind='enter:execute(
            file=$(echo {} | cut -d: -f1)
            line=$(echo {} | cut -d: -f2)
            hx "$file:$line"
        )+abort' \
        --bind='ctrl-o:execute(
            file=$(echo {} | cut -d: -f1)
            hx "$file"
        )+abort' \
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    
    # If no results found
    if test $status -ne 0
        echo "❌ No results found for '$query'"
        return 1
    end
end