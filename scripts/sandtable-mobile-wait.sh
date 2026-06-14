#!/usr/bin/env bash
# Wait for the next mobile inbox message, then print it and exit.
# Poll every 5s. No status checks. Main agent acks via POST /mailbox/inbox/ack after handling.
set -euo pipefail

detect_repo_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/docs/sandtable" || -d "$dir/.sandtable-runtime" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  printf '%s\n' "$PWD"
}

FEATURE="${1:-}"
AFTER="${2:-}"
# Resolve THIS repo's server port. Multi-repo: each repo's server may bind a
# different port (start.sh choose_port skips ports held by another repo's
# server). Read server.port so the waiter polls the SAME server the phone
# paired with — hard-coding 8765 would query another repo's server and never
# see this feature's messages. Matches status.sh / stop.sh.
REPO_ROOT="$(detect_repo_root)"
PORT_FILE="$REPO_ROOT/.sandtable-runtime/session/server.port"
PORT="${SANDTABLE_MOBILE_PORT:-$(cat "$PORT_FILE" 2>/dev/null || echo 8765)}"
BASE_URL="http://127.0.0.1:${PORT}"

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
