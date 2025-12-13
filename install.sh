#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AUTO_RAYCAST=false
SKIP_RAYCAST=false
FORCE=false
INSTALL_UV=false

usage() {
  cat <<'EOF'
Brag CLI - All-in-one installer

Usage:
  ./install.sh [--raycast] [--no-raycast] [--force] [--install-uv]

Options:
  --raycast      Install the Raycast extension automatically (no prompt).
  --no-raycast   Skip Raycast extension installation (no prompt).
  --force        Reinstall/update the uv tool installation.
  --install-uv   If uv is missing, install it (may download from the internet).
  -h, --help     Show this help.

This installer:
  1) Installs the `brag` CLI via `uv tool install`
  2) Ensures the uv tool bin dir is on your PATH
  3) Optionally installs the Raycast extension
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --raycast)
      AUTO_RAYCAST=true
      ;;
    --no-raycast)
      SKIP_RAYCAST=true
      ;;
    --force)
      FORCE=true
      ;;
    --install-uv)
      INSTALL_UV=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

echo ""
echo "🏆 =================================="
echo "   BRAG CLI - Installer"
echo "=================================== 🏆"
echo ""

if [ "$AUTO_RAYCAST" = true ] && [ "$SKIP_RAYCAST" = true ]; then
  echo "❌ Cannot use both --raycast and --no-raycast." >&2
  exit 2
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "❌ 'uv' is not installed."
  echo ""
  echo "Install uv first, then re-run this installer."
  echo ""
  echo "Options:"
  echo "  - Homebrew: brew install uv"
  echo "  - Official installer: https://astral.sh/uv"
  echo ""

  if [ "$INSTALL_UV" = true ] || [ -t 0 ]; then
    if [ "$INSTALL_UV" = false ]; then
      read -r -p "Install uv now via the official installer? (y/N) " reply
      case "$reply" in
        y|Y|yes|YES)
          INSTALL_UV=true
          ;;
      esac
    fi
  fi

  if [ "$INSTALL_UV" = true ]; then
    echo ""
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  else
    exit 1
  fi
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "❌ uv installation failed (uv still not on PATH)."
  echo "   Try opening a new terminal and re-running ./install.sh"
  exit 1
fi

UV_BIN_DIR="$(uv tool dir --bin 2>/dev/null || true)"
if [ -z "$UV_BIN_DIR" ]; then
  UV_BIN_DIR="$HOME/.local/bin"
fi

echo "📦 Installing brag CLI via uv..."
UV_INSTALL_ARGS=(tool install)
if [ "$FORCE" = true ]; then
  UV_INSTALL_ARGS+=(--force)
fi
UV_INSTALL_ARGS+=(-e "$SCRIPT_DIR")
uv "${UV_INSTALL_ARGS[@]}"

BRAG_BIN="$UV_BIN_DIR/brag"
if [ ! -x "$BRAG_BIN" ]; then
  echo ""
  echo "❌ Installation finished, but '$BRAG_BIN' was not found."
  echo "   Something went wrong with uv tool installation."
  echo "   Try running: uv tool install -e \"$SCRIPT_DIR\" --force"
  exit 1
fi

shell_name="$(basename "${SHELL:-}")"
rc_files=()
case "$shell_name" in
  zsh)
    rc_files=("$HOME/.zshrc" "$HOME/.zprofile")
    ;;
  bash)
    rc_files=("$HOME/.bashrc" "$HOME/.bash_profile")
    ;;
  *)
    echo ""
    echo "⚠️  Unknown shell: ${shell_name:-"(not set)"}"
    echo "   Add this directory to your PATH manually:"
    echo "   export PATH=\"$UV_BIN_DIR:\$PATH\""
    ;;
esac

marker_start="# >>> brag-cli (uv) >>>"
marker_end="# <<< brag-cli (uv) <<<"

bin_dir_expr="$UV_BIN_DIR"
if [[ "$UV_BIN_DIR" == "$HOME/"* ]]; then
  bin_dir_expr="\$HOME/${UV_BIN_DIR#"$HOME/"}"
fi

ensure_path_in_rc() {
  local rc_file="$1"

  # Create the file if it doesn't exist.
  if [ ! -f "$rc_file" ]; then
    touch "$rc_file"
  fi

  if grep -qF "$marker_start" "$rc_file"; then
    return 0
  fi

  if grep -qF "$bin_dir_expr" "$rc_file" || grep -qF "$UV_BIN_DIR" "$rc_file"; then
    return 0
  fi

  {
    echo ""
    echo "$marker_start"
    echo "export PATH=\"$bin_dir_expr:\$PATH\""
    echo "$marker_end"
  } >>"$rc_file"
}

if [ "${#rc_files[@]}" -gt 0 ]; then
  echo ""
  echo "🐚 Configuring your shell PATH..."
  for rc in "${rc_files[@]}"; do
    ensure_path_in_rc "$rc"
  done
fi

echo ""
echo "✅ Installed brag: $BRAG_BIN"
echo ""
echo "📝 Next steps (new terminal session):"
echo "  - Open a new terminal window/tab"
if [ "${#rc_files[@]}" -gt 0 ]; then
  echo "  - Or run: source ${rc_files[0]}"
fi
echo ""
echo "🎯 Quick test (works immediately with full path):"
echo "  $BRAG_BIN --help"
echo ""

install_raycast=false
if [ "$AUTO_RAYCAST" = true ]; then
  install_raycast=true
elif [ "$SKIP_RAYCAST" = true ]; then
  install_raycast=false
else
  if [ -t 0 ]; then
    read -r -p "🎨 Install Raycast extension? (y/N) " reply
    case "$reply" in
      y|Y|yes|YES)
        install_raycast=true
        ;;
    esac
  fi
fi

if [ "$install_raycast" = true ]; then
  echo ""
  echo "🎨 Installing Raycast extension..."

  if [ ! -d "/Applications/Raycast.app" ]; then
    echo "❌ Raycast.app not found in /Applications."
    echo "   Install Raycast first, then re-run:"
    echo "   ./install.sh --raycast"
    if [ "$AUTO_RAYCAST" = true ]; then
      exit 1
    fi
    echo ""
    echo "Skipping Raycast extension install (CLI is installed)."
    install_raycast=false
  fi

  if [ "$install_raycast" = true ]; then
    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
      echo "❌ Node.js/npm not found."
      echo "   Install Node.js first, then re-run:"
      echo "   ./install.sh --raycast"
      if [ "$AUTO_RAYCAST" = true ]; then
        exit 1
      fi
      echo ""
      echo "Skipping Raycast extension install (CLI is installed)."
      install_raycast=false
    fi
  fi

  if [ "$install_raycast" = true ]; then
    raycast_extension_dir="$HOME/.config/raycast/extensions"
    raycast_brag_dir="$raycast_extension_dir/brag"
    mkdir -p "$raycast_extension_dir"

    # Raycast provides a shared node_modules for local extensions.
    raycast_node_modules="/Applications/Raycast.app/Contents/Resources/RaycastNodeExtensions_RaycastNodeExtensions.bundle/Contents/Resources/api/node_modules"
	    if [ -d "$raycast_node_modules" ] && [ ! -e "$raycast_extension_dir/node_modules" ]; then
	      ln -s "$raycast_node_modules" "$raycast_extension_dir/node_modules"
	    fi

	    pushd "$SCRIPT_DIR/raycast-extension" >/dev/null
	    npm ci
	    npx ray build -e dist -o "$raycast_brag_dir"
	    # Raycast discovers local/development extensions via a dev log marker.
	    # `ray develop` creates this file; we create it here to make the extension appear
	    # without having to keep a dev server running.
	    touch "$raycast_brag_dir/dev.log"

	    # On some fresh installs, Raycast won't show local extensions until they've been
	    # imported at least once via `ray develop` (this is what `npm run dev` does).
	    echo ""
	    echo "🔌 Importing extension into Raycast (one-time)..."
	    if [ "$(uname -s)" = "Darwin" ] && ! pgrep -x Raycast >/dev/null 2>&1; then
	      echo "ℹ️  Raycast is not running; launching it..."
	      open -a Raycast >/dev/null 2>&1 || true
	      sleep 2
	    fi

	    # Start dev mode briefly to trigger import, then stop it so we don't leave a watcher running.
	    npx ray develop -I --exit-on-error >/dev/null 2>&1 &
	    dev_pid=$!
	    sleep 6
	    if kill -0 "$dev_pid" >/dev/null 2>&1; then
	      kill "$dev_pid" >/dev/null 2>&1 || true
	    fi
	    wait "$dev_pid" >/dev/null 2>&1 || true
	    popd >/dev/null

	    echo ""
	    echo "✅ Raycast extension built to: $raycast_brag_dir"
	    echo "   If it still doesn't appear, run: (cd raycast-extension && npm run dev)"
	  fi
	fi

echo ""
echo "🏆 Done. Start bragging:"
echo "  brag add \"Installed brag on a fresh Mac\""
echo ""
