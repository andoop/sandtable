#!/usr/bin/env bash
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

detect_lan_ip() {
  ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || printf '127.0.0.1\n'
}

latest_feature() {
  local root="$1"
  ls -1dt "$root/docs/sandtable/features"/* 2>/dev/null | head -1 | xargs basename 2>/dev/null || true
}

REPO_ROOT="$(detect_repo_root)"
FEATURE="${1:-$(latest_feature "$REPO_ROOT")}"
PREFERRED_PORT="${SANDTABLE_MOBILE_PORT:-8765}"
LAN_IP="$(detect_lan_ip)"
PID_FILE="$REPO_ROOT/.sandtable-runtime/session/server.pid"
PORT_FILE="$REPO_ROOT/.sandtable-runtime/session/server.port"

mkdir -p "$(dirname "$PID_FILE")"

# Return the repo a running server on $1 reports, or empty if nothing answers.
health_repo() {
  local port="$1"
  curl -fsS --max-time 1 "http://127.0.0.1:${port}/health" 2>/dev/null \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("repo",""))' 2>/dev/null || true
}

# Pick a port: reuse the one already serving THIS repo, else the first free port.
# Avoids clobbering another repo'\''s server that happens to hold the preferred port.
choose_port() {
  local p
  for p in $(seq "$PREFERRED_PORT" $((PREFERRED_PORT + 30))); do
    local repo
    repo="$(health_repo "$p")"
    if [[ -z "$repo" ]]; then
      printf '%s\n' "$p"; return 0          # free port
    fi
    if [[ "$repo" == "$REPO_ROOT" ]]; then
      printf '%s\n' "$p"; return 0          # our own server, reuse
    fi
    # otherwise: another repo owns this port, keep scanning
  done
  printf '%s\n' "$PREFERRED_PORT"; return 0
}

PORT="$(choose_port)"
PUBLIC_URL="http://${LAN_IP}:${PORT}"
BASE_URL="http://127.0.0.1:${PORT}"
printf '%s\n' "$PORT" >"$PORT_FILE"

# Start only if our server is not already running on the chosen port.
if [[ "$(health_repo "$PORT")" != "$REPO_ROOT" ]]; then
  node "$REPO_ROOT/runtime/server/scripts/start-daemon.mjs" \
    --repo "$REPO_ROOT" \
    --host 0.0.0.0 \
    --port "$PORT" \
    --public-url "$PUBLIC_URL" >/dev/null 2>&1 || true
  for _ in $(seq 1 30); do
    if curl -fsS "$BASE_URL/health" >/dev/null 2>&1; then break; fi
    sleep 0.5
  done
fi

if [[ -z "${FEATURE:-}" ]]; then
  echo "错误: 找不到 feature，请传入 feature id" >&2
  exit 1
fi

RESPONSE="$(curl -fsS -X POST "$BASE_URL/mobile-sync/start" \
  -H 'content-type: application/json' \
  -d "{\"feature\":\"$FEATURE\"}")"

CODE="$(printf '%s' "$RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["code"])')"

# Durable token (persisted server-side) for scan-to-connect QR.
PAIRING="$(curl -fsS "$BASE_URL/pairing?feature=$FEATURE" 2>/dev/null || echo '{}')"
QR_TOKEN="$(printf '%s' "$PAIRING" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("token",""))' 2>/dev/null || true)"
QR_PAYLOAD=""
if [[ -n "$QR_TOKEN" ]]; then
  QR_PAYLOAD="$(QR_URL="$PUBLIC_URL" QR_TOK="$QR_TOKEN" python3 -c 'import os,urllib.parse as u; print("sandtable://pair?url=%s&token=%s" % (u.quote(os.environ["QR_URL"], safe=""), u.quote(os.environ["QR_TOK"], safe="")))' 2>/dev/null || true)"
fi

cat <<EOF

Sandtable 手机同步
==================

[✓] 电脑 Server 已就绪（Agent 无需额外「连接」）
[ ] 等待手机配对

Feature   : $FEATURE
配对码    : $CODE
Server URL: $PUBLIC_URL

>>> 在 iPhone App 输入上述 URL + 配对码，点「连接」。

成功标志：
  · 手机：显示「已就绪」或「Agent 已同步 · 当前阶段 …」
  · 电脑：运行 /sandtable-mobile-status 看到 phonePaired: true

EOF

if [[ -n "$QR_PAYLOAD" ]]; then
  echo "或直接用 App 扫描下面的二维码连接（免输入）："
  echo
  node "$REPO_ROOT/runtime/server/scripts/qr-print.mjs" --text "$QR_PAYLOAD" 2>/dev/null || echo "（二维码渲染失败，请用上面的 URL + 配对码）"
  echo
fi

# Poll up to 90s for phone pairing (optional wait, non-blocking for script exit)
for _ in $(seq 1 45); do
  STATUS="$(curl -fsS "$BASE_URL/mobile-sync/status" 2>/dev/null || echo '{}')"
  PAIRED="$(printf '%s' "$STATUS" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("steps",{}).get("phonePaired", False))' 2>/dev/null || echo False)"
  if [[ "$PAIRED" == "True" ]]; then
    PHASE="$(printf '%s' "$STATUS" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("phase") or "")')"
    cat <<EOF2

[✓] 手机已配对成功
[✓] Agent 已同步${PHASE:+ · 阶段 $PHASE}

电脑照常推进 Sandtable 即可，手机会自动更新。

下一步: /sandtable-mobile-wait  （启动 inbox 等待子 agent）

EOF2
    exit 0
  fi
  sleep 2
done

cat <<EOF3

[ ] 尚未检测到手机配对（可稍后在 App 输入配对码）
    查看状态: /sandtable-mobile-status
    等待手机消息: /sandtable-mobile-wait
    停止同步: /sandtable-mobile-stop

EOF3
