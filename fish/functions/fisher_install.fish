function fisher_install --description "Install Fisher package manager"
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    
    # Install useful Fish plugins
    fisher install jethrokuan/z          # Directory jumping
    fisher install PatrickF1/fzf.fish     # FZF integration
    fisher install franciscolourenco/done # Notifications for long commands
    fisher install jorgebucaran/autopair.fish # Auto-close brackets
    
    echo "Fisher and plugins installed!"
end