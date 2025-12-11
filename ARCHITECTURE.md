# Brag CLI - Complete Architecture & Build Guide

This document provides comprehensive instructions for an LLM agent to build this project from scratch, including all architectural decisions, design patterns, and implementation considerations.

## Project Overview

**Name:** Brag CLI 
**Purpose:** A command-line tool with Raycast integration for tracking professional accomplishments to support performance reviews 
**Core Philosophy:** Simple, local-first, AI-friendly data format with minimal dependencies

## Design Decisions & Rationale

### 1. Storage Architecture

**Decision:** JSONL (JSON Lines) files organized by date hierarchy 
**Rationale:**
- **Human-readable:** Easy to inspect, debug, and manually edit if needed
- **Git-friendly:** Line-based format works well with version control
- **AI-friendly:** Easy for LLMs to parse, aggregate, and generate reports from
- **Append-only:** Safe concurrent writes, no database complexity
- **Time-based partitioning:** Natural organization for performance reviews and reduces file sizes

**File Structure:**
```
~/.brag/data/
 2025/
   12/
     09.jsonl  # One file per day
     10.jsonl
```

**Entry Format:**
```json
{
 "timestamp": "2025-12-09T17:00:00Z",
 "content": "Accomplishment description",
 "tags": ["feature", "performance"],
 "project": "auth-service"
}
```

**Alternatives Considered:**
- SQLite: Too complex for simple append operations, harder to inspect
- Single JSON file: Poor concurrency, harder to version control
- Database: Overkill, requires additional dependencies, not portable

### 2. Technology Stack

**Python CLI (Core):**
- **Language:** Python 3.8+ (widely available, excellent stdlib)
- **Dependencies:** NONE (uses only stdlib)
- **Package Manager:** pip with pyproject.toml (modern Python packaging)
- **Rationale:** Maximum portability, no dependency hell, runs anywhere

**Raycast Extension (UI):**
- **Language:** TypeScript + React
- **Framework:** @raycast/api
- **Rationale:** Native Raycast integration, beautiful UI, keyboard-first workflow

**Dev Tools:**
- pytest: Industry standard testing
- black: Opinionated formatter, no configuration needed
- flake8: Linting without heavy type checking
- isort: Import organization
- pre-commit: Automated quality gates

### 3. CLI Design Patterns

**Command Structure:**
```
brag add [content] [--tags TAG...] [--project PROJECT] [--edit]
brag list [--days N] [--date DATE]
brag export [--start DATE] [--end DATE] [--format FORMAT]
```

**Design Principles:**
1. **Immediate value:** `brag add "text"` is fastest path to success
2. **Sensible defaults:** Most common use cases need minimal flags
3. **Editor integration:** `--edit` flag for multi-line entries
4. **UNIX philosophy:** Do one thing well, composable with other tools

**Editor Selection Logic:**
```python
editor = os.environ.get("EDITOR", os.environ.get("VISUAL", "vim"))
```
Respects user preferences, falls back to vim (universally available).

### 4. Code Organization

**Three-layer architecture:**

```
brag/
 models.py    # Data structures and serialization
 storage.py   # File I/O and date-based partitioning
 cli.py       # Command-line interface and argument parsing
```

**Separation of Concerns:**
- **models.py:** Pure data, no I/O, serialization/deserialization
- **storage.py:** File operations, knows about directory structure
- **cli.py:** User interaction, argument parsing, output formatting

**Why this matters:**
- Easy to test each layer independently
- Models can be used in Raycast extension
- Storage layer could be swapped (e.g., cloud sync) without changing models
- CLI can be extended without touching storage logic

### 5. Raycast Integration Architecture

**Four Commands (Distinct Use Cases):**

1. **Add Brag:** Quick capture form
  - Text area for content
  - Project autocomplete (learns from history)
  - Tag picker with preset options
  - Option to open full editor

2. **Search Brags:** Full-text search across all time
  - Live search as user types
  - Multiple copy formats (Markdown, JSON, plain text)

3. **Recent Brags:** Time-filtered view
  - Dropdown: 7, 14, 30, 60, 90 days
  - Perfect for weekly reviews

4. **Export Brags:** Date range export
  - Custom start/end dates
  - Multiple formats
  - Auto-copy to clipboard

**Integration Approach:**
- Calls `brag` CLI commands via shell
- Parses JSONL files directly for search/display
- No separate API or server needed
- Works entirely with local filesystem

### 6. Testing Strategy

**Coverage Goals:**
- Models: 100% (pure functions, easy to test)
- Storage: 100% (critical correctness)
- CLI: Best effort (harder to test interactive features)
- Overall: >65% (current: 68%)

**Test Organization:**
```
tests/
 test_models.py    # 7 tests - Data structure tests
 test_storage.py   # 9 tests - File I/O, date ranges
 test_cli.py       # 7 tests - Command execution
```

**What's Tested:**
- Entry creation and serialization
- Multi-line content handling
- Directory creation and file permissions
- Date-based file path generation
- Adding and retrieving entries
- Date range queries
- Editor integration
- Tag and project metadata

**What's Not Tested (Intentionally):**
- Interactive editor sessions (hard to automate)
- Shell environment setup
- Raycast UI (tested manually)

### 7. Quality Automation

**Pre-commit Hooks:**
```yaml
- Code formatting (black, isort)
- Linting (flake8)
- Tests (pytest)
- File hygiene (trailing whitespace, EOF)
- Config validation (YAML, JSON, TOML)
```

**Philosophy:** Catch errors before commit, not in CI. Fast feedback loop.

**CI/CD Ready:**
- GitHub Actions workflow template included
- Runs on multiple Python versions
- Can be extended for automatic releases

## Implementation Guide for LLM Agent

### Phase 1: Core Data Model (models.py)

**Requirements:**
1. BragEntry class with fields: timestamp, content, tags, project
2. ISO 8601 timestamp format with Z suffix
3. to_dict() and from_dict() methods
4. to_json() and from_json() methods using stdlib json module
5. Default timestamp to current UTC time if not provided
6. Tags default to empty list, project defaults to None

**Key Implementation Details:**
- Use `datetime.utcnow().isoformat() + "Z"` for timestamps
- Support multi-line content (preserve newlines)
- No validation beyond Python type hints
- Keep it simple: ~50 lines total

### Phase 2: Storage Layer (storage.py)

**Requirements:**
1. BragStorage class with data_dir parameter
2. Default data_dir to `~/.brag/data`
3. File path: `{data_dir}/{YYYY}/{MM}/{DD}.jsonl`
4. add_entry() method - append to appropriate file
5. get_entries() method - read all entries for a date
6. get_entries_range() method - read entries across date range
7. list_available_dates() method - find all dates with entries

**Key Implementation Details:**
- Use pathlib.Path for cross-platform compatibility
- Create directories with `mkdir(parents=True, exist_ok=True)`
- Parse timestamp to determine which file to use
- Handle missing files gracefully (return empty list)
- One line per entry in JSONL format
- Use `datetime.fromisoformat()` for timestamp parsing

**File Format Example:**
```jsonl
{"timestamp": "2025-12-09T17:00:00Z", "content": "First entry", "tags": [], "project": null}
{"timestamp": "2025-12-09T18:30:00Z", "content": "Second entry", "tags": ["feature"], "project": "api"}
```

### Phase 3: CLI Interface (cli.py)

**Requirements:**
1. Use argparse for command-line parsing
2. Three subcommands: add, list, export
3. Global --data-dir option (defaults to None, storage handles default)

**Command Specifications:**

**add:**
- Positional: content (optional if --edit)
- Flags: --tags (multiple), --project, --edit
- If --edit, open $EDITOR (fallback: $VISUAL, vim)
- Create temp file, launch editor, read result
- If content empty after edit, abort with error
- Print success message with timestamp

**list:**
- Flags: --days N (default 7), --date YYYY-MM-DD
- If --date provided, show only that date
- Otherwise show last N days
- Format: Date header, bulleted list, tags/project
- Handle no entries gracefully

**export:**
- Flags: --start DATE, --end DATE, --format (json/markdown/text)
- Default: all entries, JSON format
- JSON: output array of entry objects
- Markdown: group by date with headers
- Text: simple bullet list

**Key Implementation Details:**
- Use subprocess.call() for editor
- tempfile.NamedTemporaryFile for editor content
- Clean up temp files in finally block
- Use argparse subparsers for commands
- Entry point: main() function for console_scripts

### Phase 4: Package Configuration (pyproject.toml)

**Requirements:**
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "brag-cli"
version = "0.1.0"
description = "A CLI tool to track your accomplishments for performance reviews"
requires-python = ">=3.8"
dependencies = []  # No runtime dependencies!

[project.optional-dependencies]
dev = [
   "pytest>=7.4.0",
   "pytest-cov>=4.1.0",
   "black>=23.12.0",
   "flake8>=7.0.0",
   "isort>=5.13.0",
   "pre-commit>=3.6.0",
]

[project.scripts]
brag = "brag.cli:main"
```

### Phase 5: Shell Setup (setup_shell.sh)

**Purpose:** Add brag CLI to PATH after local installation

**Requirements:**
1. Detect shell (zsh or bash)
2. Add pip3 user bin directory to PATH
3. Update appropriate rc file (.zshrc or .bashrc)
4. Make idempotent (don't add multiple times)

**Implementation:**
```bash
#!/bin/bash
BIN_DIR="$(python3 -m site --user-base)/bin"
# Check if already in PATH
# Add to shell rc file with comment marker
# Source the rc file
```

### Phase 6: Testing Suite

**Test Structure:**

**test_models.py:**
- Entry creation with/without metadata
- Serialization to dict and JSON
- Deserialization from dict and JSON
- Multi-line content handling
- Timestamp handling

**test_storage.py:**
- Storage initialization
- File path generation for dates
- Directory creation
- Adding entries
- Retrieving entries for single date
- Retrieving entries for date range
- Listing available dates
- Multiple entries same day
- Handling missing files

**test_cli.py:**
- Add command with content
- Add command with tags and project
- Add command with editor (mock editor)
- List command with no entries
- Export command with JSON output
- Multi-line content via CLI

**Test Utilities:**
- Use pytest fixtures for temp directories
- Mock os.environ for editor tests
- Mock subprocess.call for editor tests
- Use tmpdir for isolated test data

### Phase 7: Raycast Extension

**Directory Structure:**
```
raycast-extension/
 src/
   add-brag.tsx       # Form for adding entries
   search-brags.tsx   # Search with full-text
   recent-brags.tsx   # Time-filtered view
   export-brags.tsx   # Date range export
 package.json         # Extension manifest
```

**Key Components:**

**add-brag.tsx:**
- Form with text area, project field, tag picker
- Submit: execute `brag add` command via shell
- Show success toast
- Option to open editor with ActionPanel

**search-brags.tsx:**
- Read all JSONL files from data directory
- Filter entries by search term (content, tags, project)
- Display in list with metadata
- Actions: copy as Markdown/JSON/text

**recent-brags.tsx:**
- Dropdown for time period selection
- Filter entries by date range
- Copy all as Markdown action
- Individual entry actions

**export-brags.tsx:**
- Date pickers for start/end
- Format dropdown
- Execute export command
- Copy result to clipboard automatically

**Shared Utilities:**
```typescript
// Read JSONL file
function readBragFile(path: string): BragEntry[]

// Format entry as Markdown
function formatAsMarkdown(entries: BragEntry[]): string

// Execute brag CLI command
function executeBragCommand(args: string[]): Promise<string>
```

### Phase 8: Documentation

**Required Files:**

**README.md:**
- Quick start guide
- Installation instructions
- Usage examples for CLI and Raycast
- Data storage explanation
- Development setup

**INSTALL.md:**
- Step-by-step installation
- Prerequisites (Python 3.8+, pip3)
- Shell setup instructions
- Raycast installation
- Troubleshooting

**DEVELOPMENT.md:**
- Dev environment setup
- Running tests
- Code quality tools
- Pre-commit hooks
- Makefile commands

**RAYCAST_INTEGRATION.md:**
- Features overview
- Workflow examples
- Keyboard shortcuts
- Troubleshooting

### Phase 9: Development Tools

**Makefile:**
```makefile
install:
  pip3 install -e .

install-dev:
  pip3 install -e ".[dev]"
  pre-commit install

test:
  pytest

test-coverage:
  pytest --cov=brag --cov-report=html
  open htmlcov/index.html

format:
  black brag tests
  isort brag tests

lint:
  flake8 brag tests --max-line-length=100

clean:
  rm -rf build dist *.egg-info .pytest_cache htmlcov
```

**pre-commit-config.yaml:**
- trailing-whitespace
- end-of-file-fixer
- check-yaml, check-json, check-toml
- black, isort, flake8
- pytest (fail fast)

**pytest.ini:**
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = --cov=brag --cov-report=term-missing --cov-report=html
```

## Critical Implementation Considerations

### 1. Date Handling

**Always use UTC:**
- Avoids timezone confusion
- Consistent across systems
- ISO 8601 format with Z suffix

**Parse dates carefully:**
```python
# Correct: handles Z suffix
datetime.fromisoformat(timestamp.replace("Z", "+00:00"))

# Incorrect: doesn't handle Z
datetime.fromisoformat(timestamp)  # ValueError
```

### 2. File Operations

**Always create parent directories:**
```python
file_path.parent.mkdir(parents=True, exist_ok=True)
```

**Handle missing files gracefully:**
```python
if not file_path.exists():
   return []
```

**Use context managers:**
```python
with open(file_path, "a") as f:
   f.write(entry.to_json() + "\n")
```

### 3. Editor Integration

**Clean up temp files:**
```python
try:
   subprocess.call([editor, temp_path])
   # ... read result
finally:
   os.unlink(temp_path)  # Always clean up
```

**Respect user environment:**
```python
editor = os.environ.get("EDITOR", os.environ.get("VISUAL", "vim"))
```

### 4. User Experience

**Provide feedback:**
- Print success messages with relevant info
- Show helpful error messages
- Use colors/icons if terminal supports it

**Default to most common use case:**
- `brag list` defaults to last 7 days (not all time)
- `brag add` goes straight to content (not menu)

**Make it forgiving:**
- Accept various date formats
- Trim whitespace from content
- Handle empty tag lists gracefully

### 5. Raycast Best Practices

**Use ActionPanel for discoverability:**
- Primary action: Copy as Markdown
- Secondary actions: Copy as JSON, Plain Text
- Keyboard shortcuts visible in UI

**Show metadata clearly:**
- Tags with visual icons
- Project in subtitle
- Timestamp in readable format

**Handle edge cases:**
- No entries found: show empty state with helpful message
- Large result sets: implement pagination
- Long content: truncate in list, show full in detail

## Build Order

**Recommended sequence for LLM agent:**

1. **Setup project structure:**
  - Create directory structure
  - Create pyproject.toml
  - Create __init__.py files

2. **Implement models.py:**
  - BragEntry class
  - Serialization methods
  - Test immediately

3. **Implement storage.py:**
  - BragStorage class
  - File path logic
  - Add/retrieve methods
  - Test immediately

4. **Implement cli.py:**
  - Argument parsing
  - Add command
  - List command
  - Export command
  - Test manually and with pytest

5. **Create shell setup:**
  - setup_shell.sh script
  - Test on actual shell

6. **Add development tools:**
  - pytest.ini
  - .pre-commit-config.yaml
  - Makefile
  - Run `make install-dev`

7. **Write tests:**
  - test_models.py
  - test_storage.py
  - test_cli.py
  - Achieve >65% coverage

8. **Create Raycast extension:**
  - package.json manifest
  - add-brag.tsx
  - search-brags.tsx
  - recent-brags.tsx
  - export-brags.tsx
  - Test in Raycast

9. **Write documentation:**
  - README.md
  - INSTALL.md
  - DEVELOPMENT.md
  - RAYCAST_INTEGRATION.md

10. **Create installation scripts:**
   - install_raycast.sh
   - Test end-to-end installation

## Expected Outcomes

**After following this guide, the project should have:**

- ✅ 661 lines of Python code
- ✅ 23 passing tests with 68% coverage
- ✅ 4 CLI commands (add, list, export, plus help)
- ✅ 4 Raycast commands (Add, Search, Recent, Export)
- ✅ Pre-commit hooks configured and working
- ✅ Comprehensive documentation (5 markdown files)
- ✅ Zero runtime dependencies (Python stdlib only)
- ✅ Working installation scripts
- ✅ Beautiful Raycast UI with forms, search, and export
- ✅ Local-first, privacy-preserving data storage
- ✅ AI-friendly JSONL format for LLM integration

## Success Criteria

**The implementation is correct if:**

1. `pip3 install -e .` installs successfully
2. `brag add "test"` creates entry in correct file
3. `brag list` shows the entry
4. `brag export` outputs valid JSON
5. All 23 tests pass with `pytest`
6. Pre-commit hooks run without errors
7. Raycast extension imports and all commands work
8. Data is stored in `~/.brag/data/YYYY/MM/DD.jsonl`
9. Each entry is valid JSON on one line
10. No external dependencies in production code

## Common Pitfalls to Avoid

1. **Don't add unnecessary dependencies** - Use Python stdlib
2. **Don't overcomplicate storage** - JSONL is perfect, don't use a database
3. **Don't skip date validation** - ISO 8601 parsing is strict
4. **Don't forget UTC** - Always use UTC for timestamps
5. **Don't ignore file cleanup** - Clean up temp files in finally blocks
6. **Don't make commands verbose** - Quick capture is the goal
7. **Don't forget documentation** - This is a user-facing tool
8. **Don't skip testing** - File operations need thorough testing
9. **Don't hardcode paths** - Use os.path.expanduser() and pathlib
10. **Don't break the UNIX philosophy** - Do one thing well

## Extension Points

**Future enhancements this architecture supports:**

- **Cloud sync:** Swap storage layer for cloud backend
- **Web UI:** Serve JSONL files via simple web server
- **Mobile app:** Read JSONL files from sync folder
- **AI integration:** LLM can parse JSONL directly
- **Git integration:** Track changes with git
- **Analytics:** Parse JSONL to generate insights
- **Templates:** Add entry templates for common types
- **Reminders:** Periodic prompts to add entries
- **Export formats:** PDF, HTML, custom templates
- **Team sharing:** Aggregate multiple user's brags

**All without changing core architecture.**

---

**This document is intended to be a complete specification for rebuilding this project from scratch. An LLM agent following these instructions should produce a functionally identical system.**

