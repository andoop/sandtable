#!/usr/bin/env bash
set -euo pipefail

# Publish Sandtable runtime events for iOS/mobile SSE listening tests.
#
# Usage:
#   ./scripts/mobile-listening-e2e.sh \
#     --base-url http://127.0.0.1:8765 \
#     --feature 2026-06-13-mobile-listening-test \
#     --token <pairing-token> \
#     --phase PLAN \
#     --summary "Moved to PLAN from mobile test script"

BASE_URL="http://127.0.0.1:8765"
FEATURE=""
TOKEN=""
PHASE=""
SUMMARY=""
DOCUMENT_NAME=""
DOCUMENT_CONTENT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url) BASE_URL="$2"; shift 2 ;;
    --feature) FEATURE="$2"; shift 2 ;;
    --token) TOKEN="$2"; shift 2 ;;
    --phase) PHASE="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --document-name) DOCUMENT_NAME="$2"; shift 2 ;;
    --document-content) DOCUMENT_CONTENT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$FEATURE" || -z "$TOKEN" ]]; then
  echo "Usage: $0 --feature <id> --token <pairing-token> [--phase PLAN] [--document-name prd --document-content '...']" >&2
  exit 1
fi

if [[ -n "$PHASE" ]]; then
  curl -fsS -X POST "$BASE_URL/features/$FEATURE/sync/phase" \
    -H 'content-type: application/json' \
    -d "{\"token\":\"$TOKEN\",\"phase\":\"$PHASE\",\"summary\":\"$SUMMARY\"}"
  echo
fi

if [[ -n "$DOCUMENT_NAME" ]]; then
  curl -fsS -X POST "$BASE_URL/features/$FEATURE/sync/document" \
    -H 'content-type: application/json' \
    -d "{\"token\":\"$TOKEN\",\"name\":\"$DOCUMENT_NAME\",\"content\":$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$DOCUMENT_CONTENT")}"
  echo
fi
