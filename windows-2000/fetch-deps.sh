#!/usr/bin/env bash
# Stage the Windows 2000 build inputs, injecting the product key from .env so no
# key is ever committed:
#   - answer/winnt.sif  (the unattended answer floppy, read as A:\winnt.sif)
#   - scripts/install.wisp  (the GUI key is typed here too, since retail media
#     ignores winnt.sif's ProductKey — see install.wisp.in)
# Both are generated from *.in templates and are gitignored.
set -euo pipefail
cd "$(dirname "$0")"

# Load product keys from the repo-root .env if present.
if [ -f ../.env ]; then set -a; . ../.env; set +a; fi
: "${WINDOWS_2000_PRO_KEY:?set WINDOWS_2000_PRO_KEY in ../.env (see ../.env.example)}"

rm -rf answer
mkdir -p answer
sed "s/__PRODUCT_KEY__/${WINDOWS_2000_PRO_KEY}/" winnt.sif.in > answer/winnt.sif

# The GUI key page has 5 auto-advancing boxes, so type the key without dashes.
sed "s/__PRODUCT_KEY__/${WINDOWS_2000_PRO_KEY//-/}/" scripts/install.wisp.in > scripts/install.wisp

echo "staged answer/winnt.sif + scripts/install.wisp (key injected from .env)"
