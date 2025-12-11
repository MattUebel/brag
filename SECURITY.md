# Security Policy

## Supported Versions

Use the latest version of the CLI and Raycast extension to ensure you have the latest security patches.

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1.0 | :x:                |

## Reporting a Vulnerability

We take the security of this project seriously. If you find a vulnerability, please report it responsibly.

### How to Report

1.  **Do not** open a public GitHub issue for sensitive security vulnerabilities.
2.  Email the maintainer at `mattuebel@gmail.com` (or the email listed in the commit log) with the subject "Security Vulnerability in Brag".
3.  Include details about the vulnerability, how to reproduce it, and the potential impact.

### Response Timeline

*   We will acknowledge your report within 48 hours.
*   We will provide an estimated timeline for a fix within 1 week.
*   We will notify you when the fix is released.

## Security Best Practices for Users

*   **Data Storage:** Please be aware that `brag` stores your data in plain text in `~/.brag/data`. Do not use this tool to store passwords, API keys, or other highly sensitive secrets.
*   **Updates:** regularly update the tool (`pip install --upgrade brag-cli` and pull the latest Raycast extension code) to receive security fixes.
