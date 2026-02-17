#!/usr/bin/env python3
"""
Region Mask Generator for Planet Wonders Coloring Pages

Generates region mask PNGs from outline images. Each closed region gets a unique
integer ID (1-255). Pixel value 0 = outline/border (not fillable).

Usage:
    python generate_masks.py input_outline.png output_mask.png

Requirements:
    pip install opencv-python numpy pillow

Algorithm:
    1. Load outline PNG (black lines on white background)
    2. Convert to grayscale
    3. Threshold to binary (lines become foreground)
    4. Dilate lines by 1-2px to seal anti-aliased gaps
    5. Invert (white regions become foreground)
    6. connectedComponents() labels each enclosed region with unique ID
    7. Save single-channel PNG (pixel value = region ID, 0 = border)
"""

import sys
import cv2
import numpy as np
from PIL import Image


def generate_mask(input_path, output_path, dilate_iterations=1, threshold=200):
    """
    Generate a region mask from an outline image.

    Args:
        input_path: Path to input outline PNG (black lines on white)
        output_path: Path to output mask PNG (grayscale, region IDs)
        dilate_iterations: Number of dilation passes to seal gaps (default: 1)
        threshold: Grayscale threshold for line detection (default: 200)
    """
    print(f"Loading outline image: {input_path}")
    img = cv2.imread(input_path)

    if img is None:
        raise ValueError(f"Could not load image: {input_path}")

    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    print(f"  Image size: {gray.shape[1]}x{gray.shape[0]}")

    # Threshold: pixels below threshold become foreground (lines)
    # For black lines on white: low values are lines
    _, binary = cv2.threshold(gray, threshold, 255, cv2.THRESH_BINARY_INV)
    print(f"  Thresholded at {threshold}")

    # Dilate lines to seal anti-aliased gaps
    if dilate_iterations > 0:
        kernel = np.ones((3, 3), np.uint8)
        binary = cv2.dilate(binary, kernel, iterations=dilate_iterations)
        print(f"  Dilated {dilate_iterations} iteration(s)")

    # Invert: white regions (inside outlines) become foreground
    inverted = cv2.bitwise_not(binary)

    # Find connected components (each region gets unique ID)
    num_labels, labels = cv2.connectedComponents(inverted, connectivity=8)
    print(f"  Found {num_labels - 1} regions (excluding background)")

    # Identify components that touch ANY border (outside/open regions).
    # Fillable regions should be fully enclosed by outlines and therefore
    # should not touch the canvas edge.
    height, width = labels.shape

    border_components = set(labels[0, :])
    border_components.update(labels[height - 1, :])
    border_components.update(labels[:, 0])
    border_components.update(labels[:, width - 1])

    # Component 0 is the outline, always non-fillable.
    border_components.discard(0)

    print(f"  Components touching border (outside/open): {len(border_components)}")
    for comp in sorted(border_components):
        size = np.sum(labels == comp)
        print(f"    Component {comp}: {size} pixels")

    # Create mask: 0 for lines/outline/outside-open, 1..N for enclosed regions
    mask = np.zeros_like(gray, dtype=np.uint8)

    # Count component sizes for filtering and reporting
    component_sizes = []
    for label in range(num_labels):
        # Skip component 0 (outline) and border-touching outside/open regions.
        if label == 0 or label in border_components:
            continue
        size = np.sum(labels == label)
        component_sizes.append((label, size))

    # Sort by size for reporting
    component_sizes.sort(key=lambda x: x[1], reverse=True)

    # Filter out tiny regions (likely noise/anti-aliasing artifacts)
    MIN_REGION_SIZE = 50
    filtered_components = [
        (label, size) for label, size in component_sizes
        if size >= MIN_REGION_SIZE
    ]

    print(f"  Filtered to {len(filtered_components)} fillable regions (removed {len(component_sizes) - len(filtered_components)} tiny regions)")

    # Remap: outline + canvas background → 0, all other components → 1, 2, 3...
    region_id = 1
    for label, size in filtered_components:
        mask[labels == label] = region_id
        if region_id <= 10 or region_id > len(filtered_components) - 5:  # Print first 10 and last 5
            print(f"    Region {region_id}: component {label}, size {size} pixels")
        elif region_id == 11:
            print(f"    ... ({len(filtered_components) - 15} more regions) ...")
        region_id += 1
        if region_id > 255:
            print("  WARNING: More than 255 regions after filtering! Capping at 255.")
            break

    # Save mask as single-channel PNG
    print(f"Saving mask to: {output_path}")
    Image.fromarray(mask, mode='L').save(output_path)
    print(f"✓ Mask generated successfully: {num_labels - 1} regions")


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        print("\nUsage:")
        print("  python generate_masks.py input_outline.png output_mask.png")
        print("\nOptional arguments:")
        print("  --dilate N      Number of dilation iterations (default: 1)")
        print("  --threshold T   Grayscale threshold for line detection (default: 200)")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    # Parse optional arguments
    dilate = 1
    threshold = 200

    for i in range(3, len(sys.argv)):
        if sys.argv[i] == '--dilate' and i + 1 < len(sys.argv):
            dilate = int(sys.argv[i + 1])
        elif sys.argv[i] == '--threshold' and i + 1 < len(sys.argv):
            threshold = int(sys.argv[i + 1])

    try:
        generate_mask(input_path, output_path, dilate_iterations=dilate, threshold=threshold)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
