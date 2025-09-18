#!/usr/bin/env zsh
# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/ferdinand/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/Users/ferdinand/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/Users/ferdinand/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/Users/ferdinand/.fzf/shell/key-bindings.zsh"
