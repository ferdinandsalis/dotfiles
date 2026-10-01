function _fzf_wrapper --description "Prepares some environment variables before executing fzf."
    # Make sure fzf uses fish to execute preview commands, some of which
    # are autoloaded fish functions so don't exist in other shells.
    # Use --function so that it doesn't clobber SHELL outside this function.
    # Widgets whose previews are plain POSIX pipelines can set _fzf_preview_shell
    # (e.g. /bin/sh) to skip a ~100ms config-loading fish spawn per preview.
    if not set --query _fzf_preview_shell
        set -f _fzf_preview_shell (command --search fish)
    end
    set -f --export SHELL $_fzf_preview_shell

    # If neither FZF_DEFAULT_OPTS nor FZF_DEFAULT_OPTS_FILE are set, then set some sane defaults.
    # See https://github.com/junegunn/fzf#environment-variables
    set --query FZF_DEFAULT_OPTS FZF_DEFAULT_OPTS_FILE
    if test $status -eq 2
        # cycle allows jumping between the first and last results, making scrolling faster
        # layout=reverse lists results top to bottom, mimicking the familiar layouts of git log, history, and env
        # border shows where the fzf window begins and ends
        # height=90% leaves space to see the current command and some scrollback, maintaining context of work
        # preview-window=wrap wraps long lines in the preview window, making reading easier
        # marker=* makes the multi-select marker more distinguishable from the pointer (since both default to >)
        set --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'
    end

    fzf $argv
end
