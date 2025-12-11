import { homedir } from "os";
import { join } from "path";

// Raycast extensions run in a restricted shell environment without access to
// the user's custom PATH. We need to specify the full path to the brag CLI.
// 
// Common installation locations:
// - pip install --user: ~/Library/Python/3.X/bin/brag (macOS)
// - pip install: /usr/local/bin/brag
// - pipx: ~/.local/bin/brag
//
// We check multiple locations and use the first one that exists.

const possiblePaths = [
    join(homedir(), "Library/Python/3.9/bin/brag"),
    join(homedir(), "Library/Python/3.10/bin/brag"),
    join(homedir(), "Library/Python/3.11/bin/brag"),
    join(homedir(), "Library/Python/3.12/bin/brag"),
    join(homedir(), ".local/bin/brag"),
    "/usr/local/bin/brag",
    "/opt/homebrew/bin/brag",
];

import { existsSync } from "fs";

let cachedPath: string | null = null;

export function getBragPath(): string {
    if (cachedPath) return cachedPath;

    for (const p of possiblePaths) {
        if (existsSync(p)) {
            cachedPath = p;
            return p;
        }
    }

    // Fallback - try 'brag' and hope it's in PATH (it usually won't be in Raycast)
    // This will likely fail, but provides a clear error message.
    return "brag";
}
