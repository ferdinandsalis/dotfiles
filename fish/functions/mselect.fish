function mselect --description "Select and read an email interactively"
    # Get list of all emails (or use search query if provided)
    if test (count $argv) -gt 0
        set -l query (string join " " $argv)
        set -l emails (himalaya envelope list "$query" 2>/dev/null)
    else
        set -l emails (himalaya envelope list 2>/dev/null)
    end

    # Check if we got any emails
    if test -z "$emails"
        echo "No emails found"
        return 1
    end

    # Use fzf to select, keeping the header for context
    set -l selected (echo "$emails" | fzf --header-lines=2 --prompt="Select email (↑/↓ to navigate, Enter to read): ")

    if test -n "$selected"
        # Extract the ID (first field after removing pipes and spaces)
        set -l email_id (echo $selected | sed 's/|//g' | awk '{print $1}')

        # Validate that we got a numeric ID
        if string match -qr '^[0-9]+$' -- "$email_id"
            himalaya message read $email_id
        else
            echo "Could not extract email ID from selection"
        end
    end
end