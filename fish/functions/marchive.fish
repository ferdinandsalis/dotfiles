function marchive --description "Archive email(s) by ID"
    if test (count $argv) -eq 0
        echo "Usage: marchive <id> [id2] [id3] ..."
        echo "Example: marchive 123 456"
        return 1
    end

    for id in $argv
        himalaya message move $id Archive
        echo "✓ Archived message $id"
    end
end