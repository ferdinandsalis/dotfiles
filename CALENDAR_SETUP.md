# Calendar Setup Guide

This guide will help you configure your terminal calendar system with support for iCloud, Google Workspace, and personal Google calendars.

## Installation

1. Install the calendar tools:
   ```bash
   brew bundle
   ```

2. Create symlinks with dotbot:
   ```bash
   ./install
   ```

## Configuration

### 1. iCloud Calendar

1. Generate an app-specific password:
   - Go to https://appleid.apple.com
   - Sign in and go to "Sign-In and Security"
   - Click "App-Specific Passwords"
   - Generate a new password for "vdirsyncer"

2. Store the password in 1Password:
   - Create a new login item called "iCloud Calendar"
   - Save the app-specific password in the password field

3. Update the vdirsyncer config:
   - Edit `~/.config/vdirsyncer/config`
   - Replace `YOUR_APPLE_ID` with your Apple ID email

### 2. Google Calendars (CalDAV with App Passwords)

For both Google Workspace and personal Google accounts:

1. Enable 2-factor authentication on your Google account (if not already enabled)

2. Generate an app-specific password:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Other (custom name)" and enter "vdirsyncer"
   - Copy the generated 16-character password

3. Store the password in 1Password:
   - Create a new login item called "Google Workspace Calendar" or "Google Personal Calendar"
   - Save the app-specific password in the password field

4. Update the vdirsyncer config:
   - Edit `~/.config/vdirsyncer/config`
   - Replace `YOUR_WORKSPACE_EMAIL@YOUR_DOMAIN.com` with your actual email
   - Replace `YOUR_PERSONAL_EMAIL@gmail.com` with your Gmail address

5. Discover and sync calendars:
   ```bash
   vdirsyncer discover google_workspace_calendar
   vdirsyncer discover google_personal_calendar
   vdirsyncer sync
   ```

### 3. Alternative OAuth Method

If you prefer using CalDAV with app passwords:

1. Enable 2-factor authentication on your Google account
2. Generate app-specific passwords at https://myaccount.google.com/apppasswords
3. Store passwords in 1Password
4. Uncomment the CalDAV sections in vdirsyncer config

## Initial Sync

1. Discover calendars (first time only):
   ```bash
   vdirsyncer discover
   ```

2. Sync all calendars:
   ```bash
   cal-sync
   # or use the abbreviation: cals
   ```

## Usage

### View Calendar

```bash
# Today's events in minimal format
tcal
# or use abbreviation: tc

# Week calendar view
cal

# Next 7 days agenda
agenda
# or specify days: agenda 14
```

### Add Events

```bash
# Interactive mode
cal-add

# Quick add with natural language
cal-add "Meeting with Johann tomorrow at 2pm"
# or use abbreviation: cala "Dentist appointment next Monday 10am"
```

### Search Events

```bash
cal-search "meeting"
# or use abbreviation: calf "dentist"
```

### Sync Calendars

```bash
cal-sync
# or use abbreviation: cals
```

## Automatic Features

- **Terminal Greeting**: Shows your first 3 events when opening a new terminal
- **Fish Abbreviations**:
  - `tc` → `tcal` (today's calendar)
  - `cals` → `cal-sync` (sync calendars)
  - `cala` → `cal-add` (add event)
  - `calf` → `cal-search` (find events)

## Troubleshooting

### Authentication Issues

If you get authentication errors:

1. Check your app-specific passwords are correct
2. For Google OAuth, try re-authenticating:
   ```bash
   rm ~/.vdirsyncer/google_*_token
   vdirsyncer discover
   ```

### Sync Issues

If calendars aren't syncing:

1. Check the vdirsyncer status:
   ```bash
   vdirsyncer status
   ```

2. Run a manual sync with verbose output:
   ```bash
   vdirsyncer -v DEBUG sync
   ```

### Calendar Colors

To customize calendar colors, edit `~/.config/khal/config` and modify the color values:
- iCloud: `light blue`
- Google Workspace: `light green`
- Personal Google: `light magenta`

Available colors: black, white, brown, yellow, dark gray, dark green, dark blue,
light gray, light green, light blue, dark magenta, dark cyan, dark red,
light magenta, light cyan, light red

## Automation (Optional)

To sync calendars automatically, add a cron job:

```bash
# Edit crontab
crontab -e

# Add this line to sync every 30 minutes
*/30 * * * * /opt/homebrew/bin/vdirsyncer sync
```

Or use launchd on macOS for better integration.