#!/usr/bin/env python3
"""
Export story text from story_data.dart to a JSON config for audio generation.

Usage:
    python tools/story_text_export.py

Output:
    tools/story_audio_config.json
"""

import json
import re
import sys
from pathlib import Path

STORY_DATA = Path(__file__).parent.parent / "lib/features/stories/data/story_data.dart"
OUTPUT = Path(__file__).parent / "story_audio_config.json"


def extract_stories(dart_source: str) -> dict[str, list[dict]]:
    """Parse story_data.dart and extract country ID + page texts."""
    stories: dict[str, list[dict]] = {}

    # Find each Story block
    story_pattern = re.compile(
        r"const\s+_(\w+)Story\s*=\s*Story\(", re.MULTILINE
    )
    page_text_pattern = re.compile(
        r"text:\s*\n?\s*'((?:[^'\\]|\\.|(?:'\s*\n\s*'))*)'",
        re.DOTALL,
    )
    country_id_pattern = re.compile(r"countryId:\s*'(\w+)'")

    for match in story_pattern.finditer(dart_source):
        # Find the matching closing for this Story(
        start = match.end()
        depth = 1
        pos = start
        while pos < len(dart_source) and depth > 0:
            if dart_source[pos] == '(':
                depth += 1
            elif dart_source[pos] == ')':
                depth -= 1
            pos += 1
        story_block = dart_source[match.start():pos]

        # Extract country ID
        cid_match = country_id_pattern.search(story_block)
        if not cid_match:
            continue
        country_id = cid_match.group(1)

        # Extract all page texts
        pages = []
        for i, text_match in enumerate(page_text_pattern.finditer(story_block)):
            raw = text_match.group(1)
            # Clean up Dart string concatenation
            text = raw.replace("'\n          '", "")
            text = text.replace("'\n            '", "")
            text = text.replace("\\n", "\n")
            # Decode unicode escapes
            text = text.replace("\\u{201C}", "\u201C")
            text = text.replace("\\u{201D}", "\u201D")
            text = text.replace("\\u{2019}", "\u2019")
            text = text.replace("\\u{2014}", "\u2014")
            text = text.replace("\\u{2026}", "\u2026")
            text = text.strip()
            pages.append({"page": i + 1, "text": text})

        if pages:
            stories[country_id] = pages

    return stories


def main():
    if not STORY_DATA.exists():
        print(f"Error: {STORY_DATA} not found", file=sys.stderr)
        sys.exit(1)

    dart_source = STORY_DATA.read_text(encoding="utf-8")
    stories = extract_stories(dart_source)

    if not stories:
        print("Warning: No stories extracted!", file=sys.stderr)

    config = {
        "voice_id": "REPLACE_WITH_YOUR_ELEVENLABS_VOICE_ID",
        "model_id": "eleven_multilingual_v2",
        "output_format": "mp3_44100_64",
        "stories": stories,
    }

    OUTPUT.write_text(json.dumps(config, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Exported {sum(len(p) for p in stories.values())} pages from {len(stories)} stories")
    print(f"Config written to: {OUTPUT}")
    print()
    print("Next steps:")
    print("  1. Replace 'voice_id' with your ElevenLabs voice ID")
    print("  2. Run: python tools/generate_story_audio.py")


if __name__ == "__main__":
    main()
