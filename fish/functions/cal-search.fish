function cal-search --description "Search calendar events"
    if test (count $argv) -eq 0
        echo "Usage: cal-search <search term>"
        return 1
    end

    if command -v khal >/dev/null
        # Search events with the given term
        # Suppress warnings by redirecting stderr
        khal search $argv 2>/dev/null
    else
        echo "khal is not installed. Run: brew bundle"
    end
end