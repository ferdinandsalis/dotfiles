function cal --description "Show calendar for the week"
    if command -v khal >/dev/null
        # Show this week's events in list format (cleaner, no descriptions)
        # Suppress warnings by redirecting stderr
        echo "📅 This Week's Events"
        echo "===================="
        khal list today 7d --format "{start-date} {start-time} {title} [{calendar}]" 2>/dev/null
    else
        echo "khal is not installed. Run: brew bundle"
    end
end