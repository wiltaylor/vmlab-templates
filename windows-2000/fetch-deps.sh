#!/usr/bin/env bash
# Stage the unattended answer floppy for Windows 2000 setup.
#
# CD-boot Setup automatically reads A:\winnt.sif; we build that floppy from
# ./answer/ (gitignored — it carries the product key). The key comes from .env
# (WINDOWS_2000_PRO_KEY); winnt.sif.in holds everything else with a placeholder.
set -euo pipefail
cd "$(dirname "$0")"

# Load product keys from the repo-root .env if present.
if [ -f ../.env ]; then set -a; . ../.env; set +a; fi
: "${WINDOWS_2000_PRO_KEY:?set WINDOWS_2000_PRO_KEY in ../.env (see ../.env.example)}"

rm -rf answer
mkdir -p answer
sed "s/__PRODUCT_KEY__/${WINDOWS_2000_PRO_KEY}/" winnt.sif.in > answer/winnt.sif
echo "staged answer/winnt.sif (key injected from .env)"
