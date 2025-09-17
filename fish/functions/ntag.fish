function ntag --description "Search notes by tags"
    set -f notes_dir ~/notes
    
    # If no argument provided, show all tags and let user select
    if test (count $argv) -eq 0
        # Find all tags in notes (lines starting with Tags: or inline #tags)
        set -f all_tags
        
        # Extract tags from "Tags:" lines and inline #tags
        for note in (fd -e md . "$notes_dir" 2>/dev/null)
            # Extract from "Tags:" lines
            set -f tags_line (rg '^[Tt]ags?:\s*(.*)$' -o -r '$1' "$note" 2>/dev/null)
            for tag_line in $tags_line
                # Split by comma or space and extract #tags
                set -f tags (echo "$tag_line" | rg '#\w+' -o)
                set -a all_tags $tags
            end
            
            # Extract inline #tags from content
            set -f inline_tags (rg '#\w+' -o "$note" 2>/dev/null)
            set -a all_tags $inline_tags
        end
        
        if test (count $all_tags) -eq 0
            echo "❌ No tags found in notes"
            echo "💡 Add tags to your notes using #tag format or 'Tags: #tag1 #tag2' lines"
            return 1
        end
        
        # Remove duplicates, sort, and remove # prefix for display
        set -f unique_tags (printf '%s\n' $all_tags | sort -u | sed 's/^#//')
        
        # Show tags with fzf
        set -f selected_tag (printf '%s\n' $unique_tags | fzf \
            --prompt="🏷️ Tag> " \
            --height=50% \
            --layout=reverse \
            --border=rounded \
            --preview='bash -c "
                tag=\"#{}\"
                echo \"🏷️ Notes tagged with: \$tag\"
                echo
                echo \"📊 Count: \$(rg -l \"\$tag\" $HOME/notes/**/*.md 2>/dev/null | wc -l) notes\"
                echo
                echo \"📝 Preview:\"
                rg -l \"\$tag\" $HOME/notes/**/*.md 2>/dev/null | head -5 | while read file; do
                    echo \"• \$(basename \"\$file\" .md)\"
                done
            "' \
            --preview-window=right:50%:wrap \
            --header="↑↓ Navigate | Enter: Search tag | Ctrl-A: Show all tags" \
            --bind='ctrl-a:execute(rg "#\w+" -o ~/notes/**/*.md | sort | uniq -c | sort -nr | head -20)+abort' \
            --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
            --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
            --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8)
        
        if test -n "$selected_tag"
            # Search for the selected tag
            ntag "$selected_tag"
        end
        
        return
    end
    
    # Search for specific tag(s)
    set -f query (string join " " $argv)
    
    # Add # prefix if not present
    if not string match -q "#*" "$query"
        set query "#$query"
    end
    
    echo "🏷️ Searching for tag: $query"
    echo
    
    # Find notes containing the tag
    set -f matching_notes (rg -l "$query" "$notes_dir" --type=md 2>/dev/null)
    
    if test (count $matching_notes) -eq 0
        echo "❌ No notes found with tag: $query"
        echo "💡 Available tags:"
        rg '#\w+' -o "$notes_dir" --type=md 2>/dev/null | sort -u | head -10
        return 1
    end
    
    # Show matching notes with fzf
    printf '%s\n' $matching_notes | fzf \
        --prompt="🏷️ Tagged '$query'> " \
        --height=70% \
        --layout=reverse \
        --border=rounded \
        --preview='bash -c "
            echo \"📄 {}\"
            echo \"🏷️ Tag: '$query'\"
            echo
            echo \"📖 Content:\"
            bat --style=numbers --color=always --line-range :20 {} 2>/dev/null || cat {} | head -20
            echo
            echo \"🏷️ All tags in this note:\"
            rg \"#\\w+\" -o {} | sort -u | tr \"\\n\" \" \" 
            echo
        "' \
        --preview-window=right:60%:wrap \
        --header="↑↓ Navigate | Enter: Open note | Ctrl-L: Show tag line | Ctrl-A: Show all tags in note" \
        --bind='enter:execute(hx {})+abort' \
        --bind='ctrl-l:execute(
            echo "Lines containing '$query' in {}:"
            rg -n "$query" {} | head -10
            read -p "Press Enter to continue..."
        )' \
        --bind='ctrl-a:execute(
            echo "All tags in {}:"
            rg "#\w+" -o {} | sort -u
            read -p "Press Enter to continue..."
        )' \
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    
    echo
    echo "📊 Found $(count $matching_notes) note(s) with tag: $query"
end