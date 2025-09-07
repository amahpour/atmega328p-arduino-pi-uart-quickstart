#!/usr/bin/env bash
set -euo pipefail

DEV="${1:-/dev/serial0}"
BAUD=38400

echo "Using device: $DEV @ $BAUD baud"
stty -F "$DEV" $BAUD -icrnl -ixon -echo
echo "Type 'h' for hello, 't' for millis(), or any text to echo. Ctrl-C to quit."
# print incoming bytes
cat < "$DEV" &
READER_PID=$!
trap "kill $READER_PID 2>/dev/null || true" EXIT

# simple interactive forwarder: stdin -> device
while IFS= read -r -n1 ch; do
  printf "%s" "$ch" > "$DEV"
done
