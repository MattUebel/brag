# Installation Guide

## Prerequisites

- Python 3.8+
- pip3
- Raycast (optional, for UI)

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

3. Setup shell integration (adds `brag` to PATH):
   ```bash
   ./setup_shell.sh
   source ~/.zshrc  # or ~/.bashrc
   ```

4. Verify installation:
   ```bash
   brag --help
   ```

## Raycast Extension Installation

1. Navigate to the extension directory:
   ```bash
   cd raycast-extension
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

   > **Note:** The extension scripts (`npm run dev`, etc.) rely on the Raycast CLI, which is installed locally by `npm install`. However, running the extension itself requires the [Raycast application](https://raycast.com/) to be installed on your Mac.

3. Import into Raycast:
   - Open Raycast
   - Run "Import Extension"
   - Select the `raycast-extension` directory

See [RAYCAST_INTEGRATION.md](RAYCAST_INTEGRATION.md) for usage details.
