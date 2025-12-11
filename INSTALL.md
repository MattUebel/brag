# Installation Guide

## Prerequisites

- Python 3.8+
- pip3
- Raycast (optional, for UI integration)
- Node.js and npm (optional, required for Raycast extension development)

## CLI Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd brag
   ```

2. Install the package:
   ```bash
   pip3 install -e .
   ```
   
   > **Note:** If `pip install -e .` fails with an error about `setup.py`, the project includes a minimal `setup.py` shim for compatibility. If you still have issues, try upgrading pip first: `pip3 install --upgrade pip setuptools wheel`

3. Setup shell integration (adds `brag` to PATH):
   ```bash
   chmod +x setup_shell.sh
   ./setup_shell.sh
   source ~/.zshrc  # or ~/.bashrc
   ```

4. Verify installation:
   ```bash
   brag --help
   ```

   If `brag` is still not found, the CLI was likely installed to `~/Library/Python/3.X/bin/brag` (on macOS). You can run it directly with the full path, or ensure that directory is in your PATH.

## Raycast Extension Installation

1. Navigate to the extension directory:
   ```bash
   cd raycast-extension
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. **Start the development server** (recommended):
   ```bash
   npm run dev
   ```
   
   This will:
   - Build the extension
   - Auto-import it into Raycast
   - Hot-reload on file changes
   - Handle TypeScript compilation more leniently

   > **Note:** The Raycast application must be installed on your Mac. Get it from [raycast.com](https://raycast.com/).

4. **Alternative: Manual import**
   - Open Raycast
   - Run "Import Extension"
   - Select the `raycast-extension` directory

## Troubleshooting

### CLI not found
The `brag` CLI is installed to your Python user bin directory. Common locations:
- macOS: `~/Library/Python/3.X/bin/brag`
- Linux: `~/.local/bin/brag`

Run `setup_shell.sh` to add this to your PATH automatically.

### Raycast extension can't find `brag`
Raycast runs in a restricted shell environment without your custom PATH. The extension includes a `config.ts` file that searches common installation locations automatically. If `brag` is installed in a non-standard location, you may need to edit `raycast-extension/src/config.ts`.

### TypeScript build errors
Use `npm run dev` instead of `npm run build`. The dev server is more lenient with TypeScript errors and works correctly even when strict type checking fails.

See [RAYCAST_INTEGRATION.md](RAYCAST_INTEGRATION.md) for usage details.
See [ARCHITECTURE.md](ARCHITECTURE.md) for technical details and gotchas.
