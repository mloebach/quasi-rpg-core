# -*- coding: utf-8 -*-
"""
Fast Command Inserter for VN Story Scripts
============================================
Automatically inserts commands (like @icon) before dialogue lines
based on configurable rules.

Usage:
    python fast_commands.py <path>                     # Preview
    python fast_commands.py <path> --fix               # Apply
    python fast_commands.py <path> --ext .story         # Set extension
    python fast_commands.py <path> --only icon          # Run one rule
    python fast_commands.py --list                      # List rules

<path> can be a single file or a directory (scanned recursively).
"""

import argparse
import re
from pathlib import Path


# ══════════════════════════════════════════════════════════════
#  CHARACTER DATABASE
#  Add all recognized speaker names here. Only these names
#  will trigger automatic command insertion.
#  Supports aliases — if a character can be referred to by
#  multiple names, list them all.
# ══════════════════════════════════════════════════════════════

CHARACTERS = {
    # Format: "Name As It Appears In Script"
    # The script matches case-insensitively but preserves
    # the casing you put here for the generated command.

    "Culpex",
    "Ehrugarr",
    "JQ3",
    "Quzeon",
    "Regamirr",
    "Havi",
    "Yunyere",
    "Veveya",
    "Pihqura",
    "Trophistus",
    "Mururham",
    "Deyacron",
    "Liburri",
    "Ozapold",
    "Uelgwold",
    "Winckary",
    "Kennewick",
    "Lannus",
    "Ipholsia",
    "Lyelye",
    "Nerinorin",
    "Dark Husk",
    "z_name",
}

# Build a lowercase lookup for case-insensitive matching,
# mapping back to the canonical casing
_CHAR_LOOKUP = {name.lower(): name for name in CHARACTERS}


def get_canonical_name(speaker: str) -> str | None:
    """Return the canonical character name if recognized, else None."""
    return _CHAR_LOOKUP.get(speaker.strip().lower())


# ══════════════════════════════════════════════════════════════
#  DIALOGUE DETECTION
# ══════════════════════════════════════════════════════════════

# Matches lines like "Veveya: Hello world!" or "JQ3: ..."
# Speaker name must be at the start of the line (allowing leading whitespace)
# and followed by a colon and at least one space
DIALOGUE_PATTERN = re.compile(r'^(\s*)([\w][\w\d ]*?):\s+(.+)$')


def parse_dialogue(line: str):
    """
    If the line is dialogue, return (indent, speaker, text).
    Otherwise return None.
    """
    m = DIALOGUE_PATTERN.match(line.rstrip('\n\r'))
    if m:
        indent = m.group(1)
        speaker = m.group(2).strip()
        text = m.group(3)
        return indent, speaker, text
    return None


# ══════════════════════════════════════════════════════════════
#  COMMAND RULES
#  Each rule defines:
#    - name:        ID for --only / --skip
#    - description: shown in --list and reports
#    - check:       function(lines, index) -> command_to_insert or None
#                   Receives all lines and the current index.
#                   Returns a string to insert BEFORE this line, or None.
# ══════════════════════════════════════════════════════════════

def icon_check(lines: list, idx: int) -> str | None:
    """
    If line is dialogue from a recognized character and the
    previous line isn't already an @icon command, return the
    @icon command to insert.
    """
    line = lines[idx]
    parsed = parse_dialogue(line)
    if not parsed:
        return None

    indent, speaker, text = parsed
    canonical = get_canonical_name(speaker)
    if not canonical:
        return None

    # Check previous non-blank lines
    prev_idx = idx - 1
    while prev_idx >= 0 and lines[prev_idx].strip() == '':
        prev_idx -= 1

    if prev_idx >= 0:
        prev_stripped = lines[prev_idx].strip()
        # Already has an @icon command right above
        if prev_stripped.startswith("@icon"):
            return None
        # Previous line is dialogue from the same character
        prev_parsed = parse_dialogue(lines[prev_idx])
        if prev_parsed:
            _, prev_speaker, _ = prev_parsed
            prev_canonical = get_canonical_name(prev_speaker)
            if prev_canonical == canonical:
                return None

    return f"{indent}@icon {canonical}\n"


RULES = [
    {
        "name": "icon",
        "description": "Insert @icon before dialogue from recognized characters",
        "check": icon_check,
    },

    # ── Add new command rules here ──
    # Example:
    # {
    #     "name": "emotion",
    #     "description": "Insert @emotion before lines with emotion markers",
    #     "check": some_function,
    # },
]


# ══════════════════════════════════════════════════════════════
#  ENGINE
# ══════════════════════════════════════════════════════════════

class CommandInserter:
    def __init__(self, rules):
        self.rules = rules

    def process_file(self, filepath: str, apply_fix: bool = False):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except (UnicodeDecodeError, PermissionError) as e:
            print(f"  Warning: Skipping {filepath}: {e}")
            return []

        insertions = []

        # First pass: find all insertions
        for i, line in enumerate(lines):
            for rule in self.rules:
                cmd = rule["check"](lines, i)
                if cmd is not None:
                    insertions.append({
                        "file": filepath,
                        "line": i + 1,
                        "rule": rule["name"],
                        "command": cmd.rstrip('\n'),
                        "before": line.rstrip('\n'),
                    })

        # Second pass: apply insertions (if fixing)
        if apply_fix and insertions:
            new_lines = []
            insert_at = {ins["line"] - 1: ins["command"] + '\n' for ins in insertions}
            for i, line in enumerate(lines):
                if i in insert_at:
                    new_lines.append(insert_at[i])
                new_lines.append(line)

            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)

        return insertions

    def process_path(self, path: str, extensions: list, apply_fix: bool = False):
        p = Path(path)

    def process_path(self, path: str, extensions: list, apply_fix: bool = False, exclude: list = None):
        p = Path(path)

        if p.is_file():
            files = [p]
        elif p.is_dir():
            files = []
            for ext in extensions:
                files.extend(p.rglob(f"*{ext}"))
            if exclude:
                exclude_lower = [e.lower() for e in exclude]
                files = [f for f in files
                         if not any(ex in [part.lower() for part in f.parts]
                                    for ex in exclude_lower)]
            files.sort()
        else:
            print(f"Error: '{path}' is not a valid file or directory.")
            return []

        print(f"\n{'INSERTING' if apply_fix else 'SCANNING'} {len(files)} file(s) "
              f"with {len(self.rules)} rule(s)...\n")

        all_insertions = []
        for filepath in files:
            hits = self.process_file(str(filepath), apply_fix)
            all_insertions.extend(hits)

        return all_insertions


def print_report(insertions: list, apply_fix: bool):
    if not insertions:
        print("No commands to insert!")
        return

    action = "Inserted" if apply_fix else "Would insert"
    print(f"\n{'='*60}")
    print(f"  {action} {len(insertions)} command(s)")
    print(f"{'='*60}\n")

    by_file = {}
    for ins in insertions:
        by_file.setdefault(ins["file"], []).append(ins)

    for filepath, file_ins in by_file.items():
        print(f"  {filepath} ({len(file_ins)} insertions)")
        print(f"   {'─'*50}")
        for ins in file_ins:
            print(f"   Line {ins['line']:>4} [{ins['rule']}]:")
            print(f"     + {ins['command']}")
            print(f"       {ins['before']}")
        print()

    by_rule = {}
    for ins in insertions:
        by_rule[ins["rule"]] = by_rule.get(ins["rule"], 0) + 1
    print("Summary by rule:")
    for rule, count in sorted(by_rule.items(), key=lambda x: -x[1]):
        print(f"  {rule}: {count} insertion(s)")

    if not apply_fix:
        print(f"\nRun with --fix to apply these insertions.")
        print(f"   (Back up your files first!)\n")


def main():
    parser = argparse.ArgumentParser(
        description="Auto-insert commands into story script files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python fast_commands.py . --ext .story               # Preview
  python fast_commands.py . --ext .story --fix         # Apply
  python fast_commands.py . --ext .story --only icon   # Just icons
  python fast_commands.py --list                       # Show rules
        """
    )
    parser.add_argument("path", nargs="?", default=".",
                        help="File or directory to scan (default: current dir)")
    parser.add_argument("--fix", action="store_true",
                        help="Apply insertions (default: preview only)")
    parser.add_argument("--ext", nargs="+", default=[".story"],
                        help="File extensions to scan (default: .story)")
    parser.add_argument("--only", nargs="+", metavar="RULE",
                        help="Only run these rules")
    parser.add_argument("--skip", nargs="+", metavar="RULE",
                        help="Skip these rules")
    parser.add_argument("--exclude", nargs="+", metavar="FOLDER",
                        help="Folder names to skip (e.g. --exclude debug test)")
    parser.add_argument("--list", action="store_true",
                        help="List all available rules and exit")

    args = parser.parse_args()

    if args.list:
        print("\nAvailable command rules:\n")
        for r in RULES:
            print(f"  {r['name']:15s}  {r['description']}")
        print(f"\n  Recognized characters: {', '.join(sorted(CHARACTERS))}")
        print(f"\nUse --only or --skip to control which rules run.")
        return

    active_rules = RULES[:]
    rule_names = {r["name"] for r in RULES}

    if args.only:
        for name in args.only:
            if name not in rule_names:
                print(f"Unknown rule: '{name}'. Use --list to see available rules.")
                return
        active_rules = [r for r in RULES if r["name"] in args.only]

    if args.skip:
        for name in args.skip:
            if name not in rule_names:
                print(f"Unknown rule: '{name}'. Use --list to see available rules.")
                return
        active_rules = [r for r in active_rules if r["name"] not in args.skip]

    if not active_rules:
        print("No rules selected!")
        return

    print(f"Active rules: {', '.join(r['name'] for r in active_rules)}")

    inserter = CommandInserter(active_rules)
    insertions = inserter.process_path(args.path, args.ext, apply_fix=args.fix, exclude=args.exclude)
    print_report(insertions, args.fix)


if __name__ == "__main__":
    main()