function agenda --description "Show upcoming events (default: 7 days)"
    set -l days $argv[1]
    if test -z "$days"
        set days 7
    end

    if command -v khal >/dev/null
        # Show agenda for specified number of days
        # Suppress warnings by redirecting stderr
        khal list today {$days}d --format "{start-date} {start-time} {title}" 2>/dev/null
    else
        echo "khal is not installed. Run: brew bundle"
    end
end