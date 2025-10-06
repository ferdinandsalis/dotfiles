function mail-switch --description "Switch between email accounts"
    set -l accounts ferdinandsalis salisio
    set -l selected (printf '%s\n' $accounts | fzf --prompt="Select account: " --height=40% --layout=reverse)

    if test -n "$selected"
        echo "Switching to account: $selected"
        himalaya -a $selected list
    end
end