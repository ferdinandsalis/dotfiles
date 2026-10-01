function _tide_parent_dirs --on-variable PWD
    # `--` guards against path components starting with a dash (e.g. Claude Code's
    # dash-encoded worktree dirs) being parsed as options to `string escape`.
    set -g _tide_parent_dirs (string escape -- (
        for dir in (string split / -- $PWD)
            set -la parts $dir
            string join / -- $parts
        end))
end
