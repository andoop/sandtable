---
description: Stop mobile sync and shut down the runtime server.
---

Stop Sandtable mobile sync.

Execute:
1. Run `scripts/sandtable-mobile-stop.sh`.
2. Confirm `GET /health` is unavailable or `mobile-sync/status` shows inactive.
3. Tell the user the phone app will show Reconnecting/Disconnected; they must run `/sandtable-mobile-start` again to resync.
4. If there is an active feature, append a stop entry to `journal.md`.
