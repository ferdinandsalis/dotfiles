function _fzf_git_checkout --description "Checkout git commit/tag using FZF"
    set -f target (git log --pretty=oneline --abbrev-commit --all | fzf --preview 'git show --color=always {1}' | awk '{print $1}')
    
    if test -n "$target"
        git checkout $target
    end
end