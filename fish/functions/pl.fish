function pl --description "List recent projects with details"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📂 Recent Projects (via zoxide)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v zoxide >/dev/null
        # Get top 10 directories from zoxide
        set -f dirs (zoxide query -l | head -10)
        set -f counter 1
        
        for dir in $dirs
            # Check if it's a git repo
            if test -d "$dir/.git"
                set -f branch (git -C "$dir" branch --show-current 2>/dev/null)
                set -f status_count (git -C "$dir" status -s 2>/dev/null | wc -l | string trim)
                
                if test "$status_count" -gt 0
                    set -f status_indicator "📝 $status_count changes"
                else
                    set -f status_indicator "✨ clean"
                end
                
                printf "%2d. %-40s 🌿 %-15s %s\n" $counter (basename $dir) $branch "$status_indicator"
            else
                printf "%2d. %-40s 📁 directory\n" $counter (basename $dir)
            end
            
            set counter (math $counter + 1)
        end
    else
        echo "⚠️  zoxide not installed. Install it for better project tracking."
        echo "   Run: brew install zoxide"
    end
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 Commands:"
    echo "  • p      - Switch to a project"
    echo "  • pnew   - Create new project"
    echo "  • pl     - List recent projects (this command)"
end