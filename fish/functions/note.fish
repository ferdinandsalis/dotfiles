function note --description "Quick capture to Obsidian daily note"
    set -l script ~/.pi/agent/skills/daily-note/note.sh

    if test (count $argv) -eq 0
        # No args: read today's note
        bash $script read
    else
        # Args: append to today's note
        bash $script append $argv
    end
end
