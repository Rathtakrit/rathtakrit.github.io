#!/bin/bash
# strip-exif.sh — Remove EXIF metadata from photos before publishing
# Usage: ./scripts/strip-exif.sh <input-dir> [output-dir]
#
# Requires: exiftool (brew install exiftool)
#
# This strips GPS coordinates, camera serial numbers, timestamps,
# and other personally identifiable metadata while preserving image quality.

set -euo pipefail

INPUT_DIR="${1:?Usage: $0 <input-dir> [output-dir]}"
OUTPUT_DIR="${2:-$INPUT_DIR/stripped}"

if ! command -v exiftool &>/dev/null; then
  echo "❌ exiftool not found. Install with: brew install exiftool"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "🔒 Stripping EXIF from photos in: $INPUT_DIR"
echo "📂 Output directory: $OUTPUT_DIR"
echo ""

count=0
for img in "$INPUT_DIR"/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP} 2>/dev/null; do
  [ -f "$img" ] || continue
  filename=$(basename "$img")

  # Copy file then strip all metadata
  cp "$img" "$OUTPUT_DIR/$filename"
  exiftool -overwrite_original -all= "$OUTPUT_DIR/$filename" 2>/dev/null

  count=$((count + 1))
  echo "  ✅ $filename"
done

if [ "$count" -eq 0 ]; then
  echo "⚠️  No image files found in $INPUT_DIR"
else
  echo ""
  echo "🎉 Done! Stripped EXIF from $count photos."
  echo ""
  echo "Next steps:"
  echo "  1. Move stripped photos to: static/gallery/"
  echo "  2. Add entries to content/gallery/_index.md front matter"
  echo "  3. Example front matter entry:"
  echo '     - src: "/gallery/my-photo.jpg"'
  echo '       alt: "Description of the photo"'
  echo '       width: 1200'
  echo '       height: 800'
fi
