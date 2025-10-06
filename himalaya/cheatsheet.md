# Himalaya Email Cheatsheet

## 📧 Core Commands

### Listing & Navigation
```bash
ml                          # List inbox
mls                         # List sent items
mld                         # List drafts
mlt                         # List trash
mfd                         # List all folders

himalaya envelope list -s 10       # List emails starting from 10th
himalaya envelope list -p 2        # List page 2
himalaya envelope list --limit 50  # Show 50 emails
```

### Reading & Managing
```bash
mr <id>                     # Read email
himalaya message thread <id>       # Read entire thread
himalaya message export <id> > email.eml  # Export raw email

md <id>                     # Delete (move to trash)
himalaya message move <id> Archive # Move to Archive folder
himalaya message copy <id> Notes   # Copy to Notes folder
```

### Writing & Sending
```bash
mw                          # Write new email
mf <id>                     # Forward email
mrp <id>                    # Reply to email
himalaya message reply --all <id>  # Reply all

# Write with prefilled content
himalaya message write "Body text here"
himalaya message write -H "Subject:Meeting Tomorrow" -H "To:person@example.com"

# Send existing draft
himalaya message send < draft.eml
```

## 🔍 Search & Filter

```bash
# Search emails (no colons in syntax!)
himalaya envelope list "from gmail.com"
himalaya envelope list "subject invoice"
himalaya envelope list "body meeting"
himalaya envelope list "date 2025-09-01"
himalaya envelope list "before 2025-09-15"
himalaya envelope list "after 2025-09-01"

# Combine searches
himalaya envelope list "from ferdinand and subject urgent"
himalaya envelope list "not flag seen"  # Unread emails

# Search with flags
himalaya envelope list "flag seen"     # Read emails
himalaya envelope list "flag answered" # Replied emails
himalaya envelope list "flag flagged"  # Starred/flagged
```

## 🏷️ Flags & Labels

```bash
# Manage flags
himalaya flag add <id> flagged        # Star/flag email
himalaya flag remove <id> flagged     # Unstar
himalaya flag add <id> seen          # Mark as read
himalaya flag remove <id> seen       # Mark as unread
himalaya flag add <id> answered      # Mark as answered
```

## 📎 Attachments

```bash
# List attachments in an email
himalaya attachment list <id>

# Download attachments
himalaya attachment download <id>     # Download all
himalaya attachment download <id> 1   # Download attachment #1
```

## 👥 Account Management

```bash
# Switch accounts
himalaya --account salisio envelope list
himalaya --account ferdinandsalis envelope list

# Account diagnostics
himalaya account doctor
himalaya account doctor salisio

# List configured accounts
himalaya account list
```

## 📁 Folder Management

```bash
# Create/delete folders
himalaya folder create "Projects"
himalaya folder delete "Old Stuff"

# Purge folder (empty it)
himalaya folder purge Trash
himalaya folder purge "Junk Mail"
```

## 🎨 Output Formats

```bash
# JSON output (for scripting)
himalaya -o json envelope list
himalaya -o json message read <id>
himalaya -o json folder list

# Pipe to other tools
himalaya envelope list | grep "ferdinand"
himalaya -o json envelope list | jq '.[] | .subject'
```

## 🔧 Advanced Usage

### Templates
```bash
# Save a template
himalaya template save newsletter < template.eml

# Use a template
himalaya template forward newsletter
himalaya template reply newsletter <id>
```

### Batch Operations
```bash
# Delete multiple emails
himalaya message delete 1 2 3 4 5

# Move multiple to archive
himalaya message move 10 11 12 Archive

# Mark multiple as read
himalaya flag add 20 21 22 seen
```

### Integration with Fish
```fish
# Quick search function (add to fish/functions/)
function msearch
    set query $argv
    himalaya envelope list "$query" | fzf --preview "himalaya message read {1}"
end

# Quick archive function
function marchive
    himalaya message move $argv Archive
    echo "Moved to Archive"
end

# Check for new mail
function mcheck
    set new_count (himalaya envelope list "NOT flag:seen" -o json | jq length)
    echo "You have $new_count unread emails"
end
```

## 🚀 Pro Tips

1. **Quick account switch**: Create aliases
   ```fish
   alias mail1='himalaya --account ferdinandsalis'
   alias mail2='himalaya --account salisio'
   ```

2. **Watch for new mail**:
   ```bash
   watch -n 60 'himalaya envelope list --limit 5'
   ```

3. **Export search results**:
   ```bash
   himalaya -o json envelope list "from:client" > client-emails.json
   ```

4. **Backup emails**:
   ```bash
   for id in (himalaya envelope list -o json | jq -r '.[].id')
       himalaya message export $id > "backup/$id.eml"
   end
   ```

5. **Quick unread count in prompt**:
   Add to Fish prompt to show unread count