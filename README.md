# Brag CLI

A command-line tool with Raycast integration for tracking professional accomplishments to support performance reviews.

## Features

- **Local-first**: Data stored in JSONL files on your machine (`~/.brag/data/`)
- **CLI**: Simple commands to add, list, and export brags
- **Raycast Integration**: Beautiful UI for quick capture and search
- **AI-friendly**: JSONL format is perfect for LLM parsing and reporting
- **Zero dependencies**: Python CLI uses only stdlib

## Quick Start

### CLI Installation

```bash
# Install the package
pip3 install -e .

# Add to PATH (run once)
chmod +x setup_shell.sh
./setup_shell.sh
source ~/.zshrc  # or ~/.bashrc
```

### Raycast Extension

```bash
cd raycast-extension
npm install
npm run dev  # Starts dev server and imports into Raycast
```

## Usage

### Add a brag
```bash
brag add "Shipped the new auth service" --tags feature --project auth
```

### Open editor for multi-line entry
```bash
brag add --edit
```

### List recent brags
```bash
brag list              # Last 7 days
brag list --days 30    # Last 30 days
```

### Export brags
```bash
brag export --format json
brag export --format markdown --start 2024-01-01
```

## Data Storage

Brags are stored as JSONL files organized by date:
```
~/.brag/data/
  2025/
    12/
      09.jsonl
      10.jsonl
```

Each entry is a single JSON line:
```json
{"timestamp": "2025-12-09T17:00:00Z", "content": "Shipped auth service", "tags": ["feature"], "project": "auth"}
```

## Documentation

- [INSTALL.md](INSTALL.md) - Detailed installation instructions
- [RAYCAST_INTEGRATION.md](RAYCAST_INTEGRATION.md) - Raycast extension setup and usage
- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and testing
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture and design decisions
