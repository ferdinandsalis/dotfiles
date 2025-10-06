function _autopair_tab
    # In paging mode, explicitly call complete to navigate forward
    if commandline --paging-mode
        commandline --function complete
        return
    end

    string match --quiet --regex -- '\$[^\s]*"$' (commandline --current-token) &&
        commandline --function end-of-line --function backward-delete-char
    commandline --function complete
end
