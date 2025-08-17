function _fzf_git_branch --description "Switch git branch using FZF"
    set -f branch (git branch -a | grep -v HEAD | fzf --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" (echo {} | sed "s/.* //") | head -20' | sed "s/.* //")
    
    if test -n "$branch"
        git checkout (echo $branch | sed "s#remotes/[^/]*/##")
    end
end