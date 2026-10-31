#!/bin/bash
# Downloads variable Cairo / Noto Naskh Arabic and creates static weight instances (pdf package needs static TTFs).
# Requires: pip install fonttools
set -e
mkdir -p assets/fonts && cd assets/fonts
curl -sSL -o /tmp/Cairo-VF.ttf "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo%5Bslnt%2Cwght%5D.ttf"
curl -sSL -o /tmp/Naskh-VF.ttf "https://github.com/google/fonts/raw/main/ofl/notonaskharabic/NotoNaskhArabic%5Bwght%5D.ttf"
inst() { fonttools varLib.instancer "$1" $2 --static -q -o "$3"; }
inst /tmp/Cairo-VF.ttf "wght=400 slnt=0" Cairo-Regular.ttf
inst /tmp/Cairo-VF.ttf "wght=600 slnt=0" Cairo-SemiBold.ttf
inst /tmp/Cairo-VF.ttf "wght=700 slnt=0" Cairo-Bold.ttf
inst /tmp/Naskh-VF.ttf "wght=400" NotoNaskhArabic-Regular.ttf
inst /tmp/Naskh-VF.ttf "wght=700" NotoNaskhArabic-Bold.ttf
echo "Static fonts ready."
