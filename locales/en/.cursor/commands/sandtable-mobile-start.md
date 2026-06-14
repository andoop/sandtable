---
description: Start mobile sync on demand: launch the runtime, generate a 4-digit pairing code, and spawn the inbox waiter.
---

Start Sandtable mobile sync on demand; read `docs/mobile-review-companion/runtime.md` § On-demand sync.

**UX points (must explain to the user):**
- **Computer**: just this command + Sandtable as usual; the Agent does **not** need to "connect" to anything separately.
- **Phone**: just the Server URL + 4-digit code; once connected, **wait for the Agent to sync automatically**.
- **Success signals**: the phone app shows "Ready / Agent synced"; on the computer `/sandtable-mobile-status` shows all three steps as ✓.

Execute:
1. Determine the repo root and feature; run `scripts/sandtable-mobile-start.sh [feature-id]`.
2. Prominently print the **pairing code**, **Server URL**, and the three-step progress notes.
3. Run `/sandtable-mobile-wait` (or equivalent steps) to spawn the **inbox waiting sub-agent**:
   - The sub-agent **only** runs `scripts/sandtable-mobile-wait.sh <feature>`, polling the inbox every 5s.
   - On receiving one message, hand it verbatim to the main agent and **exit immediately**.
   - The sub-agent **must not** check status/health, read the journal, or edit documents.
4. After the main agent handles a phone message: `POST /mailbox/inbox/ack`, then `/sandtable-mobile-wait` to start the next waiter.
5. After the main agent updates Sandtable documents, if sync is active: `curl -X POST http://127.0.0.1:8765/mobile-sync/push-state`.
6. Update the feature `journal.md`.

Do not ask whether to continue.
