# Himalaya email client configuration
# Set environment variable for Himalaya config
set -gx HIMALAYA_CONFIG ~/.config/himalaya/config.toml

# Suppress IMAP warnings as recommended by Himalaya maintainer
# See: https://github.com/soywod/himalaya/issues/552
# These warnings are from the IMAP library and not actionable by users
set -gx RUST_LOG off

# Alias to ensure config is always used
alias himalaya='himalaya -c ~/.config/himalaya/config.toml'