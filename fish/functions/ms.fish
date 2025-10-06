function ms --description "Search emails (interactive or direct)"
    if test (count $argv) -eq 0
        echo "Usage: ms <field> <query>"
        echo ""
        echo "Fields:"
        echo "  from     - Search sender"
        echo "  to       - Search recipient"
        echo "  subject  - Search subject line"
        echo "  body     - Search message body"
        echo "  date     - Search by date (YYYY-MM-DD)"
        echo "  before   - Before date"
        echo "  after    - After date"
        echo ""
        echo "Examples:"
        echo "  ms from ida"
        echo "  ms subject invoice"
        echo "  ms body meeting"
        echo "  ms after 2025-09-01"
        echo ""
        echo "Special:"
        echo "  ms unread       - List unread emails"
        echo "  ms flagged      - List flagged emails"
        echo "  ms select       - Interactive selection from all"
        return 1
    end

    # Handle special cases
    if test "$argv[1]" = "unread"
        himalaya envelope list "not flag seen"
        return
    else if test "$argv[1]" = "flagged"
        himalaya envelope list "flag flagged"
        return
    else if test "$argv[1]" = "select"
        # Interactive selection mode
        set -l emails (himalaya envelope list 2>/dev/null)
        set -l selected (echo "$emails" | tail -n +3 | fzf --prompt="Select email: ")

        if test -n "$selected"
            set -l email_id (echo $selected | awk '{print $1}')
            if test -n "$email_id"
                himalaya message read $email_id
            end
        end
        return
    end

    # Build and execute search query
    set -l query (string join " " $argv)
    himalaya envelope list "$query"
end