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
INBOX_DIR="$REPO_ROOT/.sandtable-runtime/mailbox/inbox"

if [[ -z "$FEATURE" ]]; then
  echo "Usage: $0 <feature-id> [after-message-id]" >&2
  exit 1
fi

# Report waiter runtime state to the phone (best-effort; never blocks the loop).
report_state() {
  curl -fsS -m 3 -X POST "${BASE_URL}/mobile-sync/agent-state" \
    -H 'content-type: application/json' \
    -d "{\"role\":\"waiter\",\"state\":\"$1\",\"detail\":\"$2\"}" >/dev/null 2>&1 || true
}
report_state waiting "等待手机消息"

# Codex subagents may be allowed to read the workspace while loopback network
# access is denied. The mailbox directory is the server's source of truth, so
# use the same filters locally when HTTP cannot be reached from the waiter.
read_inbox_files() {
  python3 - "$INBOX_DIR" "$FEATURE" "$AFTER" <<'PY'
import json
import pathlib
import sys

inbox = pathlib.Path(sys.argv[1])
feature = sys.argv[2]
after = sys.argv[3]
messages = []

if inbox.is_dir():
    for path in sorted(inbox.glob("*.json")):
        try:
            message = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        if message.get("source") != "mobile":
            continue
        if feature and message.get("feature") != feature:
            continue
        if after and str(message.get("id", "")) <= after:
            continue
        messages.append(message)

messages.sort(key=lambda message: str(message.get("id", "")))
print(json.dumps({"ok": True, "messages": messages}, separators=(",", ":")))
PY
}

# 默认无限阻塞等待（Cursor 等支持长子 agent 的工具最理想：主 agent 阻塞等其返回）。
# 若工具对子 agent 有硬执行上限，设 SANDTABLE_WAIT_MAX_SECONDS=240：到时返回
# {"messages":[],"timeout":true}，主 agent 据此再派一个等待子 agent（仍不自己轮询）。
MAX="${SANDTABLE_WAIT_MAX_SECONDS:-0}"
START="$(date +%s)"

while true; do
  QUERY="feature=${FEATURE}"
  if [[ -n "$AFTER" ]]; then
    QUERY="${QUERY}&after=${AFTER}"
  fi
  if ! RESPONSE="$(curl -fsS -m 5 "${BASE_URL}/mailbox/inbox?${QUERY}" 2>/dev/null)"; then
    RESPONSE="$(read_inbox_files)"
  fi
  COUNT="$(printf '%s' "$RESPONSE" | python3 -c 'import json,sys; print(len(json.load(sys.stdin).get("messages",[])))')"
  if [[ "$COUNT" != "0" ]]; then
    report_state processing "已收到消息，交主 agent 处理"
    printf '%s\n' "$RESPONSE"
    exit 0
  fi
  if [[ "$MAX" =~ ^[0-9]+$ ]] && (( MAX > 0 )); then
    NOW="$(date +%s)"
    if (( NOW - START >= MAX )); then
      printf '%s\n' '{"messages":[],"timeout":true}'
      exit 0
    fi
  fi
  sleep 5
done
