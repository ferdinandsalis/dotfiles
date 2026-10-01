function _fzf_history_entries --description "Newest-first timestamped history entries, NUL-delimited, for fzf"
    # In private mode, fish history is session-local; reading the shared file
    # would leak other sessions' commands, so fall back to the builtin.
    if set -q fish_private_mode
        builtin history --null --show-time="$argv[1] │ "
        return
    end

    # Read the file directly instead of `builtin history`: up-to-date without
    # `history merge`, and immune to fish's concurrent-session history desync
    # bugs (fish-shell#10300, #12447). The file itself is always complete.
    python3 $__fish_config_dir/scripts/history-for-fzf.py --time-format "$argv[1]"
end
