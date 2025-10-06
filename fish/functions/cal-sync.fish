function cal-sync --description "Sync all calendars with remote servers"
    if command -v vdirsyncer >/dev/null
        echo "🔄 Syncing calendars..."

        # Discover new calendars (only needed first time or when adding new calendars)
        if not test -d ~/.vdirsyncer/status
            echo "📅 First time setup - discovering calendars..."
            vdirsyncer discover
        end

        # Sync all configured calendar pairs
        vdirsyncer sync

        if test $status -eq 0
            echo "✅ Calendar sync complete!"
            # Show today's events after sync
            tcal
        else
            echo "❌ Calendar sync failed. Check your configuration."
        end
    else
        echo "vdirsyncer is not installed. Run: brew bundle"
    end
end