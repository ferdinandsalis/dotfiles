function nlink --description "Navigate between notes using wiki-style links"
    set -f notes_dir ~/notes
    
    # If no argument, find links in current directory or show usage
    if test (count $argv) -eq 0
        # Check if we're in the notes directory
        if string match -q "*$notes_dir*" (pwd)
            # Look for markdown files in current directory
            set -f current_notes (fd -e md . . --max-depth 1)
            
            if test (count $current_notes) -gt 0
                echo "🔗 Finding links in current directory notes..."
                
                # Extract all [[link]] patterns from current directory notes
                set -f all_links
                for note in $current_notes
                    set -f links (rg '\[\[([^\]]+)\]\]' -o -r '$1' "$note" 2>/dev/null)
                    set -a all_links $links
                end
                
                if test (count $all_links) -gt 0
                    # Remove duplicates and show with fzf
                    printf '%s\n' $all_links | sort -u | fzf \
                        --prompt="🔗 Link> " \
                        --height=50% \
                        --layout=reverse \
                        --border=rounded \
                        --preview='bash -c "
                            # Try to find the linked note
                            link_name=\"{}\"
                            found_note=\"\"
                            
                            # Look for exact match first
                            if [ -f \"$HOME/notes/*/\$link_name.md\" ]; then
                                found_note=\$(find $HOME/notes -name \"\$link_name.md\" | head -1)
                            elif [ -f \"$HOME/notes/\$link_name.md\" ]; then
                                found_note=\"$HOME/notes/\$link_name.md\"
                            fi
                            
                            if [ -n \"\$found_note\" ]; then
                                echo \"📄 Found: \$found_note\"
                                echo
                                bat --style=numbers --color=always --line-range :15 \"\$found_note\" 2>/dev/null || cat \"\$found_note\" | head -15
                            else
                                echo \"❓ Note not found: \$link_name\"
                                echo
                                echo \"🔍 Similar notes:\"
                                find $HOME/notes -name \"*.md\" -exec basename {} .md \; | grep -i \"\$link_name\" | head -5
                            fi
                        "' \
                        --preview-window=right:60%:wrap \
                        --header="↑↓ Navigate | Enter: Open link | Ctrl-N: Create note" \
                        --bind='enter:execute(
                            link_name="{}"
                            found_note=""
                            
                            # Try to find the note
                            if [ -f "$HOME/notes/$link_name.md" ]; then
                                found_note="$HOME/notes/$link_name.md"
                            else
                                found_note=$(find $HOME/notes -name "$link_name.md" | head -1)
                            fi
                            
                            if [ -n "$found_note" ]; then
                                hx "$found_note"
                            else
                                echo "Note not found. Creating new note: $link_name"
                                echo "# $link_name" > "$HOME/notes/permanent/$link_name.md"
                                echo "" >> "$HOME/notes/permanent/$link_name.md"
                                echo "Created: $(date)" >> "$HOME/notes/permanent/$link_name.md"
                                echo "Tags: #permanent" >> "$HOME/notes/permanent/$link_name.md"
                                echo "" >> "$HOME/notes/permanent/$link_name.md"
                                hx "$HOME/notes/permanent/$link_name.md"
                            fi
                        )+abort' \
                        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
                        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
                        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
                else
                    echo "❌ No wiki-style links ([[link]]) found in current directory notes"
                end
            else
                echo "❌ No markdown notes found in current directory"
            end
        else
            echo "📖 Usage: nlink [note-name]"
            echo "   or run 'nlink' from within the notes directory to find all links"
            echo ""
            echo "Examples:"
            echo "  nlink my-note     # Open or create note with wiki-style links"
            echo "  nlink             # Show all [[links]] in current directory notes"
        end
    else
        # Open or create specific note and show its links
        set -f note_name (string join "_" $argv)
        set -f note_path
        
        # Try to find the note in various locations
        if test -f "$notes_dir/$note_name.md"
            set note_path "$notes_dir/$note_name.md"
        else
            set note_path (find "$notes_dir" -name "$note_name.md" | head -1)
        end
        
        # If not found, create it
        if test -z "$note_path"
            set note_path "$notes_dir/permanent/$note_name.md"
            echo "# $note_name" > "$note_path"
            echo "" >> "$note_path"
            echo "Created: $(date '+%Y-%m-%d %H:%M')" >> "$note_path"
            echo "Tags: #permanent" >> "$note_path"
            echo "" >> "$note_path"
            echo "📝 Created new note: $note_name"
        end
        
        # Extract and show links from this note
        set -f links (rg '\[\[([^\]]+)\]\]' -o -r '$1' "$note_path" 2>/dev/null)
        
        if test (count $links) -gt 0
            echo "🔗 Links found in $note_name:"
            printf '  [[%s]]\n' $links
            echo ""
        end
        
        # Open the note
        hx "$note_path"
        
        # Update terminal title
        echo -ne "\033]0;🔗 $note_name\007"
    end
end