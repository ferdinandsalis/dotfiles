#!/bin/bash

# Todo.txt <-> Apple Reminders Bidirectional Sync Script
# Syncs tasks between ~/todo.txt and Apple Reminders "Todo.txt" list

set -euo pipefail

# Configuration
TODO_FILE="$HOME/todo.txt"
DONE_FILE="$HOME/done.txt"
REMINDERS_LIST="Todo.txt"
SYNC_LOG="$HOME/.todo-sync.log"
STATE_FILE="$HOME/.todo-sync-state"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$SYNC_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$SYNC_LOG"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$SYNC_LOG"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$SYNC_LOG"
}

# Create todo.txt files if they don't exist
ensure_todo_files() {
    [[ -f "$TODO_FILE" ]] || touch "$TODO_FILE"
    [[ -f "$DONE_FILE" ]] || touch "$DONE_FILE"
    [[ -f "$STATE_FILE" ]] || echo "{}" > "$STATE_FILE"
}

# Create Reminders list if it doesn't exist
ensure_reminders_list() {
    osascript << EOF
tell application "Reminders"
    try
        set remindersList to list "$REMINDERS_LIST"
    on error
        make new list with properties {name:"$REMINDERS_LIST"}
        log "Created Reminders list: $REMINDERS_LIST"
    end try
end tell
EOF
}

# Get all incomplete tasks from todo.txt
get_todo_tasks() {
    if [[ -f "$TODO_FILE" ]]; then
        grep -v "^x " "$TODO_FILE" 2>/dev/null || true
    fi
}

# Get all reminders from Apple Reminders with their IDs and completion status
get_reminders_with_ids() {
    osascript << EOF
tell application "Reminders"
    set remindersList to list "$REMINDERS_LIST"
    set allReminders to reminders in remindersList
    set reminderData to {}
    repeat with aReminder in allReminders
        if completed of aReminder is false then
            set end of reminderData to (name of aReminder & "|" & id of aReminder & "|incomplete")
        end if
    end repeat
    set AppleScript's text item delimiters to "\n"
    set reminderString to reminderData as string
    set AppleScript's text item delimiters to ""
    return reminderString
end tell
EOF
}

# Get completed reminders from today (for syncing completions back to todo.txt)
get_completed_reminders_today() {
    osascript << EOF
tell application "Reminders"
    set remindersList to list "$REMINDERS_LIST"
    set allReminders to reminders in remindersList
    set completedToday to {}
    set today to current date
    set time of today to 0
    repeat with aReminder in allReminders
        if completed of aReminder is true then
            try
                if (completion date of aReminder) ≥ today then
                    set end of completedToday to name of aReminder
                end if
            on error
                -- If no completion date, assume it was completed recently
                set end of completedToday to name of aReminder
            end try
        end if
    end repeat
    set AppleScript's text item delimiters to "\n"
    set completedString to completedToday as string
    set AppleScript's text item delimiters to ""
    return completedString
end tell
EOF
}

# Get just reminder names (legacy function for compatibility)
get_reminders() {
    get_reminders_with_ids | cut -d'|' -f1
}

# Clean task text (fastest string processing using bash parameter expansion)
clean_task_text() {
    local task="$1"
    # Remove priority
    task="${task#\([ABC]\) }"
    # Remove contexts and projects (simple approach)
    task=$(echo "$task" | sed -E 's/@[a-zA-Z0-9_-]+|\\+[a-zA-Z0-9_-]+//g; s/  +/ /g')
    # Trim whitespace
    task="${task#"${task%%[![:space:]]*}"}"   # remove leading whitespace
    task="${task%"${task##*[![:space:]]}"}"   # remove trailing whitespace
    echo "$task"
}

# Batch add tasks to Apple Reminders (much faster)
batch_add_to_reminders() {
    local -a tasks=("$@")
    
    if [[ ${#tasks[@]} -eq 0 ]]; then
        return
    fi
    
    # Build AppleScript for batch operations
    local applescript="tell application \"Reminders\"
    set remindersList to list \"$REMINDERS_LIST\""
    
    for task in "${tasks[@]}"; do
        local clean_task=$(clean_task_text "$task")
        applescript+="
    make new reminder at end of remindersList with properties {name:\"$clean_task\"}"
    done
    
    applescript+="
end tell"
    
    osascript -e "$applescript"
}

# Add single task to Apple Reminders (fallback)
add_to_reminders() {
    batch_add_to_reminders "$1"
}

# Add task to todo.txt
add_to_todo() {
    local task="$1"
    echo "$task" >> "$TODO_FILE"
}

# Batch complete reminders (much faster)
batch_complete_reminders() {
    local -a tasks=("$@")
    
    if [[ ${#tasks[@]} -eq 0 ]]; then
        return
    fi
    
    # Build AppleScript for batch completion
    local applescript="tell application \"Reminders\"
    set remindersList to list \"$REMINDERS_LIST\"
    set allReminders to reminders in remindersList
    repeat with aReminder in allReminders"
    
    for task in "${tasks[@]}"; do
        local clean_task=$(clean_task_text "$task")
        applescript+="
        if name of aReminder is \"$clean_task\" and completed of aReminder is false then
            set completed of aReminder to true
        end if"
    done
    
    applescript+="
    end repeat
end tell"
    
    osascript -e "$applescript"
}

# Mark single reminder as completed (fallback)
complete_reminder() {
    batch_complete_reminders "$1"
}

# Sync todo.txt -> Apple Reminders (optimized)
sync_todo_to_reminders() {
    log "Syncing todo.txt -> Apple Reminders..."
    
    local todo_tasks
    todo_tasks=$(get_todo_tasks)
    
    if [[ -z "$todo_tasks" ]]; then
        log "No tasks in todo.txt"
        return
    fi
    
    local reminders
    reminders=$(get_reminders)
    
    # Collect tasks to add in batch
    local -a tasks_to_add=()
    
    while IFS= read -r task; do
        if [[ -n "$task" ]]; then
            local clean_task=$(clean_task_text "$task")
            
            if ! echo "$reminders" | grep -Fxq "$clean_task"; then
                tasks_to_add+=("$task")
            fi
        fi
    done <<< "$todo_tasks"
    
    # Batch add all new tasks
    if [[ ${#tasks_to_add[@]} -gt 0 ]]; then
        batch_add_to_reminders "${tasks_to_add[@]}"
        success "Added ${#tasks_to_add[@]} tasks to Reminders"
    else
        log "No new tasks to add to Reminders"
    fi
}

# Sync Apple Reminders -> todo.txt (optimized)
sync_reminders_to_todo() {
    log "Syncing Apple Reminders -> todo.txt..."
    
    local reminders
    reminders=$(get_reminders)
    
    if [[ -z "$reminders" ]]; then
        log "No reminders in Apple Reminders"
        return
    fi
    
    local todo_tasks
    todo_tasks=$(get_todo_tasks)
    
    # Create hash map of existing clean todo tasks for O(1) lookups
    declare -A existing_tasks
    while IFS= read -r todo_task; do
        if [[ -n "$todo_task" ]]; then
            local clean_todo=$(clean_task_text "$todo_task")
            existing_tasks["$clean_todo"]=1
        fi
    done <<< "$todo_tasks"
    
    # Batch collect new tasks
    local -a new_tasks=()
    while IFS= read -r reminder; do
        if [[ -n "$reminder" ]] && [[ -z "${existing_tasks[$reminder]}" ]]; then
            new_tasks+=("$reminder")
        fi
    done <<< "$reminders"
    
    # Batch add to todo.txt
    for task in "${new_tasks[@]}"; do
        add_to_todo "$task"
    done
    
    if [[ ${#new_tasks[@]} -gt 0 ]]; then
        success "Added ${#new_tasks[@]} tasks to todo.txt"
    else
        log "No new tasks to add to todo.txt"
    fi
}

# Sync completed Reminders back to todo.txt (mark as done)
sync_completed_reminders_to_todo() {
    log "Syncing completed Reminders -> todo.txt..."
    
    local completed_reminders
    completed_reminders=$(get_completed_reminders_today)
    
    if [[ -z "$completed_reminders" ]]; then
        log "No completed reminders today"
        return
    fi
    
    local todo_tasks
    todo_tasks=$(get_todo_tasks)
    
    local completed_count=0
    while IFS= read -r reminder; do
        if [[ -n "$reminder" ]]; then
            # Find matching task in todo.txt and mark as complete
            local found_task=""
            while IFS= read -r todo_task; do
                if [[ -n "$todo_task" ]]; then
                    local clean_todo=$(clean_task_text "$todo_task")
                    if [[ "$clean_todo" == "$reminder" ]]; then
                        found_task="$todo_task"
                        break
                    fi
                fi
            done <<< "$todo_tasks"
            
            if [[ -n "$found_task" ]]; then
                # Mark as complete in todo.txt
                todo.sh do $(grep -n "^$found_task$" "$TODO_FILE" | cut -d: -f1) 2>/dev/null || {
                    # Fallback: manually mark as complete
                    local today=$(date +%Y-%m-%d)
                    echo "x $today $found_task" >> "$DONE_FILE"
                    # Remove from todo.txt
                    grep -v "^$found_task$" "$TODO_FILE" > "$TODO_FILE.tmp" && mv "$TODO_FILE.tmp" "$TODO_FILE"
                }
                ((completed_count++))
            fi
        fi
    done <<< "$completed_reminders"
    
    if [[ $completed_count -gt 0 ]]; then
        success "Marked $completed_count tasks as complete in todo.txt"
    fi
}

# Sync completed tasks from todo.txt to Apple Reminders (optimized)
sync_completed_tasks() {
    log "Syncing completed tasks..."
    
    if [[ -f "$DONE_FILE" ]]; then
        local completed_tasks
        completed_tasks=$(tail -n 10 "$DONE_FILE" 2>/dev/null || true)
        
        # Collect completed tasks in batch
        local -a tasks_to_complete=()
        
        while IFS= read -r task; do
            if [[ -n "$task" ]] && [[ "$task" =~ ^x.*[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                # Extract the task name without the completion marker and date
                local clean_task=$(echo "$task" | sed -E 's/^x [0-9]{4}-[0-9]{2}-[0-9]{2} //')
                tasks_to_complete+=("$clean_task")
            fi
        done <<< "$completed_tasks"
        
        # Batch complete all tasks
        if [[ ${#tasks_to_complete[@]} -gt 0 ]]; then
            batch_complete_reminders "${tasks_to_complete[@]}"
            success "Completed ${#tasks_to_complete[@]} tasks in Reminders"
        fi
    fi
}

# Main sync function
main() {
    log "Starting bidirectional sync..."
    
    ensure_todo_files
    ensure_reminders_list
    
    case "${1:-smart}" in
        "smart"|"")
            # Smart mode: sync new tasks and completions (most common workflow)
            sync_todo_to_reminders
            sync_completed_reminders_to_todo
            ;;
        "todo-to-reminders")
            sync_todo_to_reminders
            ;;
        "reminders-to-todo")
            sync_reminders_to_todo
            ;;
        "both"|"full")
            # Full bidirectional sync
            sync_todo_to_reminders
            sync_reminders_to_todo
            sync_completed_tasks
            sync_completed_reminders_to_todo
            ;;
        *)
            # Default to smart mode
            sync_todo_to_reminders
            sync_completed_reminders_to_todo
            ;;
    esac
    
    success "Sync completed!"
}

# Show help
show_help() {
    cat << EOF
Todo.txt <-> Apple Reminders Sync Script

Usage: $0 [OPTION]

OPTIONS:
    (no args)             Smart sync: new tasks + completions (default)
    both/full             Full bidirectional sync
    todo-to-reminders     Sync only todo.txt -> Apple Reminders
    reminders-to-todo     Sync only Apple Reminders -> todo.txt
    help                  Show this help message

DESCRIPTION:
    This script syncs tasks between your todo.txt file and an Apple Reminders
    list called "$REMINDERS_LIST". It handles:
    
    - New tasks in either system
    - Completed tasks (marks them complete in both systems)
    - Preserves todo.txt priority and project/context formatting
    - Creates clean reminder names without markup
    
SETUP:
    The script will automatically create the "$REMINDERS_LIST" list in
    Apple Reminders if it doesn't exist.
    
FILES:
    Todo file: $TODO_FILE
    Done file: $DONE_FILE
    Sync log:  $SYNC_LOG
    
EOF
}

# Handle command line arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac