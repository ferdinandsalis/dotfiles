function today --description "Open or create today's daily note"
    set -f today_date (date '+%Y-%m-%d')
    set -f today_note ~/notes/daily/$today_date.md
    
    # Create today's note if it doesn't exist
    if not test -f "$today_note"
        # Create the daily directory if it doesn't exist
        mkdir -p ~/notes/daily
        
        # Create note with template
        echo "# Daily Note - $today_date" > "$today_note"
        echo "" >> "$today_note"
        echo "**Date:** $(date '+%A, %B %d, %Y')" >> "$today_note"
        echo "**Weather:** " >> "$today_note"  
        echo "" >> "$today_note"
        echo "## 📋 Today's Tasks" >> "$today_note"
        echo "" >> "$today_note"
        
        # Pull in today's todos if todo.sh is available
        if command -v todo.sh >/dev/null
            set -f todos (todo.sh list | grep -v "^--")
            if test -n "$todos"
                echo "### From todo.txt:" >> "$today_note"
                echo '```' >> "$today_note"
                todo.sh list >> "$today_note"
                echo '```' >> "$today_note"
                echo "" >> "$today_note"
            end
        end
        
        echo "### Additional Tasks:" >> "$today_note"
        echo "- [ ] " >> "$today_note"
        echo "" >> "$today_note"
        echo "## 💭 Notes & Ideas" >> "$today_note"
        echo "" >> "$today_note"
        echo "## 📝 Journal" >> "$today_note"
        echo "" >> "$today_note"
        echo "### Morning" >> "$today_note"
        echo "" >> "$today_note"
        echo "### Afternoon" >> "$today_note"
        echo "" >> "$today_note"
        echo "### Evening" >> "$today_note"
        echo "" >> "$today_note"
        echo "## 🔗 Links" >> "$today_note"
        echo "" >> "$today_note"
        echo "## 📊 Daily Review" >> "$today_note"
        echo "" >> "$today_note"
        echo "**What went well:**" >> "$today_note"
        echo "- " >> "$today_note"
        echo "" >> "$today_note"
        echo "**What could be improved:**" >> "$today_note"
        echo "- " >> "$today_note"
        echo "" >> "$today_note"
        echo "**Tomorrow's focus:**" >> "$today_note"
        echo "- " >> "$today_note"
        echo "" >> "$today_note"
        echo "---" >> "$today_note"
        echo "" >> "$today_note"
        echo "Tags: #daily #$(date '+%Y') #$(date '+%B' | tr '[:upper:]' '[:lower:]')" >> "$today_note"
        
        echo "📅 Created today's note: $today_date"
    else
        echo "📅 Opening today's note: $today_date"
    end
    
    # Open the note in Helix
    hx "$today_note"
    
    # Update terminal title
    echo -ne "\033]0;📅 Daily Note - $today_date\007"
end