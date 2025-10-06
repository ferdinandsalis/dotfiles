function tcal --description "Show today's calendar events in minimal format"
    if command -v khal >/dev/null
        # Show today's events with calendar name: "HH:MM Event Title [Calendar]"
        # Suppress warnings by redirecting stderr
        khal list today today --format "{start-time} {title} [{calendar}]" --notstarted 2>/dev/null
    else
        echo "khal is not installed. Run: brew bundle"
    end
end