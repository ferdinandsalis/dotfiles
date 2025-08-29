function zs --description "FZF-powered Zellij session picker"
    # Get list of existing sessions (strip ANSI color codes)
    set -l sessions (zellij list-sessions 2>/dev/null | grep -v "CURRENT SESSION" | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')
    
    # If no sessions exist, create a new one
    if test (count $sessions) -eq 0
        echo "No existing sessions. Creating new session..."
        zellij
        return
    end
    
    # Add option to create new session
    set sessions "NEW SESSION" $sessions
    
    # Use fzf to select session with preview
    set -l selected_session (printf '%s\n' $sessions | fzf \
        --prompt="Zellij Sessions > " \
        --height=40% \
        --border \
        --reverse \
        --header="Select session (Enter=attach, Ctrl-C=cancel)" \
        --preview-window="right:50%" \
        --preview="
            if test '{}' = 'NEW SESSION'
                echo 'Create a new Zellij session'
            else
                echo 'Session: {}'
                echo ''
                zellij list-sessions 2>/dev/null | grep '{}' | head -1
            end
        ")
    
    # Handle selection
    if test -n "$selected_session"
        if test "$selected_session" = "NEW SESSION"
            echo "Enter new session name (or press Enter for auto-generated):"
            read -l session_name
            if test -n "$session_name"
                zellij attach --create "$session_name"
            else
                zellij
            end
        else
            zellij attach "$selected_session"
        end
    end
end