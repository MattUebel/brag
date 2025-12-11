#!/bin/bash

# 🏆 Brag CLI - Uninstall Script
# Sad to see you go, but we respect your choices!

echo ""
echo "🏆 =================================="
echo "   BRAG CLI - Uninstaller"
echo "   (We'll miss you!)"
echo "=================================== 🏆"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track what we did
UNINSTALLED_CLI=false
CLEANED_PATH=false
CLEANED_RAYCAST=false

# ============================================
# Step 1: Uninstall the Python CLI
# ============================================
echo "📦 Checking for brag CLI installation..."

if pip3 show brag-cli &>/dev/null; then
    echo "   Found brag-cli package. Uninstalling..."
    pip3 uninstall brag-cli -y
    if [ $? -eq 0 ]; then
        echo -e "   ${GREEN}✅ CLI uninstalled successfully${NC}"
        UNINSTALLED_CLI=true
    else
        echo -e "   ${RED}❌ Failed to uninstall CLI${NC}"
    fi
else
    echo "   No brag-cli package found (already uninstalled or never installed)"
fi

# Also try just 'brag' in case it was installed under that name
if pip3 show brag &>/dev/null; then
    echo "   Found 'brag' package. Uninstalling..."
    pip3 uninstall brag -y
    UNINSTALLED_CLI=true
fi

# ============================================
# Step 2: Clean up PATH from shell rc files
# ============================================
echo ""
echo "🧹 Checking shell configuration..."

SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

if [ "$SHELL_NAME" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_NAME" = "bash" ]; then
    RC_FILE="$HOME/.bashrc"
fi

if [ -n "$RC_FILE" ] && [ -f "$RC_FILE" ]; then
    if grep -q "brag" "$RC_FILE"; then
        echo "   Found potential brag entries in $RC_FILE"
        echo ""
        echo -e "${YELLOW}⚠️  Action Required:${NC}"
        echo "   Please open $RC_FILE and remove any lines related to 'brag' or 'brag-cli'."
        echo "   Look for: export PATH=\"\$PATH:.../bin\""
    else
        echo "   No brag PATH entries found in $RC_FILE"
        CLEANED_PATH=true
    fi
fi

# ============================================
# Step 3: Clean up Raycast extension
# ============================================
echo ""
echo "🎨 Checking Raycast extension..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAYCAST_DIR="$SCRIPT_DIR/raycast-extension"

if [ -d "$RAYCAST_DIR/node_modules" ]; then
    echo "   Found node_modules in raycast-extension"
    rm -rf "$RAYCAST_DIR/node_modules"
    echo -e "   ${GREEN}✅ Removed node_modules${NC}"
    CLEANED_RAYCAST=true
fi

if [ -f "$RAYCAST_DIR/package-lock.json" ]; then
    rm "$RAYCAST_DIR/package-lock.json"
    echo -e "   ${GREEN}✅ Removed package-lock.json${NC}"
    CLEANED_RAYCAST=true
fi

if [ -d "$RAYCAST_DIR/dist" ]; then
    rm -rf "$RAYCAST_DIR/dist"
    echo -e "   ${GREEN}✅ Removed dist directory${NC}"
    CLEANED_RAYCAST=true
fi

if [ "$CLEANED_RAYCAST" = false ]; then
    echo "   Raycast extension already clean"
fi

echo ""
echo -e "${YELLOW}⚠️  Note: To fully remove the extension from Raycast:${NC}"
echo "   1. Open Raycast"
echo "   2. Search for 'Extensions'"
echo "   3. Find 'Brag' and click 'Remove'"

# ============================================
# Step 4: Ask about data
# ============================================
echo ""
echo "💾 Your brags are stored at: ~/.brag/data/"

if [ -d "$HOME/.brag" ]; then
    BRAG_COUNT=$(find "$HOME/.brag" -name "*.jsonl" 2>/dev/null | wc -l | tr -d ' ')
    echo "   Found $BRAG_COUNT day(s) of brags"
    echo ""
    echo -e "${YELLOW}🤔 Do you want to DELETE your brag data?${NC}"
    echo "   (This cannot be undone!)"
    echo ""
    read -p "   Type 'DELETE' to remove, or press Enter to keep: " confirm
    
    if [ "$confirm" = "DELETE" ]; then
        rm -rf "$HOME/.brag"
        echo -e "   ${GREEN}✅ Brag data deleted${NC}"
    else
        echo "   📁 Keeping your brags safe at ~/.brag/"
        echo "   (You can always delete manually later)"
    fi
else
    echo "   No brag data directory found"
fi

# ============================================
# Summary
# ============================================
echo ""
echo "🏆 =================================="
echo "   Uninstall Complete!"
echo "=================================== 🏆"
echo ""

if [ "$UNINSTALLED_CLI" = true ]; then
    echo "   ✅ CLI uninstalled"
fi
if [ "$CLEANED_PATH" = true ]; then
    echo "   ✅ Shell PATH cleaned"
fi
if [ "$CLEANED_RAYCAST" = true ]; then
    echo "   ✅ Raycast extension cleaned"
fi

echo ""
echo "📝 To reinstall, run:"
echo "   pip3 install -e ."
echo "   ./setup_shell.sh"
echo "   cd raycast-extension && npm install && npm run dev"
echo ""
echo "We hope you achieved great things! 🌟"
echo "Come back anytime - your wins will be waiting."
echo ""
