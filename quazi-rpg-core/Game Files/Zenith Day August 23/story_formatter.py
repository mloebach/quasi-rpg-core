# -*- coding: utf-8 -*-
"""
Story File Formatter
=====================
Modular formatting tool for .story VN script files.
Applies a set of formatting rules that can be individually toggled.

Usage:
    python story_formatter.py <path>                    # Preview all rules
    python story_formatter.py <path> --fix              # Apply all rules
    python story_formatter.py <path> --only bullets     # Preview one rule
    python story_formatter.py <path> --only ellipsis    # Preview one rule
    python story_formatter.py <path> --ext .story       # Set file extension
    python story_formatter.py <path> --list             # List available rules

<path> can be a single file or a directory (scanned recursively).
"""

import argparse
import re
from pathlib import Path


# ══════════════════════════════════════════════════════════════
#  FORMATTING RULES
#  Each rule is a dict with:
#    - name:        short ID used with --only / --skip
#    - description: shown in reports and --list
#    - fix:         function(line) -> fixed_line
#    - detect:      function(line) -> bool (does this line need fixing?)
#
#  To add a new rule, just append to RULES below.
# ══════════════════════════════════════════════════════════════

# ── BBCode bracket escaping helpers ──
# Known BBCode tags — if a [ is followed by one of these, it's BBCode, not narrative
_BBCODE_TAGS = {
    "b", "i", "u", "s", "p", "center", "right", "left", "fill",
    "indent", "url", "img", "font", "font_size", "opentype_features",
    "color", "bgcolor", "fgcolor", "outline_size", "outline_color",
    "table", "cell", "ul", "ol", "li", "code", "lb", "rb",
    "wave", "tornado", "shake", "fade", "rainbow", "pulse",
    "hint", "dropcap",
}

def _is_bbcode_bracket(text: str, pos: int) -> bool:
    """Check if the [ at position pos is the start of a BBCode tag."""
    if pos >= len(text) or text[pos] != '[':
        return False
    rest = text[pos + 1:]
    # Check closing tag like [/b]
    if rest.startswith('/'):
        rest = rest[1:]
    # Extract tag name (up to ] or = or space)
    tag = ""
    for ch in rest:
        if ch in ']= ':
            break
        tag += ch
    return tag.lower() in _BBCODE_TAGS


def _needs_bracket_escape(line: str) -> tuple:
    """
    Check if line has narrative brackets to escape.
    Returns (prefix, content, suffix) if it needs escaping, else None.
    Prefix is everything before the bracketed content (e.g. "Havi: ").
    """
    stripped = line.rstrip('\n\r')
    content = stripped

    # Check for speaker prefix (e.g. "Havi: [text]")
    prefix = ""
    colon_match = re.match(r'^([\w][\w\d ]*?:\s+)(.*)', content)
    if colon_match:
        prefix = colon_match.group(1)
        content = colon_match.group(2)

    content = content.strip()
    if len(content) < 2:
        return None
    if content[0] != '[' or content[-1] != ']':
        return None
    # Make sure the opening bracket is NOT a BBCode tag
    if _is_bbcode_bracket(content, 0):
        return None

    trailing = '\n' if line.endswith('\n') else ''
    return prefix, content, trailing


def _detect_narrative_brackets(line: str) -> bool:
    return _needs_bracket_escape(line) is not None


def _fix_narrative_brackets(line: str) -> str:
    result = _needs_bracket_escape(line)
    if not result:
        return line
    prefix, content, trailing = result
    # Replace only the outer brackets
    inner = content[1:-1]
    return prefix + "[lb]" + inner + "[rb]" + trailing


RULES = [
    {
        "name": "bullets",
        "description": "Remove bullet points (•, ●, ◦, ▪, ▸, ‣, ⁃, -, *) from start of lines",
        "detect": lambda line: bool(re.match(r'^[\t ]*[\u2022\u25cf\u25e6\u25aa\u25b8\u2023\u2043\-\*][\t ]+', line)),
        "fix": lambda line: re.sub(r'^([\t ]*)[\u2022\u25cf\u25e6\u25aa\u25b8\u2023\u2043\-\*][\t ]+', r'\1', line),
    },
    {
        "name": "ellipsis",
        "description": "Replace single-character ellipsis (…) with three dots (...)",
        "detect": lambda line: "\u2026" in line,
        "fix": lambda line: line.replace("\u2026", "..."),
    },

    {
        "name": "smartquotes",
        "description": "Replace smart/curly quotes with straight quotes",
        "detect": lambda line: bool(re.search(r'[\u201c\u201d\u2018\u2019]', line)),
        "fix": lambda line: line.replace('\u201c', '"').replace('\u201d', '"')
                                .replace('\u2018', "'").replace('\u2019', "'"),
    },
    {
        "name": "emdash",
        "description": "Replace em-dashes (—) and en-dashes (–) with hyphens (-)",
        "detect": lambda line: bool(re.search(r'[\u2014\u2013]', line)),
        "fix": lambda line: line.replace('\u2014', '-').replace('\u2013', '-'),
    },
    {
        "name": "doublespace",
        "description": "Collapse multiple spaces into a single space (preserves leading indent)",
        "detect": lambda line: bool(re.search(r'(?<=\S)  +', line)),
        "fix": lambda line: re.sub(r'(?<=\S)  +', ' ', line),
    },
    {
        "name": "brackets",
        "description": "Escape narrative [] brackets to [lb][rb] for BBCode compatibility",
        "detect": _detect_narrative_brackets,
        "fix": _fix_narrative_brackets,
    },
    {
        "name": "trailingws",
        "description": "Remove trailing whitespace from lines (blank lines become truly empty)",
        "detect": lambda line: line.rstrip('\n\r') != line.rstrip('\n\r').rstrip(),
        "fix": lambda line: (
            '\n' if line.rstrip('\n\r').strip() == '' and line.endswith('\n')
            else '' if line.rstrip('\n\r').strip() == ''
            else line.rstrip('\n\r').rstrip() + '\n' if line.endswith('\n')
            else line.rstrip()
        ),
    },

    # ── Add new rules here ──
]


# ══════════════════════════════════════════════════════════════
#  ENGINE (you shouldn't need to edit below here)
# ══════════════════════════════════════════════════════════════

class StoryFormatter:
    def __init__(self, rules):
        self.rules = rules

    def scan_line(self, line, line_num, filepath):
        """Check which rules trigger on this line."""
        hits = []
        for rule in self.rules:
            if rule["detect"](line):
                fixed = rule["fix"](line)
                if fixed != line:
                    hits.append({
                        "file": filepath,
                        "line": line_num,
                        "rule": rule["name"],
                        "before": line.rstrip('\n'),
                        "after": fixed.rstrip('\n'),
                    })
        return hits

    def fix_line(self, line):
        """Apply all active rules to a line."""
        for rule in self.rules:
            line = rule["fix"](line)
        return line

    def process_file(self, filepath, apply_fix=False):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except (UnicodeDecodeError, PermissionError) as e:
            print(f"  Warning: Skipping {filepath}: {e}")
            return []

        all_hits = []
        fixed_lines = []

        for i, line in enumerate(lines, 1):
            hits = self.scan_line(line, i, filepath)
            all_hits.extend(hits)
            fixed_lines.append(self.fix_line(line) if apply_fix else line)

        if apply_fix and all_hits:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(fixed_lines)

        return all_hits

    def process_path(self, path, extensions, apply_fix=False, exclude=None):
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

        print(f"\n{'FIXING' if apply_fix else 'SCANNING'} {len(files)} file(s) "
              f"with {len(self.rules)} rule(s)...\n")

        all_hits = []
        for filepath in files:
            hits = self.process_file(str(filepath), apply_fix)
            all_hits.extend(hits)

        return all_hits


def print_report(hits, apply_fix):
    if not hits:
        print("No formatting issues found!")
        return

    action = "Fixed" if apply_fix else "Found"
    print(f"\n{'='*60}")
    print(f"  {action} {len(hits)} formatting issue(s)")
    print(f"{'='*60}\n")

    # Group by file
    by_file = {}
    for h in hits:
        by_file.setdefault(h["file"], []).append(h)

    for filepath, file_hits in by_file.items():
        print(f"  {filepath} ({len(file_hits)} issues)")
        print(f"   {'─'*50}")
        for h in file_hits:
            print(f"   Line {h['line']:>4} [{h['rule']}]:")
            print(f"     - {h['before']}")
            print(f"     + {h['after']}")
        print()

    # Summary by rule
    by_rule = {}
    for h in hits:
        by_rule[h["rule"]] = by_rule.get(h["rule"], 0) + 1
    print("Summary by rule:")
    for rule, count in sorted(by_rule.items(), key=lambda x: -x[1]):
        print(f"  {rule}: {count} occurrence(s)")

    if not apply_fix:
        print(f"\nRun with --fix to apply these changes.")
        print(f"   (Back up your files first!)\n")


def main():
    parser = argparse.ArgumentParser(
        description="Format story script files with configurable rules.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python story_formatter.py . --ext .story              # Preview all rules
  python story_formatter.py . --ext .story --fix        # Apply all rules
  python story_formatter.py . --ext .story --only bullets   # Just bullets
  python story_formatter.py . --ext .story --skip bullets   # All except bullets
  python story_formatter.py --list                       # Show available rules
        """
    )
    parser.add_argument("path", nargs="?", default=".",
                        help="File or directory to scan (default: current dir)")
    parser.add_argument("--fix", action="store_true",
                        help="Apply fixes (default: preview only)")
    parser.add_argument("--ext", nargs="+", default=[".story"],
                        help="File extensions to scan (default: .story)")
    parser.add_argument("--exclude", nargs="+", metavar="FOLDER",
                        help="Folder names to skip (e.g. --exclude debug test)")
    parser.add_argument("--only", nargs="+", metavar="RULE",
                        help="Only run these rules")
    parser.add_argument("--skip", nargs="+", metavar="RULE",
                        help="Skip these rules")
    parser.add_argument("--list", action="store_true",
                        help="List all available rules and exit")

    args = parser.parse_args()

    if args.list:
        print("\nAvailable formatting rules:\n")
        for r in RULES:
            print(f"  {r['name']:15s}  {r['description']}")
        print(f"\nUse --only or --skip to control which rules run.")
        return

    # Filter rules
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
        print("No rules selected! Check your --only / --skip flags.")
        return

    print(f"Active rules: {', '.join(r['name'] for r in active_rules)}")

    formatter = StoryFormatter(active_rules)
    hits = formatter.process_path(args.path, args.ext, apply_fix=args.fix, exclude=args.exclude)
    print_report(hits, args.fix)


if __name__ == "__main__":
    main()