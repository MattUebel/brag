# Development Guide

## Setup

1. Install development dependencies:
   ```bash
   make install-dev
   ```

2. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

## Testing

Run tests with pytest:
```bash
make test
```

Check coverage:
```bash
make test-coverage
```

## Code Quality

Format code:
```bash
make format
```

Lint code:
```bash
make lint
```

## Project Structure

- `brag/`: Python package source
- `tests/`: Pytest suite
- `raycast-extension/`: Raycast extension source
- `~/.brag/data/`: Default data storage location
