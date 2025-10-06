#!/usr/bin/env bash

# Setup script for Himalaya email passwords in macOS Keychain
# This script helps you securely store email passwords

set -e

echo "Himalaya Email Password Setup"
echo "=============================="
echo ""
echo "This script will help you store your email passwords securely in macOS Keychain."
echo "The passwords will be used by Himalaya to access your email accounts."
echo ""

# Function to add password to keychain
add_password() {
    local email="$1"
    local account_name="$2"

    echo "Setting up password for: $email"
    echo "Please enter the password for this account:"
    read -s password
    echo ""

    # Delete existing password if it exists (ignore errors)
    security delete-generic-password -a "$email" -s "himalaya" 2>/dev/null || true

    # Add new password
    security add-generic-password -a "$email" -s "himalaya" -w "$password"

    echo "✓ Password stored successfully for $account_name"
    echo ""
}

# Setup passwords for both accounts
echo "1. Ferdinand Salis - Primary Account"
add_password "mail@ferdinandsalis.com" "ferdinandsalis"

echo "2. Ferdinand Salis - Secondary Account"
add_password "ferdinand@salis.io" "salisio"

echo "=============================="
echo "Password setup complete!"
echo ""
echo "Note: For Fastmail accounts:"
echo "  1. You can use your regular password, or"
echo "  2. Generate an app-specific password at: https://www.fastmail.com/settings/security/devicekeys"
echo "  3. App-specific passwords are recommended for better security"
echo ""
echo "You can test your configuration with:"
echo "  himalaya account list"
echo "  himalaya -a ferdinandsalis list"
echo "  himalaya -a salisio list"