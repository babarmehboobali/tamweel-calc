#!/bin/bash
set -e
cd "$(dirname "$0")/.."
zip -r ../tamweel_calc.zip . -x "build/*" ".dart_tool/*" "android/key.properties" "*.jks" "*.keystore" ".git/*"
echo "Created ../tamweel_calc.zip"

