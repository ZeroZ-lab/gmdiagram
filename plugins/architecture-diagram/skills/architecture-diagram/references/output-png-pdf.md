# PNG/PDF Export Reference

## Usage

After generating an HTML or SVG diagram, use the export script to convert:

```bash
# PNG export (high-resolution, 2000px width)
./scripts/export.sh diagram.html --format png

# PDF export (vector quality)
./scripts/export.sh diagram.html --format pdf

# SVG input also works
./scripts/export.sh diagram.svg --format png --output my-diagram.png
```

## Requirements

### PNG Export
- **Node.js** 18+ (for @resvg/resvg-js)
- The script auto-installs the dependency on first run

### PDF Export
- **rsvg-convert** (from librsvg)
- Install: `brew install librsvg` (macOS) or `apt install librsvg2-bin` (Linux)

## How It Works

1. If input is HTML, extract the `<svg>` element using sed
2. For PNG: use @resvg/resvg-js (Rust-based SVG renderer) to rasterize at 2000px width
3. For PDF: use rsvg-convert for direct SVG-to-PDF vector conversion

## Limitations

- PNG background defaults to `#020617` (dark) — adjust in the script for light styles
- Google Fonts need to be available on the system for accurate rendering in PNG
- SVG filters (cyberpunk glow) may render slightly differently in PNG vs browser
