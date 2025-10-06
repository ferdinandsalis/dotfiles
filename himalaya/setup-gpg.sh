#!/usr/bin/env bash

# Setup GPG for email signing and encryption with Himalaya
set -e

echo "🔐 GPG Setup for Email Signing & Encryption"
echo "==========================================="
echo ""

# Function to generate a GPG key
generate_key() {
    local email="$1"
    local name="$2"

    echo "Generating GPG key for: $email"

    # Create key generation config
    cat > /tmp/gpg-key-config <<EOF
%echo Generating GPG key for $email
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $name
Name-Email: $email
Expire-Date: 2y
%commit
%echo done
EOF

    # Generate the key
    gpg --batch --generate-key /tmp/gpg-key-config
    rm /tmp/gpg-key-config

    echo "✓ Key generated for $email"
    echo ""
}

# Function to setup existing key
setup_existing() {
    echo "Current GPG keys:"
    gpg --list-secret-keys --keyid-format LONG
    echo ""
    echo "Your GPG setup is ready for use with Himalaya!"
}

# Main menu
echo "Choose an option:"
echo "1. Generate new GPG keys for both email addresses"
echo "2. Generate GPG key for mail@ferdinandsalis.com only"
echo "3. Generate GPG key for ferdinand@salis.io only"
echo "4. I already have GPG keys set up"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        generate_key "mail@ferdinandsalis.com" "Ferdinand Salis"
        generate_key "ferdinand@salis.io" "Ferdinand Salis"
        ;;
    2)
        generate_key "mail@ferdinandsalis.com" "Ferdinand Salis"
        ;;
    3)
        generate_key "ferdinand@salis.io" "Ferdinand Salis"
        ;;
    4)
        setup_existing
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "==========================================="
echo "✅ GPG Setup Complete!"
echo ""
echo "Your GPG keys:"
gpg --list-secret-keys --keyid-format LONG
echo ""
echo "📧 Using PGP with Himalaya:"
echo ""
echo "Sign emails:"
echo "  himalaya message write --sign"
echo ""
echo "Encrypt emails (recipient must have public key):"
echo "  himalaya message write --encrypt"
echo ""
echo "Sign and encrypt:"
echo "  himalaya message write --sign --encrypt"
echo ""
echo "Export your public key to share:"
echo "  gpg --armor --export $email > my-public-key.asc"
echo ""
echo "Import someone's public key:"
echo "  gpg --import their-public-key.asc"