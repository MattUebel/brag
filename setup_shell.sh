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
    echo "❌ Unsupported shell: $SHELL_NAME"
    echo "   (But hey, that's something to brag about - you're unique!)"
    exit 1
fi

# Check if already in PATH
if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    echo "✅ You're already set up and ready to brag!"
    echo "   Run 'brag --help' to see what you can do."
    exit 0
fi

# Add to rc file
echo "" >> "$RC_FILE"
echo "# 🏆 Brag CLI - Track your wins!" >> "$RC_FILE"
echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$RC_FILE"

echo "✅ Success! Added $BIN_DIR to your PATH"
echo ""
echo "📝 Next steps:"
echo "   1. Run: source $RC_FILE"
echo "   2. Try:  brag add \"Set up the brag CLI - my first win!\""
echo ""
echo "🎯 Pro tip: Use 'brag add --edit' for multi-line entries"
echo ""
echo "Now go out there and do something worth bragging about! 💪"
echo ""
