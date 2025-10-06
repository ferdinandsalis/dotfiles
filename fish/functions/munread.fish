function munread --description "Show and manage unread emails"
    set -l unread (himalaya envelope list "not flag seen")

    if test -z "$unread"
        echo "📭 No unread emails!"
        return 0
    end

    echo "$unread"
    echo ""

    # Offer quick actions
    echo "Quick actions:"
    echo "  r <id>  - Read email"
    echo "  a       - Mark all as read"
    echo "  q       - Quit"
    echo ""

    while true
        read -l -P "> " action id

        switch $action
            case r
                if test -n "$id"
                    himalaya message read $id
                    echo ""
                    echo "Press Enter to continue..."
                    read
                    munread  # Refresh the list
                    return
                else
                    echo "Please provide an email ID"
                end

            case a
                set -l ids (himalaya envelope list "not flag seen" -o json | jq -r '.[].id')
                for email_id in $ids
                    himalaya flag add $email_id seen
                    echo "✓ Marked $email_id as read"
                end
                echo "✓ Marked all as read"
                return

            case q
                return

            case '*'
                echo "Unknown action: $action"
        end
    end
end