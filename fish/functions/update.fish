function update --description "Update system packages and tools"
    echo "Updating Homebrew..."
    brew update && brew upgrade && brew cleanup
    
    echo "Updating Mise tools..."
    mise upgrade
    
    echo "Updating npm packages..."
    npm update -g
    
    echo "Updating Fish completions..."
    fish_update_completions
    
    echo "Update complete!"
end