function cal-add --description "Add a new calendar event"
    if command -v khal >/dev/null
        if test (count $argv) -eq 0
            # Interactive mode
            khal new
        else
            # Quick add with natural language
            # Example: cal-add "Meeting with Johann tomorrow at 2pm"
            khal new $argv
        end
    else
        echo "khal is not installed. Run: brew bundle"
    end
end