function agenda --description "Show upcoming calendar events"
    set -l days 7
    if test (count $argv) -gt 0
        set days $argv[1]
    end
    cali events --from today --to +{$days}d
end
