#!/usr/bin/env bash
# Report the main agent's actual execution state to the active mobile session.
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

STATE="${1:-}"
shift || true
DETAIL="$*"

case "$STATE" in
  idle|working|error|disconnected) ;;
  *) echo "Usage: $0 <idle|working|error|disconnected> [detail]" >&2; exit 1 ;;
esac
case "$DETAIL" in
  *$'\n'*|*$'\r'*|*$'\t'*)
    echo "Detail must be a single line without control characters" >&2
    exit 1
    ;;
esac

REPO_ROOT="$(detect_repo_root)"
PORT_FILE="$REPO_ROOT/.sandtable-runtime/session/server.port"
PORT="${SANDTABLE_MOBILE_PORT:-$(cat "$PORT_FILE" 2>/dev/null || echo 8765)}"
ESCAPED_DETAIL="$(printf '%s' "$DETAIL" | sed 's/\\/\\\\/g; s/"/\\"/g')"
PAYLOAD="{\"role\":\"main\",\"state\":\"$STATE\",\"detail\":\"$ESCAPED_DETAIL\"}"

curl -fsS -m 5 -X POST "http://127.0.0.1:${PORT}/mobile-sync/agent-state" \
  -H 'content-type: application/json' \
  -d "$PAYLOAD"
printf '\n'
