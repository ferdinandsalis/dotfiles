function _fzf_npm_scripts --description "Run npm scripts using FZF"
    if not test -f package.json
        echo "No package.json found in current directory"
        return 1
    end
    
    set -f script (jq -r '.scripts | keys[]' package.json 2>/dev/null | fzf --preview 'jq -r ".scripts.\"{}\"" package.json' --preview-window=wrap)
    
    if test -n "$script"
        echo "Running: npm run $script"
        npm run $script
    end
end