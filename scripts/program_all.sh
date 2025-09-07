#!/usr/bin/env bash
set -euo pipefail

# Batch program N ATmega328P chips using Atmel-ICE via Arduino CLI + MiniCore.
# - Sets fuses for 8 MHz internal RC + BOD 2.7 V (Burn Bootloader).
# - Compiles the example sketch once.
# - Uploads it N times; you swap chips between uploads.
#
# Usage:
#   PROG=atmelice_isp ./scripts/program_all.sh -n 3
# Defaults:
COUNT=3
PROG="${PROG:-atmel_ice}"

while getopts ":n:" opt; do
  case $opt in
    n) COUNT="$OPTARG" ;;
    *) echo "Usage: $0 [-n COUNT]"; exit 1 ;;
  esac
done

echo "==> Installing/Updating Arduino CLI core index..."
arduino-cli core update-index

echo "==> Installing MiniCore..."
arduino-cli core install MiniCore:avr \
  --additional-urls https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json

FQBN='MiniCore:avr:328:clock=8MHz_internal,BOD=2v7,bootloader=no_bootloader'

echo "==> Burning bootloader (fuses only) with $PROG"
arduino-cli burn-bootloader -b "$FQBN" -P "$PROG"

echo "==> Compiling sketch (sketches/serial_echo)..."
arduino-cli compile -b "$FQBN" sketches/serial_echo

for i in $(seq 1 "$COUNT"); do
  echo
  read -r -p "Insert chip #$i and press Enter to program..." _
  echo "==> Uploading to chip #$i with $PROG"
  arduino-cli upload -b "$FQBN" -P "$PROG" sketches/serial_echo
  echo "==> Done chip #$i"
done

echo
echo "==> Listing available programmers (for reference):"
arduino-cli board details -b MiniCore:avr:328 | sed -n '/Programmers:/,/^$/p' || true
echo "All done."
