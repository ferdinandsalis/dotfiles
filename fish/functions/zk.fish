function zk --description "Kill Zellij sessions with FZF selection"
    # Get list of existing sessions (strip ANSI color codes)
    set -l sessions (zellij list-sessions 2>/dev/null | grep -v "CURRENT SESSION" | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')
    
    # Check if there are any sessions to kill
    if test (count $sessions) -eq 0
        echo "No sessions to kill"
        return 1
    end
    
    # Use fzf to select session(s) to kill
    set -l selected_sessions (printf '%s\n' $sessions | fzf \
        --prompt="Kill Sessions > " \
        --height=40% \
        --border \
        --reverse \
        --multi \
        --header="Select sessions to kill (Tab=multi-select, Enter=confirm)" \
        --preview-window="right:50%" \
        --preview="
            echo 'Session: {}'
            echo ''
            zellij list-sessions 2>/dev/null | grep '{}' | head -1
        ")
    
    # Kill selected sessions
    if test -n "$selected_sessions"
        for session in $selected_sessions
            echo "Killing session: $session"
            zellij kill-session "$session"
        end
    end
end