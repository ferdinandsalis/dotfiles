function pnew --description "Create a new project with template"
    if test (count $argv) -eq 0
        echo "Usage: pnew <project-name> [template]"
        echo "Templates: node, rust, go, python, ruby, basic"
        return 1
    end
    
    set -f project_name $argv[1]
    set -f template $argv[2]
    
    # Default to basic if no template specified
    if test -z "$template"
        set template "basic"
    end
    
    # Determine project location
    echo "Where should this project be created?"
    echo "1) ~/projects (default)"
    echo "2) ~/work"
    echo "3) Current directory"
    read -P "Choice [1-3]: " choice
    
    switch $choice
        case 2
            set -f base_dir ~/work
        case 3
            set -f base_dir (pwd)
        case '*'
            set -f base_dir ~/projects
    end
    
    # Create project directory
    set -f project_path "$base_dir/$project_name"
    
    if test -d "$project_path"
        echo "❌ Project $project_path already exists!"
        return 1
    end
    
    mkdir -p "$project_path"
    cd "$project_path"
    
    # Initialize git
    git init
    
    # Create template-specific files
    switch $template
        case node
            echo "📦 Creating Node.js project..."
            echo '{
  "name": "'$project_name'",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "dev": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "MIT"
}' > package.json
            echo 'console.log("Hello from '$project_name'!");' > index.js
            echo "node_modules/
.env
.DS_Store" > .gitignore
            
        case rust
            echo "🦀 Creating Rust project..."
            cargo init --name "$project_name"
            
        case go
            echo "🐹 Creating Go project..."
            go mod init "$project_name"
            echo 'package main

import "fmt"

func main() {
    fmt.Println("Hello from '$project_name'!")
}' > main.go
            
        case python
            echo "🐍 Creating Python project..."
            echo "# $project_name

## Setup
\`\`\`bash
uv sync
uv run python main.py
\`\`\`" > README.md
            echo '[project]
name = "'$project_name'"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.11"
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"' > pyproject.toml
            echo 'def main():
    print("Hello from '$project_name'!")

if __name__ == "__main__":
    main()' > main.py
            echo ".venv/
__pycache__/
*.pyc
.env
.DS_Store
uv.lock" > .gitignore
            
        case ruby
            echo "💎 Creating Ruby project..."
            echo "source 'https://rubygems.org'" > Gemfile
            echo 'puts "Hello from '$project_name'!"' > main.rb
            
        case '*'
            echo "📁 Creating basic project..."
    end
    
    # Create common files
    if not test -f README.md
        echo "# $project_name

## Description
A new project created with pnew.

## Getting Started
1. Clone this repository
2. Follow setup instructions below

## Setup
TODO: Add setup instructions

## Usage
TODO: Add usage instructions" > README.md
    end
    
    if not test -f .gitignore
        echo ".DS_Store
.env
*.log" > .gitignore
    end
    
    # Create .editorconfig
    echo "root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true" > .editorconfig
    
    # Initial commit
    git add .
    git commit -m "Initial commit: $project_name ($template template)"
    
    # Success message
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Project created successfully!"
    echo "📂 Location: $project_path"
    echo "🏗️  Template: $template"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Next steps:"
    echo "  • Open in editor: hx ."
    echo "  • Start coding!"
    
    # Add to zoxide if available
    if command -v zoxide >/dev/null
        zoxide add "$project_path"
    end
end