#!/usr/bin/env bash
# Push a visible progress message to the active mobile-sync conversation.
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

KIND="${1:-status}"
shift || true
if [[ "$#" -eq 1 && "$1" == "-" ]]; then
  TEXT="$(cat)"
else
  TEXT="$*"
fi

if [[ -z "$TEXT" ]]; then
  echo "Usage: $0 <status|phase|question|chat> <message|->" >&2
  exit 1
fi

case "$KIND" in
  status|phase|question|chat) ;;
  *) echo "Invalid kind: $KIND" >&2; exit 1 ;;
esac
case "$TEXT" in
  *$'\r'*|*$'\t'*)
    echo "Message must not contain carriage returns or tabs" >&2
    exit 1
    ;;
esac
if [[ "$KIND" == "status" || "$KIND" == "phase" ]]; then
  case "$TEXT" in
    *$'\n'*) echo "$KIND messages must be a single line" >&2; exit 1 ;;
  esac
fi

REPO_ROOT="$(detect_repo_root)"
PORT_FILE="$REPO_ROOT/.sandtable-runtime/session/server.port"
PORT="${SANDTABLE_MOBILE_PORT:-$(cat "$PORT_FILE" 2>/dev/null || echo 8765)}"
ESCAPED_TEXT="$(
  printf '%s' "$TEXT" \
    | sed 's/\\/\\\\/g; s/"/\\"/g' \
    | awk 'BEGIN { first = 1 } { if (!first) printf "\\n"; printf "%s", $0; first = 0 }'
)"
PAYLOAD="{\"kind\":\"$KIND\",\"text\":\"$ESCAPED_TEXT\"}"

curl -fsS -m 5 -X POST "http://127.0.0.1:${PORT}/mobile-sync/notify" \
  -H 'content-type: application/json' \
  -d "$PAYLOAD"
printf '\n'
