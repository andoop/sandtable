---
description: Start mobile sync on demand: launch the runtime, generate a 4-digit pairing code, and spawn the inbox waiter.
---

Start Sandtable mobile sync on demand; read `docs/mobile-review-companion/runtime.md` § On-demand sync.

**UX points (must explain to the user):**
- **Computer**: just this command + Sandtable as usual; the Agent does **not** need to "connect" to anything separately.
- **Phone**: just the Server URL + 4-digit code; once connected, **wait for the Agent to sync automatically**.
- **Success signals**: the phone app shows "Ready / Agent synced"; on the computer `/sandtable-mobile-status` shows all three steps as ✓.

Execute (keep the main agent light; hand waiting and heavy work to the sub-agent / script, and stay idle when there is no message):
1. Run `scripts/sandtable-mobile-start.sh [feature-id]` (returns immediately, non-blocking) and show me the **pairing code + Server URL** verbatim.
2. **Immediately** run `/sandtable-mobile-wait` to spawn the **single-job** inbox waiter; the main agent does not poll or repeatedly check status/health itself.
3. Only when the waiter hands back a phone message does the main agent act (port from `.sandtable-runtime/session/server.port`): report `agent-state main=working` → handle it → `POST /mailbox/inbox/ack` → report `agent-state main=idle` → then `/sandtable-mobile-wait` for the next waiter. On error, report `main=error`.
4. Only after the main agent updates Sandtable documents and sync is active: `POST /mobile-sync/push-state`; record a line in `journal.md` for phase actions.

Do not ask whether to continue.
