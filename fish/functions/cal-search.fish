function cal-search --description "Search calendar events"
    if test (count $argv) -eq 0
        echo "Usage: cal-search <query> [--from <date>] [--to <date>]"
        return 1
    end
    cali events --search $argv
end
