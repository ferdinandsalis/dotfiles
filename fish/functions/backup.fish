function backup --description "Create a backup of a file with timestamp"
    if test (count $argv) -eq 0
        echo "Usage: backup <file>"
        return 1
    end
    
    set -l file $argv[1]
    if test -f $file
        cp $file "$file.backup."(date +%Y%m%d_%H%M%S)
        echo "Backed up $file"
    else
        echo "File not found: $file"
        return 1
    end
end