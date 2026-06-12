#!/bin/sh
# Download + verify + extract the official Kali QEMU image into disk/.
# Kali distributes it as a 7z archive, which vmlab's URL sources cannot
# unpack — so this script stages the raw qcow2 for vmlab.wcl's
# `source "qcow2" { path = "./disk/kali.qcow2" }`.
set -eu

VERSION="2026.1"
ARCHIVE="kali-linux-${VERSION}-qemu-amd64.7z"
URL="https://cdimage.kali.org/kali-${VERSION}/${ARCHIVE}"
SHA256="efce2da10c775da5f58954166f633d5da9115e29663731dcb65d616f19d966f4"

cd "$(dirname "$0")"
mkdir -p disk

if [ -f disk/kali.qcow2 ]; then
    echo "disk/kali.qcow2 already present; delete it to re-fetch"
    exit 0
fi

if [ ! -f "disk/${ARCHIVE}" ]; then
    echo "downloading ${URL} ..."
    curl -L --fail -o "disk/${ARCHIVE}.part" "$URL"
    mv "disk/${ARCHIVE}.part" "disk/${ARCHIVE}"
fi

echo "${SHA256}  disk/${ARCHIVE}" | sha256sum -c -

echo "extracting ..."
7z x -odisk -y "disk/${ARCHIVE}" >/dev/null
QCOW2="$(find disk -name '*.qcow2' ! -name kali.qcow2 | head -n1)"
[ -n "$QCOW2" ] || { echo "no qcow2 found in the archive" >&2; exit 1; }
mv "$QCOW2" disk/kali.qcow2
rm -f "disk/${ARCHIVE}"
find disk -mindepth 1 -type d -empty -delete

echo "staged disk/kali.qcow2"
