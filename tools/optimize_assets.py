#!/usr/bin/env python3
"""
Planet Wonders — Asset Optimization Script

Resizes and converts all image assets according to asset_config.yaml rules.
Converts PNG/JPG to WebP (lossy with alpha) or compresses PNG with pngquant.

Usage:
    python3 tools/optimize_assets.py                  # Full optimization
    python3 tools/optimize_assets.py --dry-run        # Report only, no changes
    python3 tools/optimize_assets.py --single FILE    # Optimize one file

Requirements:
    pip install Pillow pyyaml
    brew install webp pngquant
"""

from __future__ import annotations

import argparse
import fnmatch
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Optional

import yaml
from PIL import Image

ASSETS_DIR = Path(__file__).parent.parent / "assets"
CONFIG_PATH = Path(__file__).parent / "asset_config.yaml"

# File extensions we process
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg"}

# Skip these files/patterns
SKIP_PATTERNS = {".DS_Store", ".gitkeep", "*.json", "*.md", "*.mp3",
                 "*.textClipping", "*.yaml", "*.yml"}


def load_config(config_path: Path) -> list[dict]:
    """Load format rules from YAML config."""
    with open(config_path) as f:
        cfg = yaml.safe_load(f)
    return cfg.get("format_rules", [])


def match_rule(rel_path: str, rules: list[dict]) -> dict | None:
    """Find the first matching rule for a relative asset path."""
    for rule in rules:
        pattern = rule["pattern"]
        if fnmatch.fnmatch(rel_path, pattern):
            return rule
    return None


def should_skip_file(filename: str) -> bool:
    """Check if file should be skipped entirely."""
    for pat in SKIP_PATTERNS:
        if fnmatch.fnmatch(filename, pat):
            return True
    return False


def get_image_files(assets_dir: Path) -> list[Path]:
    """Walk assets directory and collect all image files."""
    files = []
    for root, _, filenames in os.walk(assets_dir):
        for fname in sorted(filenames):
            if should_skip_file(fname):
                continue
            ext = Path(fname).suffix.lower()
            if ext in IMAGE_EXTENSIONS:
                files.append(Path(root) / fname)
    return files


def resize_image(img: Image.Image, max_w: int, max_h: int) -> Image.Image:
    """Resize image to fit within max dimensions, preserving aspect ratio."""
    w, h = img.size
    if w <= max_w and h <= max_h:
        return img

    ratio = min(max_w / w, max_h / h)
    new_w = int(w * ratio)
    new_h = int(h * ratio)
    return img.resize((new_w, new_h), Image.LANCZOS)


def convert_to_webp(input_path: Path, output_path: Path, quality: int) -> bool:
    """Convert image to WebP using cwebp for best alpha handling."""
    # First resize with Pillow, save as temp PNG
    try:
        img = Image.open(input_path)
    except Exception as e:
        print(f"  ERROR: Cannot open {input_path}: {e}")
        return False

    # Use temp file for cwebp input
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
        tmp_path = Path(tmp.name)

    try:
        # Save resized as PNG for cwebp
        img.save(tmp_path, "PNG")
        img.close()

        # Run cwebp
        cmd = [
            "cwebp",
            "-q", str(quality),
            "-alpha_filter", "best",
            "-m", "6",  # max compression effort
            "-quiet",
            str(tmp_path),
            "-o", str(output_path),
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"  ERROR: cwebp failed for {input_path}: {result.stderr}")
            return False
        return True
    finally:
        tmp_path.unlink(missing_ok=True)


def compress_png(input_path: Path, output_path: Path) -> bool:
    """Compress PNG using pngquant (lossy but visually lossless)."""
    cmd = [
        "pngquant",
        "--quality=65-95",
        "--speed=1",
        "--force",
        "--output", str(output_path),
        str(input_path),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        # pngquant returns 99 if quality can't be met; keep original
        shutil.copy2(input_path, output_path)
    return True


def optimize_file(
    file_path: Path,
    assets_dir: Path,
    rules: list[dict],
    dry_run: bool = False,
) -> dict:
    """Optimize a single image file. Returns stats dict."""
    rel_path = str(file_path.relative_to(assets_dir))
    # Normalize path separators for matching
    rel_match = rel_path.replace("\\", "/").lower()

    original_size = file_path.stat().st_size

    # Find matching rule
    rule = match_rule(rel_match, rules)
    if rule is None:
        # Try with original case
        rule = match_rule(rel_path.replace("\\", "/"), rules)

    if rule is None:
        return {"path": rel_path, "action": "no_rule", "original": original_size,
                "new": original_size, "saved": 0}

    if rule.get("skip"):
        return {"path": rel_path, "action": "skip", "original": original_size,
                "new": original_size, "saved": 0}

    target_format = rule["format"]
    max_w = rule.get("max_width", 99999)
    max_h = rule.get("max_height", 99999)
    quality = rule.get("quality", 85)

    # Open and resize
    try:
        img = Image.open(file_path)
    except Exception as e:
        return {"path": rel_path, "action": "error", "error": str(e),
                "original": original_size, "new": original_size, "saved": 0}

    resized = resize_image(img, max_w, max_h)
    resized_changed = resized.size != img.size

    if target_format == "webp":
        new_ext = ".webp"
    else:
        new_ext = ".png"

    # Determine output path (change extension if converting)
    old_stem = file_path.stem
    old_ext = file_path.suffix
    new_path = file_path.with_name(old_stem + new_ext)

    if dry_run:
        # Estimate savings
        if target_format == "webp":
            # Rough estimate: WebP is ~10-15% of PNG size after resize
            w, h = resized.size
            pixels = w * h
            estimated = int(pixels * 0.15)  # ~0.15 bytes/pixel for WebP q85
            if img.mode == "RGBA":
                estimated = int(estimated * 1.3)
        else:
            estimated = int(original_size * 0.7)  # pngquant ~30% savings

        img.close()
        return {"path": rel_path, "action": f"would_convert_to_{target_format}",
                "original": original_size, "new": estimated,
                "saved": original_size - estimated,
                "resize": f"{img.size} -> {resized.size}" if resized_changed else "no"}

    # Actually convert
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
        tmp_resized = Path(tmp.name)

    with tempfile.NamedTemporaryFile(suffix=new_ext, delete=False) as tmp:
        tmp_output = Path(tmp.name)

    try:
        # Save resized image as temp PNG
        resized.save(tmp_resized, "PNG")
        resized.close()
        img.close()

        if target_format == "webp":
            success = convert_to_webp(tmp_resized, tmp_output, quality)
        elif rule.get("compression") == "pngquant":
            success = compress_png(tmp_resized, tmp_output)
        else:
            # Plain PNG, just save the resized version
            shutil.copy2(tmp_resized, tmp_output)
            success = True

        if not success:
            return {"path": rel_path, "action": "error",
                    "original": original_size, "new": original_size, "saved": 0}

        new_size = tmp_output.stat().st_size

        # Only replace if we actually saved space (or changed format)
        if new_size < original_size or new_ext != old_ext.lower():
            # Remove original
            file_path.unlink()
            # Move optimized to final location
            shutil.move(str(tmp_output), str(new_path))
            tmp_output = None  # Don't delete in finally

            return {"path": rel_path, "new_path": str(new_path.relative_to(assets_dir)),
                    "action": f"converted_to_{target_format}",
                    "original": original_size, "new": new_size,
                    "saved": original_size - new_size}
        else:
            return {"path": rel_path, "action": "kept_original_smaller",
                    "original": original_size, "new": original_size, "saved": 0}

    finally:
        tmp_resized.unlink(missing_ok=True)
        if tmp_output:
            Path(tmp_output).unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description="Optimize Planet Wonders assets")
    parser.add_argument("--dry-run", action="store_true",
                        help="Report what would change without modifying files")
    parser.add_argument("--single", type=str,
                        help="Optimize a single file")
    parser.add_argument("--config", type=str, default=str(CONFIG_PATH),
                        help="Path to config YAML")
    args = parser.parse_args()

    config_path = Path(args.config)
    rules = load_config(config_path)

    if args.single:
        file_path = Path(args.single)
        if not file_path.exists():
            print(f"File not found: {file_path}")
            sys.exit(1)
        result = optimize_file(file_path, ASSETS_DIR, rules, dry_run=args.dry_run)
        print(f"{result['action']}: {result['path']}")
        print(f"  {result['original']:,} -> {result['new']:,} bytes "
              f"(saved {result['saved']:,})")
        return

    # Process all images
    files = get_image_files(ASSETS_DIR)
    print(f"Found {len(files)} image files to process")
    if args.dry_run:
        print("DRY RUN — no files will be modified\n")

    total_original = 0
    total_new = 0
    total_saved = 0
    converted = 0
    skipped = 0
    errors = 0

    for i, file_path in enumerate(files, 1):
        result = optimize_file(file_path, ASSETS_DIR, rules, dry_run=args.dry_run)

        total_original += result["original"]
        total_new += result["new"]
        total_saved += result["saved"]

        action = result["action"]
        if "convert" in action:
            converted += 1
            saved_pct = (result["saved"] / result["original"] * 100
                         if result["original"] > 0 else 0)
            print(f"[{i}/{len(files)}] {action}: {result['path']} "
                  f"({result['original']:,} -> {result['new']:,}, "
                  f"-{saved_pct:.0f}%)")
        elif action == "skip" or action == "no_rule":
            skipped += 1
        elif action == "error":
            errors += 1
            print(f"[{i}/{len(files)}] ERROR: {result['path']} "
                  f"— {result.get('error', 'unknown')}")
        elif action == "kept_original_smaller":
            skipped += 1

    # Summary
    print(f"\n{'='*60}")
    print(f"OPTIMIZATION SUMMARY")
    print(f"{'='*60}")
    print(f"Files processed:  {len(files)}")
    print(f"Converted:        {converted}")
    print(f"Skipped:          {skipped}")
    print(f"Errors:           {errors}")
    print(f"Original total:   {total_original / (1024*1024):.1f} MB")
    print(f"New total:        {total_new / (1024*1024):.1f} MB")
    print(f"Saved:            {total_saved / (1024*1024):.1f} MB "
          f"({total_saved / total_original * 100:.0f}%)"
          if total_original > 0 else "")


if __name__ == "__main__":
    main()
