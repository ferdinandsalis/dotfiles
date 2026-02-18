function note --description "Quick capture to Obsidian daily note"
    set -l script ~/.pi/agent/skills/daily-note/note.sh

    if test (count $argv) -eq 0
        # No args: open today's note in Obsidian
        set -l note_path (bash $script path)
        open "obsidian://open?vault=notes&file=daily/"(date +%Y-%m-%d)
    else
        # Args: append to today's note
        bash $script append $argv
    end
end
