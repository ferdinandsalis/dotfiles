function mcheck --description "Check for unread emails in all accounts"
    echo "📬 Checking mail..."
    echo ""

    # Check primary account
    set -l unread_primary (himalaya --account ferdinandsalis envelope list "not flag seen" -o json 2>/dev/null | jq 'length // 0')
    if test -z "$unread_primary"
        set unread_primary 0
    end
    echo "mail@ferdinandsalis.com: $unread_primary unread"

    # Check secondary account
    set -l unread_secondary (himalaya --account salisio envelope list "not flag seen" -o json 2>/dev/null | jq 'length // 0')
    if test -z "$unread_secondary"
        set unread_secondary 0
    end
    echo "ferdinand@salis.io: $unread_secondary unread"

    # Total
    set -l total (math $unread_primary + $unread_secondary)
    echo ""
    echo "Total: $total unread emails"

    # Show recent unread if any
    if test $total -gt 0
        echo ""
        echo "Recent unread:"
        himalaya envelope list "not flag seen" --limit 5
    end
end