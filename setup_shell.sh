#!/bin/bash

# 🏆 Brag CLI - Setup Script
# Because your accomplishments deserve to be remembered!

echo ""
echo "🏆 =================================="
echo "   BRAG CLI - Shell Setup"
echo "   Time to start bragging!"
echo "=================================== 🏆"
echo ""

# Get user bin directory
BIN_DIR="$(python3 -m site --user-base)/bin"

# Detect shell
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

if [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
else
    echo "⚠️  Unknown shell: $SHELL_NAME"
    echo "   You'll need to manually add the bin directory to your PATH."
fi

# Check if already in PATH
if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    echo "✅ You're already set up and ready to brag!"
    echo "   Run 'brag --help' to see what you can do."
    exit 0
fi

echo "⚠️  The brag executable is in: $BIN_DIR"
echo "   but this directory is not currently in your PATH."
echo ""

# Check if we might have added it before but it's not sourced
if [ -n "$RC_FILE" ] && [ -f "$RC_FILE" ]; then
    if grep -q "$BIN_DIR" "$RC_FILE"; then
        echo "✅ It looks like it's already in your $RC_FILE"
        echo "   Try running this to refresh your shell:"
        echo ""
        echo "   source $RC_FILE"
        exit 0
    fi
fi

# Not in PATH and not in RC file - Add it automatically
echo "➕ Adding $BIN_DIR to $RC_FILE..."
echo "" >> "$RC_FILE"
echo "# 🏆 Brag CLI - Track your wins!" >> "$RC_FILE"
echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$RC_FILE"

echo "✅ Success! Added to your configuration."
echo ""
echo "📝 Next steps:"
echo "   1. Run: source $RC_FILE"
echo "   2. Try:  brag add \"Set up the brag CLI - my first win!\""
echo ""
echo "🎯 Pro tip: Use 'brag add --edit' for multi-line entries"
echo ""
echo "Now go out there and do something worth bragging about! 💪"
echo ""
