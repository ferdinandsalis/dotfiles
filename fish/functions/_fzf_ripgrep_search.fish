function _fzf_ripgrep_search --description "Interactive ripgrep search with FZF"
    set -f initial_query $argv
    set -f rg_prefix "rg --column --line-number --no-heading --color=always --smart-case"
    
    set -f selected (FZF_DEFAULT_COMMAND="$rg_prefix '$initial_query'" \
        fzf --bind "change:reload:$rg_prefix {q} || true" \
            --ansi --disabled --query "$initial_query" \
            --prompt 'Ripgrep> ' \
            --delimiter : \
            --header 'CTRL-R: Switch between ripgrep/fzf' \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3')
    
    if test -n "$selected"
        set -f file (echo $selected | cut -d: -f1)
        set -f line (echo $selected | cut -d: -f2)
        $EDITOR $file +$line
    end
end