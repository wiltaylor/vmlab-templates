#!/bin/sh
# Download + verify + extract the official Parrot Security QEMU image
# into disk/. Parrot distributes it as a zip, which vmlab's URL sources
# cannot unpack — so this script stages the raw qcow2 for vmlab.wcl's
# `source "qcow2" { path = "./disk/parrot.qcow2" }`.
set -eu

VERSION="7.2"
ARCHIVE="Parrot-security-${VERSION}_amd64.qcow2.zip"
URL="https://deb.parrot.sh/parrot/iso/${VERSION}/${ARCHIVE}"
SHA256="5aeabacf963b51b4bbcd3ba2794801ed474924afa275655ed206e5b85c1680d5"

cd "$(dirname "$0")"
mkdir -p disk

if [ -f disk/parrot.qcow2 ]; then
    echo "disk/parrot.qcow2 already present; delete it to re-fetch"
    exit 0
fi

if [ ! -f "disk/${ARCHIVE}" ]; then
    echo "downloading ${URL} ..."
    curl -L --fail -o "disk/${ARCHIVE}.part" "$URL"
    mv "disk/${ARCHIVE}.part" "disk/${ARCHIVE}"
fi

echo "${SHA256}  disk/${ARCHIVE}" | sha256sum -c -

echo "extracting ..."
unzip -o -d disk "disk/${ARCHIVE}" >/dev/null
QCOW2="$(find disk -name '*.qcow2' ! -name parrot.qcow2 | head -n1)"
[ -n "$QCOW2" ] || { echo "no qcow2 found in the archive" >&2; exit 1; }
mv "$QCOW2" disk/parrot.qcow2
rm -f "disk/${ARCHIVE}"
find disk -mindepth 1 -type d -empty -delete

echo "staged disk/parrot.qcow2"
