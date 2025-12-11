#!/bin/bash

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
    echo "Unsupported shell: $SHELL_NAME"
    exit 1
fi

# Check if already in PATH
if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    echo "Bin directory already in PATH."
    exit 0
fi

# Add to rc file
echo "" >> "$RC_FILE"
echo "# Added by brag-cli" >> "$RC_FILE"
echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$RC_FILE"

echo "Added $BIN_DIR to PATH in $RC_FILE"
echo "Please restart your shell or run 'source $RC_FILE' to apply changes."
