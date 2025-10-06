#!/usr/bin/env bash

# Manual password setup commands for Himalaya
# Run these commands one by one, replacing YOUR_PASSWORD with your actual password

echo "To manually set up passwords, run these commands:"
echo ""
echo "# For mail@ferdinandsalis.com:"
echo 'security add-generic-password -a "mail@ferdinandsalis.com" -s "himalaya" -w "YOUR_PASSWORD"'
echo ""
echo "# For ferdinand@salis.io:"
echo 'security add-generic-password -a "ferdinand@salis.io" -s "himalaya" -w "YOUR_PASSWORD"'
echo ""
echo "Replace YOUR_PASSWORD with your actual Fastmail password or app-specific password."
echo ""
echo "To generate app-specific passwords, visit:"
echo "https://www.fastmail.com/settings/security/devicekeys"