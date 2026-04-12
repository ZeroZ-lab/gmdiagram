#!/usr/bin/env bash
# gmdiagram export script
# Converts HTML/SVG diagrams to PNG or PDF
#
# Usage: ./scripts/export.sh <input.html|input.svg> --format png|pdf [--output filename]
#
# Requirements:
#   PNG: Node.js + npm (uses @resvg/resvg-js)
#   PDF: rsvg-convert (brew install librsvg)

set -euo pipefail

INPUT=""
FORMAT=""
OUTPUT=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --output)
      OUTPUT="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 <input.html|input.svg> --format png|pdf [--output filename]"
      echo ""
      echo "Formats:"
      echo "  png   Export as high-resolution PNG (2000px width) using @resvg/resvg-js"
      echo "  pdf   Export as vector PDF using rsvg-convert"
      echo ""
      echo "Requirements:"
      echo "  PNG: Node.js 18+ and npm"
      echo "  PDF: rsvg-convert (install via: brew install librsvg)"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      INPUT="$1"
      shift
      ;;
  esac
done

# Validate
if [[ -z "$INPUT" ]]; then
  echo "Error: No input file specified" >&2
  echo "Usage: $0 <input.html|input.svg> --format png|pdf" >&2
  exit 1
fi

if [[ -z "$FORMAT" ]]; then
  echo "Error: No format specified. Use --format png or --format pdf" >&2
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: File not found: $INPUT" >&2
  exit 1
fi

# Validate format
if [[ "$FORMAT" != "png" && "$FORMAT" != "pdf" ]]; then
  echo "Error: Unknown format. Use 'png' or 'pdf'." >&2
  exit 1
fi

# Determine output filename
BASENAME="${INPUT%.*}"
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${BASENAME}.${FORMAT}"
fi

# Validate output path is within current working directory
OUTPUT_REAL="$(cd "$(dirname "$OUTPUT")" 2>/dev/null && pwd)/$(basename "$OUTPUT")" || OUTPUT_REAL="$(pwd)/$OUTPUT"
ALLOWED_DIR="$(pwd)"
if [[ "$OUTPUT_REAL" != "$ALLOWED_DIR"* ]]; then
  echo "Error: Output file must be within current directory" >&2
  exit 1
fi

# Extract SVG from HTML if needed
TEMP_SVG=""
if [[ "$INPUT" == *.html ]]; then
  echo "Extracting SVG from HTML..."
  TEMP_SVG=$(mktemp /tmp/gmdiagram-XXXXXX.svg)
  chmod 600 "$TEMP_SVG"
  # Extract content between <svg> and </svg> tags
  sed -n '/<svg/,/<\/svg>/p' "$INPUT" > "$TEMP_SVG"
  SVG_FILE="$TEMP_SVG"
else
  SVG_FILE="$INPUT"
fi

# Export based on format
case "$FORMAT" in
  png)
    # Check for Node.js
    if ! command -v node &> /dev/null; then
      echo "Error: Node.js is required for PNG export" >&2
      echo "Install from: https://nodejs.org" >&2
      if [[ -n "$TEMP_SVG" ]]; then rm -f "$TEMP_SVG"; fi
      exit 1
    fi

    # Ensure resvg-js is installed
    cd "$SCRIPT_DIR"
    if [[ ! -d "node_modules/@resvg/resvg-js" ]]; then
      echo "Installing @resvg/resvg-js..."
      npm install 2>&1 || {
        echo "Error: Failed to install @resvg/resvg-js" >&2
        if [[ -n "$TEMP_SVG" ]]; then rm -f "$TEMP_SVG"; fi
        exit 1
      }
    fi

    # Extract background color from SVG or use white as default
    BG_COLOR=$(grep -o 'background[^;]*#\([0-9a-fA-F]\{3,8\}\)' "$SVG_FILE" | head -1 | grep -o '#[0-9a-fA-F]\{3,8\}' || echo "#ffffff")

    echo "Converting to PNG (2000px width)..."
    node -e "
      const { Resvg } = require('@resvg/resvg-js');
      const fs = require('fs');
      const svg = fs.readFileSync(process.argv[1]);
      const resvg = new Resvg(svg, {
        background: process.argv[3],
        fitTo: { mode: 'width', value: 2000 },
        font: { loadSystemFonts: true, defaultFontFamily: 'JetBrains Mono' }
      });
      const pngData = resvg.render();
      fs.writeFileSync(process.argv[2], pngData.asPng());
      console.log('Done: ' + process.argv[2] + ' (' + Math.round(pngData.asPng().length / 1024) + ' KB)');
    " "$SVG_FILE" "$OUTPUT" "$BG_COLOR"
    ;;

  pdf)
    # Check for rsvg-convert
    if ! command -v rsvg-convert &> /dev/null; then
      echo "Error: rsvg-convert is required for PDF export" >&2
      echo "Install via: brew install librsvg" >&2
      if [[ -n "$TEMP_SVG" ]]; then rm -f "$TEMP_SVG"; fi
      exit 1
    fi

    echo "Converting to vector PDF..."
    rsvg-convert -f pdf -o "$OUTPUT" "$SVG_FILE"
    echo "Done: $OUTPUT"
    ;;

  *)
    echo "Error: Unknown format '$FORMAT'. Use 'png' or 'pdf'." >&2
    if [[ -n "$TEMP_SVG" ]]; then rm -f "$TEMP_SVG"; fi
    exit 1
    ;;
esac

# Cleanup temp file
if [[ -n "$TEMP_SVG" ]]; then
  rm -f "$TEMP_SVG"
fi
