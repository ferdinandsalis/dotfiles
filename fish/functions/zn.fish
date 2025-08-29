function zn --description "Create new named Zellij session"
    if test (count $argv) -eq 0
        echo "Enter session name:"
        read -l session_name
        if test -z "$session_name"
            echo "No name provided, creating anonymous session..."
            zellij
            return
        end
    else
        set session_name $argv[1]
    end
    
    # Check if session already exists
    if zellij list-sessions 2>/dev/null | grep -q "^$session_name"
        echo "Session '$session_name' already exists. Attaching..."
        zellij attach "$session_name"
    else
        echo "Creating new session: $session_name"
        zellij attach --create "$session_name"
    end
end