"""
Ligature Fixer for VN Story Scripts
====================================
Scans story/text files for broken PDF ligatures (fi, fl, ft, ff, ffi, ffl, etc.)
and fixes them. Outputs a report of all changes made.

Usage:
    python ligature_fixer.py <path>              # Preview mode (no changes)
    python ligature_fixer.py <path> --fix        # Apply fixes
    python ligature_fixer.py <path> --ext .story  # Only scan .story files

<path> can be a single file or a directory (scanned recursively).
"""

import argparse
import os
import re
from pathlib import Path

# ── Common English words containing ligatures ──

LIGATURE_WORDS = {
    "fi": [
        "after", "affirm", "affirmation", "affirmative",
        "amplified", "amplifier", "artificial",
        "battlefield", "beatific", "beautiful", "beneficent", "beneficial",
        "bonfire", "calcified", "campfire", "certified", "clarified",
        "classified", "codified", "confide", "confidence", "confident",
        "confidential", "confirm", "confirmation", "conflict", "confine",
        "crossfire", "crucified", "decipher", "decified", "defiance",
        "defiant", "define", "defined", "definition", "dignified",
        "disqualified", "edified", "efficient", "elfin",
        "exemplified", "fight", "fighter", "fighting", "figure",
        "figured", "file", "filed", "fill", "filled", "filling",
        "film", "filter", "filth", "filthy", "fin", "final", "finale",
        "finalize", "finally", "find", "finding", "findings", "fine",
        "fined", "finely", "finesse", "finger", "fingertip", "finish",
        "finished", "finite", "fire", "fired", "firelight", "fireplace",
        "firm", "firmly", "first", "firsthand", "fish", "fishing",
        "fist", "fit", "fitness", "fitted", "fitting", "five",
        "fix", "fixed", "fixture", "fortified", "fortify",
        "glorified", "glorify", "gratified", "gratifying",
        "gunfire", "hellfire", "horrified", "horrifying",
        "identified", "identify", "indemnified", "infidel",
        "infiltrate", "infinite", "infinitely", "infinity",
        "intensified", "justified", "justify", "knife",
        "life", "lifeless", "lifelike", "lifetime", "lift", "lifted",
        "lifting", "magnified", "magnificent", "midfield",
        "misfire", "modified", "modify", "mortified",
        "notified", "notify", "nullified", "office", "officer",
        "official", "officially", "offline", "orifice", "ossified",
        "outfit", "outfield", "outfight", "outfit", "outfitted",
        "pacified", "petrified", "pitiful", "plentiful",
        "pontificate", "profile", "profiled", "profit", "profitable",
        "proficient", "purified", "purify", "qualified", "qualifier",
        "qualify", "ratified", "ratify", "rectified", "refined",
        "refine", "refinement", "refinery", "refit", "retrofit",
        "rifle", "rifled", "sacrifice", "sacrificed", "sacrificial",
        "sanctified", "satisfied", "satisfy", "scarified",
        "scientific", "semifinal", "shift", "shifted", "shifting",
        "significance", "significant", "significantly", "signified",
        "signify", "simplified", "simplify", "sniffle", "specific",
        "specifically", "specified", "specify", "spitfire",
        "stifle", "stifled", "stifling", "stratified",
        "sufficient", "sufficiently", "superficial", "swift",
        "swiftly", "terrified", "terrify", "terrifying",
        "testified", "testify", "thirtyfive", "trifle",
        "typified", "unconfirmed", "undefined", "underfire",
        "unified", "unfinished", "unfit", "unified", "unify",
        "unjustified", "unofficial", "unqualified", "unsatisfied",
        "unspecified", "verified", "verify", "versified",
        "vivified", "wife", "wildlife", "wolfishly",
    ],
    "fl": [
        "afflict", "affliction", "affluent", "airflow",
        "baffle", "baffled", "baffling", "battlefield",
        "camouflage", "camouflaged", "conflict", "conflicted",
        "confluent", "deflate", "deflect", "deflection",
        "downfall", "firefly", "flag", "flagged", "flair",
        "flake", "flaked", "flaky", "flame", "flamed", "flaming",
        "flank", "flanked", "flanking", "flap", "flare", "flared",
        "flash", "flashback", "flashlight", "flask", "flat",
        "flatten", "flatter", "flattery", "flaunt", "flavor",
        "flaw", "flawed", "flawless", "flay", "fled", "flee",
        "fleece", "fleeing", "fleet", "fleeting", "flesh",
        "fleshed", "flew", "flex", "flexibility", "flexible",
        "flick", "flicker", "flickered", "flickering", "flight",
        "flinch", "flinched", "fling", "flint", "flip", "flipped",
        "flipping", "flit", "float", "floated", "floating",
        "flock", "flocked", "flood", "flooded", "flooding",
        "floor", "floored", "flooring", "flop", "flopped",
        "flora", "floral", "florid", "flourish", "flourished",
        "flow", "flowed", "flower", "flowering", "flowers",
        "flowing", "flown", "fluctuate", "fluency", "fluent",
        "fluently", "fluff", "fluffy", "fluid", "fluidity",
        "fluke", "flung", "flunk", "fluorescent", "flurry",
        "flush", "flushed", "flushing", "fluster", "flustered",
        "flutter", "fluttered", "fluttering", "flux",
        "inflame", "inflate", "inflated", "inflation",
        "inflect", "inflection", "inflexible", "inflict",
        "influence", "influenced", "influential", "influx",
        "leaflet", "lofty", "offload", "outflank",
        "overflow", "overflowed", "overflowing",
        "piffle", "raffle", "reflect", "reflected", "reflection",
        "reflective", "reflex", "reflexive", "rifle", "riffle",
        "ruffle", "ruffled", "scaffold", "scuffle", "selfless",
        "shuffle", "shuffled", "sniffle", "snowflake",
        "souffle", "stifle", "stifled", "stifling",
        "sunflower", "trifle", "truffle", "waffle", "workflow",
    ],
    "ft": [
        "after", "aftereffect", "afterglow", "afterimage",
        "afterlife", "aftermath", "afternoon", "aftershock",
        "afterthought", "afterward", "afterwards", "aircraft",
        "aloft", "bereft", "cleft", "craft", "crafted",
        "craftsman", "craftsmanship", "crafty", "croft",
        "daft", "deft", "deftly", "deftness", "draft", "drafted",
        "drafting", "drift", "drifted", "drifter", "drifting",
        "gift", "gifted", "graft", "grafted",
        "heft", "hefted", "hefty", "loft", "lofted", "lofty",
        "left", "leftover", "leftovers", "lift", "lifted",
        "lifter", "lifting", "loft", "lofty",
        "often", "offset", "raft", "rafted", "rafter",
        "rift", "shaft", "shift", "shifted", "shifter",
        "shifting", "shifty", "sift", "sifted", "sifting",
        "soft", "soften", "softened", "softening", "softer",
        "softly", "softness", "software", "swift", "swiftly",
        "swiftness", "theft", "thrift", "thrifty",
        "tuft", "tufted", "waft", "wafted", "wafting",
    ],
    "ff": [
        "affair", "affect", "affected", "affection", "affectionate",
        "affirm", "affirmation", "afflict", "affluent", "afford",
        "afforded", "affront", "baffled", "bluff", "bluffing",
        "buff", "buffer", "buffet", "chaff", "chaffinch",
        "cliff", "cliffside", "coffee", "coffer", "coffin",
        "cuff", "cuffed", "cutoff", "differ", "difference",
        "different", "differently", "difficult", "difficulty",
        "doff", "doffed", "effect", "effective", "effectively",
        "effectiveness", "effort", "effortless", "effortlessly",
        "gaffe", "gruff", "gruffly", "handoff", "huff", "huffed",
        "ineffective", "miffed", "offbeat", "offend", "offended",
        "offender", "offense", "offensive", "offer", "offered",
        "offering", "office", "officer", "official", "officially",
        "offline", "offset", "offspring", "payoff", "playoff",
        "puff", "puffed", "rebuff", "riffraff", "riffled",
        "rough", "ruffian", "ruffle", "ruffled",
        "scaffold", "scaffolding", "scoff", "scoffed",
        "scuffle", "sheriff", "shuffle", "sniff", "sniffed",
        "sniffle", "staff", "staffed", "stiff", "stiffen",
        "stiffened", "stiffly", "stiffness", "stuff", "stuffed",
        "stuffing", "stuffy", "suffer", "suffered", "suffering",
        "sufficient", "tariff", "toff", "toffee", "traffic",
        "truffled", "waffle",
    ],
    "ffi": [
        "affidavit", "affiliate", "affiliated", "affiliation",
        "affinity", "affirm", "affirmation", "affirmative",
        "baffling", "caffeine", "coefficient", "coffin",
        "daffodil", "deficiency", "deficient", "difficulty",
        "efficiency", "efficient", "efficiently",
        "griffin", "huffing", "inefficiency", "inefficient",
        "muffin", "officious", "office", "officer", "official",
        "officially", "officiate", "paraffin", "proficiency",
        "proficient", "puffin", "ruffian", "scaffold",
        "scaffolding", "scoffing", "sniffing", "staffing",
        "stiffing", "stuffing", "sufficient", "sufficiently",
        "trafficking", "unofficial",
    ],
    "ffl": [
        "afflict", "afflicted", "affliction", "baffle",
        "baffled", "bafflement", "baffling", "duffel",
        "muffle", "muffled", "offload", "offloaded",
        "piffle", "raffle", "raffled", "riffle", "riffled",
        "ruffle", "ruffled", "scaffold", "scuffle",
        "shuffle", "shuffled", "sniffle", "sniffled",
        "souffle", "stifle", "stifled", "stifling",
        "truffle", "waffle", "waffled",
    ],
}

# ── Add your project-specific terms here ──
CUSTOM_WORDS = {
    "fi": [],
    "fl": [],
    "ft": [],
    "ff": [],
    "ffi": [],
    "ffl": [],
}

for lig, words in CUSTOM_WORDS.items():
    if lig in LIGATURE_WORDS:
        LIGATURE_WORDS[lig].extend(words)

# ── Broken forms that cause too many false positives ──
# These won't be auto-fixed, but WILL be reported at the end
# for manual review. Add the BROKEN form in lowercase.
REVIEW_ONLY = {
    "the ",  # "theft" minus "ft" — matches every "the"
    " are",  # "flare" minus "fl" — matches every "are"
    "the",
    "are",
}


def build_fix_map():
    """
    For each word, generate broken forms from ligature removal.
    Returns (fix_map, review_map) — review_map has high-false-positive entries.
    """
    fix_map = {}
    review_map = {}

    ordered_ligs = sorted(LIGATURE_WORDS.keys(), key=len, reverse=True)

    for lig in ordered_ligs:
        words = LIGATURE_WORDS[lig]
        for word in words:
            wl = word.lower()
            idx = wl.find(lig)
            while idx != -1:
                left = wl[:idx]
                right = wl[idx + len(lig):]
                broken_space = left + " " + right
                broken_drop = left + right

                if len(left) + len(right) >= 3:
                    # Decide which map this goes into
                    space_is_review = (broken_space.strip() in REVIEW_ONLY or broken_space in REVIEW_ONLY)
                    drop_is_review = (broken_drop in REVIEW_ONLY)

                    if space_is_review:
                        if broken_space not in review_map:
                            review_map[broken_space] = (word, lig)
                    else:
                        if broken_space not in fix_map:
                            fix_map[broken_space] = (word, lig)

                    if len(broken_drop) >= 4:
                        if drop_is_review:
                            if broken_drop not in review_map:
                                review_map[broken_drop] = (word, lig)
                        else:
                            if broken_drop not in fix_map:
                                fix_map[broken_drop] = (word, lig)

                idx = wl.find(lig, idx + 1)

    return fix_map, review_map


def preserve_case(original_broken: str, fixed: str) -> str:
    if original_broken.isupper():
        return fixed.upper()
    if original_broken and original_broken[0].isupper():
        return fixed[0].upper() + fixed[1:]
    return fixed


def build_pattern(mapping):
    """Build a regex pattern from a fix/review map."""
    space_broken = [k for k in mapping if " " in k]
    space_broken.sort(key=len, reverse=True)
    if not space_broken:
        return None
    escaped = [re.escape(b) for b in space_broken]
    return re.compile(
        r'(?<!\w)(' + '|'.join(escaped) + r')(?!\w)',
        re.IGNORECASE
    )


class LigatureFixer:
    def __init__(self):
        self.fix_map, self.review_map = build_fix_map()
        self.fix_pattern = build_pattern(self.fix_map)
        self.review_pattern = build_pattern(self.review_map)
        self.changes = []

    def _scan_with(self, pattern, mapping, line, line_num, filepath, tag):
        matches = []
        if not pattern:
            return matches
        for m in pattern.finditer(line):
            broken = m.group(0)
            broken_lower = broken.lower()
            if broken_lower in mapping:
                fixed_word, ligature = mapping[broken_lower]
                fixed = preserve_case(broken, fixed_word)
                matches.append({
                    "file": filepath,
                    "line": line_num,
                    "col": m.start(),
                    "broken": broken,
                    "fixed": fixed,
                    "ligature": ligature,
                    "context": line.strip(),
                    "tag": tag,
                })
        return matches

    def scan_line(self, line, line_num, filepath):
        fix_matches = self._scan_with(
            self.fix_pattern, self.fix_map, line, line_num, filepath, "fix")
        review_matches = self._scan_with(
            self.review_pattern, self.review_map, line, line_num, filepath, "review")
        return fix_matches, review_matches

    def fix_line(self, line):
        if not self.fix_pattern:
            return line
        def replacer(m):
            broken = m.group(0)
            broken_lower = broken.lower()
            if broken_lower in self.fix_map:
                fixed_word, _ = self.fix_map[broken_lower]
                return preserve_case(broken, fixed_word)
            return broken
        return self.fix_pattern.sub(replacer, line)

    def process_file(self, filepath, apply_fix=False):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except (UnicodeDecodeError, PermissionError) as e:
            print(f"  Warning: Skipping {filepath}: {e}")
            return [], []

        all_fix = []
        all_review = []
        fixed_lines = []

        for i, line in enumerate(lines, 1):
            fix_matches, review_matches = self.scan_line(line, i, filepath)
            all_fix.extend(fix_matches)
            all_review.extend(review_matches)
            if apply_fix:
                fixed_lines.append(self.fix_line(line))
            else:
                fixed_lines.append(line)

        if apply_fix and all_fix:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(fixed_lines)

        return all_fix, all_review

    def process_path(self, path, extensions, apply_fix=False, exclude=None):
        p = Path(path)
        all_fix = []
        all_review = []

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
            return [], []

        print(f"\n{'FIXING' if apply_fix else 'SCANNING'} {len(files)} file(s)...\n")

        for filepath in files:
            fix, review = self.process_file(str(filepath), apply_fix)
            all_fix.extend(fix)
            all_review.extend(review)

        return all_fix, all_review


def print_matches(matches, header, symbol):
    """Print a section of matches grouped by file."""
    by_file = {}
    for m in matches:
        by_file.setdefault(m["file"], []).append(m)

    for filepath, file_matches in by_file.items():
        print(f"{symbol} {filepath} ({len(file_matches)} issues)")
        print(f"   {'─'*50}")
        for m in file_matches:
            print(f"   Line {m['line']:>4}: \"{m['broken']}\" -> \"{m['fixed']}\"  [{m['ligature']}]")
            ctx = m["context"]
            if len(ctx) > 80:
                start = max(0, m["col"] - 30)
                end = min(len(ctx), m["col"] + 50)
                ctx = ("..." if start > 0 else "") + ctx[start:end] + ("..." if end < len(ctx) else "")
            print(f"           {ctx}")
        print()


def print_report(fix_matches, review_matches, apply_fix):
    if not fix_matches and not review_matches:
        print("No ligature breaks found!")
        return

    # Main fixes
    if fix_matches:
        action = "Fixed" if apply_fix else "Found"
        print(f"\n{'='*60}")
        print(f"  {action} {len(fix_matches)} ligature break(s)")
        print(f"{'='*60}\n")
        print_matches(fix_matches, "Auto-fixable", "  ")

        by_lig = {}
        for m in fix_matches:
            by_lig[m["ligature"]] = by_lig.get(m["ligature"], 0) + 1
        print("Summary by ligature type:")
        for lig, count in sorted(by_lig.items(), key=lambda x: -x[1]):
            print(f"  {lig}: {count} occurrence(s)")

    # Review-only section
    if review_matches:
        print(f"\n{'='*60}")
        print(f"  {len(review_matches)} possible match(es) needing MANUAL REVIEW")
        print(f"  (Not auto-fixed — too many false positives)")
        print(f"{'='*60}\n")
        print_matches(review_matches, "Manual review", "  ?")


def main():
    parser = argparse.ArgumentParser(
        description="Fix broken PDF ligatures in story/text files.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python ligature_fixer.py . --ext .story             # Preview
  python ligature_fixer.py . --ext .story --fix        # Apply fixes
        """
    )
    parser.add_argument("path", help="File or directory to scan")
    parser.add_argument("--fix", action="store_true",
                        help="Apply fixes (default: preview only)")
    parser.add_argument("--ext", nargs="+", default=[".txt", ".md", ".json", ".cfg", ".tres", ".gd"],
                        help="File extensions to scan (default: .txt .md .json .cfg .tres .gd)")
    parser.add_argument("--exclude", nargs="+", metavar="FOLDER",
                        help="Folder names to skip (e.g. --exclude debug test)")

    args = parser.parse_args()

    fixer = LigatureFixer()
    fix_matches, review_matches = fixer.process_path(args.path, args.ext, apply_fix=args.fix, exclude=args.exclude)
    print_report(fix_matches, review_matches, args.fix)

    if fix_matches and not args.fix:
        print(f"\nRun with --fix to apply the auto-fixable changes.")
        print(f"   (Back up your files first!)\n")


if __name__ == "__main__":
    main()