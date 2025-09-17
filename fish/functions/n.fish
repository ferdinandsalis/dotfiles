function n --description "Smart note management with Helix and fzf"
    # Notes directory
    set -f notes_dir ~/notes
    
    # If argument provided, create/open specific note
    if test (count $argv) -gt 0
        set -f note_name (string join "_" $argv)
        set -f note_path "$notes_dir/inbox/$note_name.md"
        
        # Create note with basic metadata if it doesn't exist
        if not test -f "$note_path"
            echo "# $argv" > "$note_path"
            echo "" >> "$note_path"
            echo "Created: $(date '+%Y-%m-%d %H:%M')" >> "$note_path"
            echo "Tags: #inbox" >> "$note_path"
            echo "" >> "$note_path"
            echo "---" >> "$note_path"
            echo "" >> "$note_path"
        end
        
        hx "$note_path"
        return
    end
    
    # Find all markdown files in notes directory
    set -f all_notes (fd -e md . "$notes_dir" 2>/dev/null)
    
    # Use fzf with enhanced preview matching your existing style
    set -f selected (printf '%s\n' $all_notes | fzf \
        --prompt="📝 Note> " \
        --height=60% \
        --layout=reverse \
        --border=rounded \
        --preview='bat --style=numbers --color=always --line-range :20 {} 2>/dev/null || head -20 {}' \
        --preview-window=right:65%:wrap \
        --header="↑↓ Navigate | Enter: Open | Ctrl-N: New Note | Ctrl-D: Delete" \
        --bind='ctrl-n:execute(echo {} | sed "s|.*/||" | sed "s|\.md$||" | read -p "New note name: " name && touch ~/notes/inbox/$name.md && hx ~/notes/inbox/$name.md)+abort' \
        --bind='ctrl-d:execute(rm -i {})+reload(fd -e md . ~/notes)' \
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8)
    
    if test -n "$selected"
        hx "$selected"
        
        # Update terminal title with note name
        set -f note_name (basename "$selected" .md)
        echo -ne "\033]0;📝 $note_name\007"
    end
end