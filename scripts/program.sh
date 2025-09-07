#!/usr/bin/env bash
set -euo pipefail

# Program a single ATmega328P chip using Atmel-ICE via Arduino CLI + MiniCore.
# - Sets fuses for 8 MHz internal RC + BOD 2.7 V (Burn Bootloader).
# - Compiles the example sketch once.
# - Uploads it to the chip you have connected.
#
# Usage:
#   PROG=atmelice_isp ./scripts/program_one.sh
# Default programmer is 'atmel_ice'.

PROG="${PROG:-atmel_ice}"
FQBN='MiniCore:avr:328:clock=8MHz_internal,BOD=2v7,bootloader=no_bootloader'

echo "==> Installing/Updating Arduino CLI core index..."
arduino-cli core update-index

echo "==> Installing MiniCore (if missing)..."
arduino-cli core install MiniCore:avr \
  --additional-urls https://mcudude.github.io/MiniCore/package_MCUdude_MiniCore_index.json

echo "==> Burning bootloader (sets fuses) with $PROG"
arduino-cli burn-bootloader -b "$FQBN" -P "$PROG"

echo "==> Compiling sketch (sketches/serial_echo)..."
arduino-cli compile -b "$FQBN" sketches/serial_echo

echo
read -r -p "Ensure chip is inserted and press Enter to program..." _
echo "==> Uploading to chip with $PROG"
arduino-cli upload -b "$FQBN" -P "$PROG" sketches/serial_echo
echo "==> Done"

echo
echo "==> Listing available programmers (for reference):"
arduino-cli board details -b MiniCore:avr:328 | sed -n '/Programmers:/,/^$/p' || true
echo "All done."
