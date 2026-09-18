# Set Ghostty tab title from .meta files found walking up the directory tree.
#
# Priority:
#   1. .meta file with `tab-title = ...` (supports templates)
#   2. Default fish_title behavior
#
# Templates in .meta tab-title:
#   {dirname}    — leaf name of current directory
#   {project}    — leaf name of the directory containing .meta
#   {git_branch} — current git branch (empty if not in a repo)

function __tab_title_find --on-variable PWD -d "Find tab title from .meta"
    set -g __tab_title_custom ""
    set -g __tab_title_meta_dir ""

    set -l dir $PWD
    while true
        # .meta with tab-title always wins
        if test -f "$dir/.meta"
            set -l title (grep -m1 '^tab-title\s*=' "$dir/.meta" 2>/dev/null | string replace -r '^tab-title\s*=\s*' '' | string trim)
            if test -n "$title"
                set -g __tab_title_custom "$title"
                set -g __tab_title_meta_dir "$dir"
                return
            end
        end

        set -l parent (dirname "$dir")
        if test "$parent" = "$dir"
            return
        end
        set dir $parent
    end
end

function fish_title
    if test -n "$__tab_title_custom"
        set -l title $__tab_title_custom

        set title (string replace -a '{dirname}' (basename $PWD) $title)
        set title (string replace -a '{project}' (basename "$__tab_title_meta_dir") $title)

        if string match -q '*{git_branch}*' $title
            set -l branch (git -C $PWD symbolic-ref --short HEAD 2>/dev/null; or echo "")
            set title (string replace -a '{git_branch}' "$branch" $title)
        end

        echo -- $title
        return
    end

    # Default fish_title behavior.
    set -l ssh
    set -q SSH_TTY
    and set ssh "["(prompt_hostname | string sub -l 10 | string collect)"]"

    if set -q argv[1]
        echo -- $ssh (string sub -l 20 -- $argv[1]) (prompt_pwd -d 1 -D 1)
    else
        set -l command (status current-command)
        if test "$command" = fish
            set command
        end
        echo -- $ssh (string sub -l 20 -- $command) (prompt_pwd -d 1 -D 1)
    end
end

# Run on shell startup
__tab_title_find
