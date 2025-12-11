# 🏆 Brag CLI

**Stop forgetting your wins. Start bragging.**

A command-line tool with Raycast integration for tracking professional accomplishments. Perfect for performance reviews, 1:1s, and remembering that you actually *do* get stuff done.

## ✨ Features

- **📁 Local-first**: Your brags stay on your machine (`~/.brag/data/`)
- **⚡ Lightning fast**: Add a brag in seconds from terminal or Raycast
- **🤖 AI-friendly**: JSONL format is perfect for LLM analysis
- **🎨 Raycast UI**: Beautiful interface for quick capture and search
- **📦 Zero dependencies**: Python CLI uses only stdlib

## 🚀 Quick Start

### Install the CLI

```bash
# Clone and install
git clone <repo-url>
cd brag
pip3 install -e .

# Set up your shell (one-time)
chmod +x setup_shell.sh
./setup_shell.sh
source ~/.zshrc  # or ~/.bashrc

# 🎉 You're ready to brag!
brag add "Set up the brag CLI - already winning!"
```

### Install Raycast Extension (Optional)

```bash
cd raycast-extension
npm install
npm run dev  # Starts dev server and imports into Raycast
```

## 📝 Usage

### Record your wins

```bash
# Quick brag
brag add "Shipped the new auth service"

# With metadata
brag add "Fixed critical bug in prod" --tags bug,urgent --project payments

# Multi-line (opens your editor)
brag add --edit
```

### Review your accomplishments

```bash
# What did I do this week?
brag list

# What about this month?
brag list --days 30
```

### Export for performance reviews

```bash
# Get everything as JSON (great for AI analysis)
brag export --format json

# Markdown for docs
brag export --format markdown --start 2024-01-01

# Just Q4
brag export --start 2024-10-01 --end 2024-12-31
```

## 🗂️ Data Storage

Your brags live in `~/.brag/data/` organized by date:

```
~/.brag/data/
  2025/
    12/
      09.jsonl  ← One file per day
      10.jsonl
      11.jsonl
```

Each entry is a single JSON line:
```json
{"timestamp": "2025-12-09T17:00:00Z", "content": "Shipped auth service", "tags": ["feature"], "project": "auth"}
```

## 🗑️ Uninstall

Changed your mind? No hard feelings!

```bash
./uninstall.sh
```

This will:
- Remove the CLI from pip
- Clean up your shell PATH
- Remove Raycast extension files
- Optionally delete your brag data (you'll be asked)

## 🎯 Why Brag?

Because when review season comes around, you'll thank yourself for having a record of:
- That bug you fixed at 2am
- The feature that seemed small but took a week
- The time you helped onboard the new team member
- All those "quick" tasks that added up

**Your future self will thank you. Start bragging today.**

## 📚 Documentation

- [INSTALL.md](INSTALL.md) - Detailed installation guide
- [RAYCAST_INTEGRATION.md](RAYCAST_INTEGRATION.md) - Raycast extension setup
- [DEVELOPMENT.md](DEVELOPMENT.md) - Contributing and development
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical deep-dive

---

*Built with ❤️ for developers who forget how awesome they are.*
