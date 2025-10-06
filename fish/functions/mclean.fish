function mclean --description "Clean up email folders (trash, spam)"
    echo "🧹 Cleaning up email folders..."

    # Show current status
    set -l trash_count (himalaya envelope list -f Trash -o json 2>/dev/null | jq 'length // 0')
    if test -z "$trash_count"
        set trash_count 0
    end

    set -l junk_count (himalaya envelope list -f "Junk Mail" -o json 2>/dev/null | jq 'length // 0')
    if test -z "$junk_count"
        set junk_count 0
    end

    echo "Trash: $trash_count emails"
    echo "Junk Mail: $junk_count emails"

    if test (math $trash_count + $junk_count) -eq 0
        echo "✨ Already clean!"
        return 0
    end

    # Ask for confirmation
    read -l -P "Empty Trash and Junk Mail folders? [y/N] " confirm

    if test "$confirm" = "y" -o "$confirm" = "Y"
        if test $trash_count -gt 0
            himalaya folder purge Trash
            echo "✓ Emptied Trash"
        end

        if test $junk_count -gt 0
            himalaya folder purge "Junk Mail"
            echo "✓ Emptied Junk Mail"
        end

        echo "🎉 Cleanup complete!"
    else
        echo "Cleanup cancelled"
    end
end