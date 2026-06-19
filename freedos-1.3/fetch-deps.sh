#!/bin/sh
# Download + verify + extract the official FreeDOS 1.3 LiveCD into this directory.
# FreeDOS ships the media as a multi-file zip (FD13BOOT.img, FD13LIVE.iso,
# readme.txt), which vmlab's URL sources cannot unpack — so this stages the raw
# FD13LIVE.iso for vmlab.wcl's `source "iso" { path = "./FD13LIVE.iso" }`.
set -eu

ARCHIVE="FD13-LiveCD.zip"
URL="https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/${ARCHIVE}"
SHA256="250d3980b38d988ddfe100df1a5d09009c6fee17cbabd17274d5284e02a491c4"

cd "$(dirname "$0")"

if [ -f FD13LIVE.iso ]; then
    echo "FD13LIVE.iso already present; delete it to re-fetch"
    exit 0
fi

if [ ! -f "${ARCHIVE}" ]; then
    echo "downloading ${URL} ..."
    curl -L --fail -o "${ARCHIVE}.part" "$URL"
    mv "${ARCHIVE}.part" "${ARCHIVE}"
fi

echo "${SHA256}  ${ARCHIVE}" | sha256sum -c -

echo "extracting FD13LIVE.iso ..."
unzip -o "${ARCHIVE}" FD13LIVE.iso >/dev/null
[ -f FD13LIVE.iso ] || { echo "FD13LIVE.iso not found in ${ARCHIVE}" >&2; exit 1; }

# Drop the zip + the boot floppy image we don't use (the iso is enough).
rm -f "${ARCHIVE}" FD13BOOT.img

echo "staged FD13LIVE.iso"
