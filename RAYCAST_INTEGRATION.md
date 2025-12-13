# Raycast Integration

The Brag Raycast extension provides a seamless way to track accomplishments without leaving your keyboard.

## Installation

1. Navigate to `raycast-extension/` directory
2. Run `npm install` to install dependencies
3. Run `npm run dev` to start the development server and auto-import the extension
4. The extension will appear in Raycast immediately

### Recommended (all-in-one)

From the repo root, you can also run:

```bash
./install.sh --raycast
```

> **Important:** Use `npm run dev` (not `npm run build`). The dev server handles TypeScript compilation more leniently and hot-reloads on changes.

## Commands

### Add Brag
Quickly capture an accomplishment.
- **Content**: What you did (supports Markdown)
- **Project**: Associated project (optional)
- **Tags**: Comma-separated tags (optional)

Press Enter to save. The brag is immediately written to your local storage.

### Search Brags
Full-text search through your entire history.
- Type to filter results in real-time
- **Enter**: Copy content to clipboard
- **Cmd+Shift+C**: Copy as JSON

### Recent Brags
View accomplishments from the last 7, 14, 30, or 90 days.
- Use the dropdown to select time period
- Perfect for weekly updates, standups, or performance reviews
- **Enter**: Copy content to clipboard
- **Cmd+Shift+C**: Copy as JSON

### Export Brags
Export data for a specific date range.
- **Start Date**: Beginning of export range (optional)
- **End Date**: End of export range (optional)
- **Format**: JSON, Markdown, or Plain Text

Output is automatically copied to clipboard after export.

## Troubleshooting

### "Command not found: brag"
The Raycast extension runs in a restricted shell environment without access to your custom PATH. The extension includes automatic path discovery for common installation locations:
- `~/Library/Python/3.X/bin/brag` (macOS pip --user)
- `~/.local/bin/brag` (pipx, Linux)
- `/usr/local/bin/brag` (system-wide)
- `/opt/homebrew/bin/brag` (Homebrew)

If `brag` is installed elsewhere, edit `raycast-extension/src/config.ts` to add your path.

### Extension not appearing in Raycast
Make sure `npm run dev` is running. This command:
1. Compiles the TypeScript
2. Registers the extension with Raycast
3. Watches for file changes

### Empty list in Search/Recent Brags
This means no brags have been recorded yet. Use "Add Brag" to create your first entry.

### TypeScript errors in VS Code
These can be ignored. The extension works correctly at runtime via `npm run dev` even if the IDE shows type errors. This is due to React type definition conflicts between the project and @raycast/api.

## Architecture Notes

The extension calls the `brag` CLI via `child_process.execFile()`. This approach:
- Keeps the CLI as the single source of truth
- Ensures data consistency between CLI and Raycast
- Avoids duplicating storage logic

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed technical documentation.
