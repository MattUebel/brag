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

UNINSTALLED_CLI=false
CLEANED_SHELL=false
REMOVED_RAYCAST=false

marker_start="# >>> brag-cli (uv) >>>"
marker_end="# <<< brag-cli (uv) <<<"

# ============================================
# Step 1: Uninstall the CLI (uv tool)
# ============================================
echo "📦 Uninstalling brag CLI..."

if command -v uv >/dev/null 2>&1; then
    if uv tool list 2>/dev/null | grep -q '^brag-cli '; then
        uv tool uninstall brag-cli
        UNINSTALLED_CLI=true
        echo -e "   ${GREEN}✅ Uninstalled via uv${NC}"
    else
        echo "   No uv-installed brag-cli tool found"
    fi
else
    echo "   'uv' not found; attempting best-effort manual cleanup..."
    if [ -L "$HOME/.local/bin/brag" ]; then
        target="$(readlink "$HOME/.local/bin/brag" || true)"
        case "$target" in
            *"/.local/share/uv/tools/brag-cli/"*)
                rm -f "$HOME/.local/bin/brag"
                UNINSTALLED_CLI=true
                echo -e "   ${GREEN}✅ Removed ~/.local/bin/brag symlink${NC}"
                ;;
        esac
    fi
    if [ -d "$HOME/.local/share/uv/tools/brag-cli" ]; then
        rm -rf "$HOME/.local/share/uv/tools/brag-cli"
        UNINSTALLED_CLI=true
        echo -e "   ${GREEN}✅ Removed uv tool directory${NC}"
    fi
fi

# ============================================
# Step 2: Remove PATH block added by installer
# ============================================
echo ""
echo "🧹 Cleaning shell configuration..."

remove_path_block() {
    local rc_file="$1"
    [ -f "$rc_file" ] || return 0

    if grep -qF "$marker_start" "$rc_file"; then
        # macOS/BSD sed requires an explicit suffix argument to -i
        sed -i '' '/^# >>> brag-cli (uv) >>>$/,/^# <<< brag-cli (uv) <<<$/{d;}' "$rc_file"
        CLEANED_SHELL=true
    fi
}

remove_path_block "$HOME/.zshrc"
remove_path_block "$HOME/.zprofile"
remove_path_block "$HOME/.bashrc"
remove_path_block "$HOME/.bash_profile"

if [ "$CLEANED_SHELL" = true ]; then
    echo -e "   ${GREEN}✅ Removed PATH entries added by brag installer${NC}"
else
    echo "   No installer-added PATH entries found"
fi

# ============================================
# Step 3: Remove Raycast extension (local build)
# ============================================
echo ""
echo "🎨 Removing Raycast extension..."

RAYCAST_EXT_DIR="$HOME/.config/raycast/extensions/brag"
if [ -d "$RAYCAST_EXT_DIR" ]; then
    rm -rf "$RAYCAST_EXT_DIR"
    REMOVED_RAYCAST=true
    echo -e "   ${GREEN}✅ Removed $RAYCAST_EXT_DIR${NC}"
else
    echo "   No local Raycast extension found at $RAYCAST_EXT_DIR"
fi

# Also clean build artifacts in this repo (optional but safe).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_RAYCAST_DIR="$SCRIPT_DIR/raycast-extension"
if [ -d "$REPO_RAYCAST_DIR/node_modules" ]; then
    rm -rf "$REPO_RAYCAST_DIR/node_modules"
    echo -e "   ${GREEN}✅ Removed repo raycast-extension/node_modules${NC}"
fi
if [ -d "$REPO_RAYCAST_DIR/dist" ]; then
    rm -rf "$REPO_RAYCAST_DIR/dist"
    echo -e "   ${GREEN}✅ Removed repo raycast-extension/dist${NC}"
fi
if [ -d "$REPO_RAYCAST_DIR/.raycast" ]; then
    rm -rf "$REPO_RAYCAST_DIR/.raycast"
    echo -e "   ${GREEN}✅ Removed repo raycast-extension/.raycast${NC}"
fi

echo ""
echo -e "${YELLOW}⚠️  Note:${NC} Raycast may need a restart to fully reflect removal."

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
    read -r -p "   Type 'DELETE' to remove, or press Enter to keep: " confirm

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
    echo "   ✅ CLI removed"
fi
if [ "$CLEANED_SHELL" = true ]; then
    echo "   ✅ Shell PATH cleaned"
fi
if [ "$REMOVED_RAYCAST" = true ]; then
    echo "   ✅ Raycast extension removed"
fi

echo ""
echo "📝 To reinstall from a fresh clone, run:"
echo "   ./install.sh"
echo ""
