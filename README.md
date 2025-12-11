# Brag CLI

A command-line tool with Raycast integration for tracking professional accomplishments to support performance reviews.

## Features

- **Local-first**: Data stored in JSONL files on your machine.
- **CLI**: Simple commands to add, list, and export brags.
- **Raycast Integration**: Beautiful UI for quick capture and search.
- **AI-friendly**: Data format is perfect for LLM parsing and reporting.

## Quick Start

### Installation

```bash
pip3 install -e .
./setup_shell.sh
```

### Usage

Add a brag:
```bash
brag add "Shipped the new auth service" --tags feature --project auth
```

List recent brags:
```bash
brag list
```

Export to JSON:
```bash
brag export --format json
```

See [INSTALL.md](INSTALL.md) for detailed installation instructions.
See [RAYCAST_INTEGRATION.md](RAYCAST_INTEGRATION.md) for Raycast setup.
