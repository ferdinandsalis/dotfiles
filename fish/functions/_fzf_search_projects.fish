function _fzf_search_projects --description "Search and navigate to projects"
    # Define project directories - customize these paths
    set -f project_dirs ~/Base/1-projects ~/Base/dotfiles

    # Find all git repositories in project directories
    set -f projects
    for dir in $project_dirs
        if test -d $dir
            for git_dir in (/usr/bin/find $dir -maxdepth 3 -name ".git" -type d -not -path "*/node_modules/*" -not -path "*/deps/*" 2>/dev/null)
                set -a projects (dirname $git_dir)
            end
        end
    end

    if test (count $projects) -eq 0
        echo "No projects found in: $project_dirs"
        commandline --function repaint
        return
    end

    # Use FZF to select a project
    set -f selected_project (printf '%s\n' $projects | _fzf_wrapper \
        --prompt="Projects> " \
        --preview="ls -la {}" \
        --preview-window="right:50%:wrap" \
        --header="Select a project to navigate to")

    if test $status -eq 0 -a -n "$selected_project"
        cd $selected_project
        commandline --function repaint
        commandline --replace ""
        echo "Switched to: $selected_project"
    end

    commandline --function repaint
end