#!/usr/bin/env python3
"""
Generate story narration audio via the ElevenLabs Text-to-Speech API.

Reads story_audio_config.json (produced by story_text_export.py) and
generates one MP3 per story page, saving them to assets/audio/stories/.

Usage:
    export ELEVENLABS_API_KEY=sk-...
    python tools/generate_story_audio.py

    # Override voice per country:
    python tools/generate_story_audio.py --country ghana --voice-id abc123

Requirements:
    pip install requests
"""

import argparse
import json
import sys
import time
from pathlib import Path

try:
    import requests
except ImportError:
    print("Error: 'requests' package required. Run: pip install requests", file=sys.stderr)
    sys.exit(1)

import os

API_BASE = "https://api.elevenlabs.io/v1/text-to-speech"
CONFIG_PATH = Path(__file__).parent / "story_audio_config.json"
ASSETS_DIR = Path(__file__).parent.parent / "assets/audio/stories"


def generate_audio(
    text: str,
    voice_id: str,
    model_id: str,
    output_format: str,
    api_key: str,
) -> bytes:
    """Call ElevenLabs TTS API and return MP3 bytes."""
    url = f"{API_BASE}/{voice_id}"
    headers = {
        "xi-api-key": api_key,
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
    }
    payload = {
        "text": text,
        "model_id": model_id,
        "voice_settings": {
            "stability": 0.6,
            "similarity_boost": 0.75,
            "style": 0.4,
            "use_speaker_boost": True,
        },
    }

    resp = requests.post(
        url,
        headers=headers,
        json=payload,
        params={"output_format": output_format},
        timeout=60,
    )
    resp.raise_for_status()
    return resp.content


def main():
    parser = argparse.ArgumentParser(description="Generate story audio via ElevenLabs")
    parser.add_argument("--country", help="Generate only for this country ID")
    parser.add_argument("--voice-id", help="Override voice ID for the selected country")
    parser.add_argument("--dry-run", action="store_true", help="Print what would be generated")
    args = parser.parse_args()

    api_key = os.environ.get("ELEVENLABS_API_KEY")
    if not api_key and not args.dry_run:
        print("Error: Set ELEVENLABS_API_KEY environment variable", file=sys.stderr)
        sys.exit(1)

    if not CONFIG_PATH.exists():
        print(f"Error: {CONFIG_PATH} not found. Run story_text_export.py first.", file=sys.stderr)
        sys.exit(1)

    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    default_voice_id = config["voice_id"]
    model_id = config.get("model_id", "eleven_multilingual_v2")
    output_format = config.get("output_format", "mp3_44100_64")
    stories = config["stories"]

    countries = [args.country] if args.country else list(stories.keys())

    total = sum(len(stories.get(c, [])) for c in countries)
    generated = 0
    skipped = 0

    for country_id in countries:
        pages = stories.get(country_id, [])
        if not pages:
            print(f"  Skipping {country_id}: no pages in config")
            continue

        out_dir = ASSETS_DIR / country_id
        out_dir.mkdir(parents=True, exist_ok=True)

        voice = args.voice_id if args.voice_id else default_voice_id

        for page in pages:
            page_num = page["page"]
            text = page["text"]
            out_file = out_dir / f"page_{page_num}.mp3"

            if out_file.exists():
                print(f"  [{country_id}] page_{page_num}.mp3 already exists, skipping")
                skipped += 1
                continue

            if args.dry_run:
                preview = text[:80].replace("\n", " ")
                print(f"  [DRY RUN] {country_id}/page_{page_num}.mp3 — {preview}...")
                generated += 1
                continue

            print(f"  Generating {country_id}/page_{page_num}.mp3 ...", end=" ", flush=True)
            try:
                audio_bytes = generate_audio(
                    text=text,
                    voice_id=voice,
                    model_id=model_id,
                    output_format=output_format,
                    api_key=api_key,
                )
                out_file.write_bytes(audio_bytes)
                size_kb = len(audio_bytes) / 1024
                print(f"OK ({size_kb:.0f} KB)")
                generated += 1

                # Rate limit: ~2 requests/sec to be safe
                time.sleep(0.5)
            except requests.HTTPError as e:
                print(f"FAILED: {e}")
                print(f"    Response: {e.response.text[:200] if e.response else 'N/A'}")
            except Exception as e:
                print(f"FAILED: {e}")

    print()
    print(f"Done: {generated} generated, {skipped} skipped, {total} total")


if __name__ == "__main__":
    main()
