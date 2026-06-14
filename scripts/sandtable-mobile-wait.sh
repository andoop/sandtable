#!/usr/bin/env bash
# Wait for the next mobile inbox message, then print it and exit.
# Poll every 5s. No status checks. Main agent acks via POST /mailbox/inbox/ack after handling.
set -euo pipefail

FEATURE="${1:-}"
PORT="${SANDTABLE_MOBILE_PORT:-8765}"
BASE_URL="http://127.0.0.1:${PORT}"
AFTER="${2:-}"

if [[ -z "$FEATURE" ]]; then
  echo "Usage: $0 <feature-id> [after-message-id]" >&2
  exit 1
fi

while true; do
  QUERY="feature=${FEATURE}"
  if [[ -n "$AFTER" ]]; then
    QUERY="${QUERY}&after=${AFTER}"
  fi
  RESPONSE="$(curl -fsS "${BASE_URL}/mailbox/inbox?${QUERY}" 2>/dev/null || echo '{"messages":[]}')"
  COUNT="$(printf '%s' "$RESPONSE" | python3 -c 'import json,sys; print(len(json.load(sys.stdin).get("messages",[])))')"
  if [[ "$COUNT" != "0" ]]; then
    printf '%s\n' "$RESPONSE"
    exit 0
  fi
  sleep 5
done
