function _fzf_kill_process --description "Select and kill a process using FZF"
    set -f selected_pid (ps aux | sed 1d | fzf --multi --header="Select process to kill" --preview="" | awk '{print $2}')
    
    if test -n "$selected_pid"
        echo $selected_pid | xargs kill -9
        echo "Killed process(es): $selected_pid"
    end
end