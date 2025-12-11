import argparse
import datetime
import json
import os
import subprocess  # nosec
import sys
import tempfile
from typing import List

from brag.models import BragEntry
from brag.storage import BragStorage


def get_editor() -> str:
    return os.environ.get("EDITOR", os.environ.get("VISUAL", "vim"))


def open_editor(initial_content: str = "") -> str:
    editor = get_editor()
    with tempfile.NamedTemporaryFile(suffix=".md", mode="w+", delete=False) as tf:
        tf.write(initial_content)
        tf_path = tf.name

    try:
        subprocess.call([editor, tf_path])  # nosec
        with open(tf_path, "r") as f:
            return f.read().strip()
    finally:
        if os.path.exists(tf_path):
            os.unlink(tf_path)


def cmd_add(args, storage: BragStorage):
    content = " ".join(args.content) if args.content else ""

    if args.edit:
        # Explicit editor request
        content = open_editor(content)
    elif not content:
        # No content provided - prompt interactively (avoids shell escaping issues!)
        if sys.stdin.isatty():
            print(
                "🏆 What did you accomplish? (Press Enter twice to save, Ctrl+C to cancel)"
            )
            lines = []
            try:
                while True:
                    line = input()
                    if line == "" and lines and lines[-1] == "":
                        # Two empty lines = done
                        lines.pop()  # Remove the trailing empty line
                        break
                    lines.append(line)
                content = "\n".join(lines).strip()
            except (KeyboardInterrupt, EOFError):
                print("\nCancelled.")
                sys.exit(0)
        else:
            # Non-interactive, read from stdin
            content = sys.stdin.read().strip()

    if not content:
        print("Error: Empty content, aborting.")
        sys.exit(1)

    entry = BragEntry(content=content, tags=args.tags or [], project=args.project)
    storage.add_entry(entry)
    print(f"✅ Brag added for {entry.timestamp}")


def cmd_list(args, storage: BragStorage):
    if args.date:
        entries = storage.get_entries(args.date)
        print_entries(entries, args.date)
    else:
        # Default to last N days
        end_date = datetime.date.today()
        start_date = end_date - datetime.timedelta(days=args.days)
        entries = storage.get_entries_range(
            start_date.isoformat(), end_date.isoformat()
        )

        # Group by date for display
        entries_by_date = {}
        for entry in entries:
            date_str = entry.timestamp.split("T")[0]
            if date_str not in entries_by_date:
                entries_by_date[date_str] = []
            entries_by_date[date_str].append(entry)

        for date_str in sorted(entries_by_date.keys()):
            print_entries(entries_by_date[date_str], date_str)


def print_entries(entries: List[BragEntry], date_header: str):
    if not entries:
        return

    print(f"\n## {date_header}")
    for entry in entries:
        meta = []
        if entry.project:
            meta.append(f"[{entry.project}]")
        if entry.tags:
            meta.append(f"#{', #'.join(entry.tags)}")

        meta_str = f" {' '.join(meta)}" if meta else ""
        print(f"- {entry.content}{meta_str}")


def cmd_export(args, storage: BragStorage):
    start_date = args.start
    end_date = args.end

    if not start_date:
        # Default to all time if not specified? Or maybe last 30 days?
        # Architecture says "Default: all entries"
        # Since we don't have an efficient "all entries" without scanning everything,
        # let's assume we scan available dates.
        dates = storage.list_available_dates()
        if not dates:
            print("[]" if args.format == "json" else "")
            return
        start_date = dates[0]

    if not end_date:
        end_date = datetime.date.today().isoformat()

    entries = storage.get_entries_range(start_date, end_date)

    if args.format == "json":
        print(json.dumps([e.to_dict() for e in entries], indent=2))
    elif args.format == "markdown":
        # Reuse list logic but maybe more formal?
        # Architecture says "group by date with headers"
        # Let's just reuse the grouping logic from list but print to stdout
        entries_by_date = {}
        for entry in entries:
            date_str = entry.timestamp.split("T")[0]
            if date_str not in entries_by_date:
                entries_by_date[date_str] = []
            entries_by_date[date_str].append(entry)

        for date_str in sorted(entries_by_date.keys()):
            print(f"\n## {date_str}")
            for entry in entries_by_date[date_str]:
                print(f"- {entry.content}")
    else:  # text
        for entry in entries:
            print(f"- {entry.content}")


def main():
    parser = argparse.ArgumentParser(description="Brag CLI")
    parser.add_argument("--data-dir", help="Data directory path")

    subparsers = parser.add_subparsers(dest="command", required=True)

    # Add command
    add_parser = subparsers.add_parser("add", help="Add a new brag")
    add_parser.add_argument("content", nargs="*", help="Content of the brag")
    add_parser.add_argument("--tags", nargs="+", help="Tags")
    add_parser.add_argument("--project", help="Project name")
    add_parser.add_argument("--edit", action="store_true", help="Open editor")

    # List command
    list_parser = subparsers.add_parser("list", help="List brags")
    list_parser.add_argument(
        "--days", type=int, default=7, help="Number of days to show"
    )
    list_parser.add_argument("--date", help="Specific date (YYYY-MM-DD)")

    # Export command
    export_parser = subparsers.add_parser("export", help="Export brags")
    export_parser.add_argument("--start", help="Start date (YYYY-MM-DD)")
    export_parser.add_argument("--end", help="End date (YYYY-MM-DD)")
    export_parser.add_argument(
        "--format",
        choices=["json", "markdown", "text"],
        default="json",
        help="Output format",
    )

    args = parser.parse_args()

    storage = BragStorage(args.data_dir)

    if args.command == "add":
        cmd_add(args, storage)
    elif args.command == "list":
        cmd_list(args, storage)
    elif args.command == "export":
        cmd_export(args, storage)


if __name__ == "__main__":
    main()
