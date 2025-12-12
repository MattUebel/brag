# 🏆 Installation Guide

Get ready to never forget your accomplishments again!

## Prerequisites

- Python 3.8+ *(macOS often does **not** ship with it preinstalled)*
- pip3
- Raycast *(optional, but highly recommended for the ✨ experience)*
- Node.js + npm *(only needed for Raycast extension)*

### macOS note: Xcode Command Line Tools prompt

On a fresh Mac, running `python3` (or `git`) may pop up a system prompt to install **Xcode Command Line Tools**.
That’s normal — you can install them, or install Python separately (Homebrew or python.org) and use that `python3`.

## 🚀 CLI Installation

### 1. Clone the repository

```bash
git clone <repo-url>
cd brag
```

### 2. Install the package

```bash
pip3 install -e .
```

> **Note:** If you get an error about `setup.py`, try upgrading pip first:
> ```bash
> pip3 install --upgrade pip setuptools wheel
> ```

### 3. Set up your shell

```bash
chmod +x setup_shell.sh
./setup_shell.sh
source ~/.zshrc  # or ~/.bashrc
```

> **Note:** `setup_shell.sh` only updates your `PATH`. It does **not** install the `brag` CLI by itself.

### 4. Verify it works

```bash
brag --help
```

You should see the help output. If not, the CLI was installed to `~/Library/Python/3.X/bin/brag` (on macOS). Run `setup_shell.sh` again or add that directory to your PATH manually.

### 5. Record your first brag! 🎉

```bash
brag add "Set up the brag CLI - already winning!"
```

---

## 🎨 Raycast Extension Installation

The Raycast extension gives you a beautiful UI for adding and searching brags without leaving your keyboard.

### 1. Navigate to the extension

```bash
cd raycast-extension
```

### 2. Install dependencies

```bash
npm install
```

### 3. Start the development server

```bash
npm run dev
```

This will:
- ✅ Build the extension
- ✅ Auto-import it into Raycast
- ✅ Hot-reload on changes

> **Important:** The [Raycast app](https://raycast.com/) must be installed on your Mac.

### 4. Use it!

Open Raycast and search for:
- **"Add Brag"** - Quick capture
- **"Search Brags"** - Find past wins
- **"Recent Brags"** - Last 7/14/30/90 days
- **"Export Brags"** - Generate reports

---

## 🔧 Troubleshooting

### CLI not found after install

The `brag` command lives in your Python user bin directory:
- **macOS:** `~/Library/Python/3.X/bin/brag`
- **Linux:** `~/.local/bin/brag`

Run `./setup_shell.sh` to add this to your PATH automatically.

### Raycast shows "command not found"

Raycast runs in a restricted shell environment. The extension handles this automatically by searching common installation paths. If yours is non-standard, edit `raycast-extension/src/config.ts`.

### TypeScript errors when building

Use `npm run dev` instead of `npm run build`. The dev server is more forgiving and works correctly even with type warnings.

---

## 📚 Next Steps

- [RAYCAST_INTEGRATION.md](RAYCAST_INTEGRATION.md) - Get the most out of Raycast
- [DEVELOPMENT.md](DEVELOPMENT.md) - Want to contribute?
- [ARCHITECTURE.md](ARCHITECTURE.md) - Curious how it works?

---

*Now go do something worth bragging about! 💪*
