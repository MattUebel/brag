# Contributing to Brag CLI

First off, thanks for considering contributing to Brag! 🏆

This project was "vibe-coded" - built with enthusiasm on a creative journey. We welcome contributions that keep that spirit alive while making the tool more useful for everyone.

## Ways to Contribute

### 🐛 Report Bugs
Found something broken? Open an issue with:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Your environment (OS, Python version, shell)

### 💡 Suggest Features
Have an idea? We'd love to hear it! Open an issue with:
- What problem it solves
- How you imagine it working
- Any alternatives you considered

### 🔧 Submit Pull Requests
Ready to code? Awesome!

1. **Fork the repo** and clone it locally
2. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes** and test them:
   ```bash
   pip install -e ".[dev]"
   make test
   ```
4. **Commit with a clear message**:
   ```bash
   git commit -m "Add amazing feature that does X"
   ```
5. **Push and open a PR**:
   ```bash
   git push origin feature/amazing-feature
   ```

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/brag.git
cd brag

# Install in development mode with dev dependencies
pip install -e ".[dev]"

# Run tests
make test

# Format code
make format

# Run linting
make lint

# For Raycast extension
cd raycast-extension
npm install
npm run dev
```

## Code Style

### Python
- We use **black** for formatting (just run `make format`)
- We use **flake8** for linting
- We use **isort** for import sorting
- No external dependencies in the main CLI (stdlib only!)

### TypeScript (Raycast)
- Standard Raycast/ESLint config
- Use `npm run lint` to check

## Project Structure

```
brag/
├── brag/              # Python CLI source
│   ├── cli.py         # Command-line interface
│   ├── models.py      # Data structures
│   └── storage.py     # File I/O
├── tests/             # Python tests
├── raycast-extension/ # Raycast UI
│   └── src/           # TypeScript source
└── docs/              # Documentation
```

## Testing

```bash
# Run all tests
make test

# Run with coverage
make test-coverage

# Run specific test
pytest tests/test_models.py -v
```

## What We're Looking For

### Great PRs typically:
- ✅ Solve a real problem or add clear value
- ✅ Include tests for new functionality
- ✅ Follow the existing code style
- ✅ Have clear commit messages
- ✅ Don't add unnecessary dependencies

### Ideas We Love:
- Better error messages
- New export formats
- Improved Raycast UX
- Documentation improvements
- Performance optimizations
- Accessibility improvements

### Things to Avoid:
- Breaking changes without discussion first
- External dependencies in the Python CLI
- Overly complex solutions to simple problems

## Questions?

Not sure about something? Open an issue and ask! We're friendly. 🙂

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT).

---

*Thanks for making Brag better! Your contributions are something to brag about. 🎉*
