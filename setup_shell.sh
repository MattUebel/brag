#!/bin/bash

# 🏆 Brag CLI - Setup Script
# Because your accomplishments deserve to be remembered!

echo ""
echo "🏆 =================================="
echo "   BRAG CLI - Shell Setup"
echo "   Time to start bragging!"
echo "=================================== 🏆"
echo ""

# Detect shell
SHELL_NAME=$(basename "${SHELL:-}")
RC_FILE=""

if [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
else
    echo "⚠️  Unknown shell: $SHELL_NAME"
    echo "   You'll need to manually add the bin directory to your PATH."
    echo ""
    echo "   Common locations:"
    echo "   - ~/.local/bin"
    echo "   - ~/Library/Python/3.X/bin (macOS)"
    echo ""
    echo "   Example (adjust for your system):"
    echo "   export PATH=\"$HOME/.local/bin:$PATH\""
    exit 0
fi

# If brag already works, nothing to do.
if command -v brag >/dev/null 2>&1; then
    echo "✅ 'brag' is already available: $(command -v brag)"
    echo "   Run 'brag --help' to see what you can do."
    exit 0
fi

# Try to locate an existing brag executable in common locations (avoid invoking python3).
BIN_DIR=""
if [ -x "$HOME/.local/bin/brag" ]; then
    BIN_DIR="$HOME/.local/bin"
elif [ -x "$HOME/Library/Python/3.13/bin/brag" ]; then
    BIN_DIR="$HOME/Library/Python/3.13/bin"
elif [ -x "$HOME/Library/Python/3.12/bin/brag" ]; then
    BIN_DIR="$HOME/Library/Python/3.12/bin"
elif [ -x "$HOME/Library/Python/3.11/bin/brag" ]; then
    BIN_DIR="$HOME/Library/Python/3.11/bin"
elif [ -x "$HOME/Library/Python/3.10/bin/brag" ]; then
    BIN_DIR="$HOME/Library/Python/3.10/bin"
elif [ -x "$HOME/Library/Python/3.9/bin/brag" ]; then
    BIN_DIR="$HOME/Library/Python/3.9/bin"
elif [ -x "$HOME/Library/Python/3.8/bin/brag" ]; then
    BIN_DIR="$HOME/Library/Python/3.8/bin"
fi

# If we didn't find it, fall back to the active python3 user-base bin directory.
if [ -z "$BIN_DIR" ]; then
    if [ "$(uname -s)" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
        echo "ℹ️  macOS Command Line Developer Tools not found."
        echo "   If Python isn't installed, you may see a prompt to install them."
        echo ""
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        echo "❌ python3 not found."
        echo "   Install Python 3.8+ first, then install brag, then re-run this script."
        echo ""
        echo "   Common options:"
        echo "   - macOS: install Python via Homebrew, python.org, or Xcode Command Line Tools"
        echo "   - Linux: your package manager (apt/yum) or python.org/pyenv"
        exit 1
    fi

    PY_USER_BASE=$(python3 -m site --user-base)
    PY_RC=$?
    if [ $PY_RC -ne 0 ] || [ -z "$PY_USER_BASE" ]; then
        echo "❌ Failed to determine the Python user-base directory."
        echo "   Try running: python3 -m site --user-base"
        exit 1
    fi
    BIN_DIR="$PY_USER_BASE/bin"
fi

# Check if already in PATH
if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    echo "✅ Your PATH already contains: $BIN_DIR"
    if command -v brag >/dev/null 2>&1; then
        echo "   'brag' is available: $(command -v brag)"
        echo "   Run 'brag --help' to see what you can do."
        exit 0
    fi
    echo ""
    echo "⚠️  'brag' is still not found."
    echo "   This usually means the CLI isn't installed yet."
    echo ""
    echo "   From the repo root, install it with:"
    echo "   python3 -m pip install -e ."
    echo ""
    echo "   Then open a new terminal (or run: source $RC_FILE)."
    exit 1
fi

echo "⚠️  Your Python scripts directory is: $BIN_DIR"
echo "   but this directory is not currently in your PATH."
echo ""

# Check if we might have added it before but it's not sourced
if [ -n "$RC_FILE" ] && [ -f "$RC_FILE" ]; then
    if grep -qF "$BIN_DIR" "$RC_FILE"; then
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
echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$RC_FILE"

echo "✅ Success! Added to your configuration."
echo ""
echo "📝 Next steps:"
echo "   1. Run: source $RC_FILE"
echo "   2. If you haven't installed the CLI yet, run:"
echo "      python3 -m pip install -e ."
echo "   3. Try:  brag add \"Set up the brag CLI - my first win!\""
echo ""
echo "🎯 Pro tip: Use 'brag add --edit' for multi-line entries"
echo ""
echo "Now go out there and do something worth bragging about! 💪"
echo ""
