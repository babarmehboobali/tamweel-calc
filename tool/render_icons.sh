#!/bin/bash
set -e
mkdir -p assets/branding
echo "Requires rsvg-convert (sudo apt install librsvg2-bin) or ImageMagick."
if command -v rsvg-convert >/dev/null; then
  rsvg-convert -w 1024 -h 1024 assets/branding/logo.svg -o assets/branding/icon.png
  rsvg-convert -w 1024 -h 1024 assets/branding/icon_foreground.svg -o assets/branding/icon_foreground.png
  rsvg-convert -w 1024 -h 1024 assets/branding/icon_monochrome.svg -o assets/branding/icon_monochrome.png
  rsvg-convert -w 512 -h 512 assets/branding/logo.svg -o assets/branding/logo.png
else
  echo "rsvg-convert not found. Install librsvg2-bin and re-run."
  exit 1
fi
echo "PNGs ready. Run: dart run flutter_launcher_icons && dart run flutter_native_splash:create"
