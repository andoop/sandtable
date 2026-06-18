---
description: Start mobile sync on demand: launch the runtime, generate a 4-digit pairing code, and spawn the inbox waiter.
---

Start Sandtable mobile sync on demand. Details in `docs/mobile-review-companion/runtime.md` § On-demand sync.

> **Running this command = the user has explicitly requested that you dispatch a sub-agent to run `wait`.** Any default rule like "only use multi-agent when the user explicitly asks" is **already satisfied here** — you **must** force-dispatch a real sub-agent and **must not** substitute a background script / automation / timer citing "no explicit request for parallel agents". `wait` must be run by the sub-agent; after dispatching, the main agent only blocks idle for its return — no polling, no status/health checks, no timeouts.

Execute:
1. **Force feature choice**: list `docs/sandtable/features/` and you **must** use **AskQuestion** to make me pick one; do not assume and do not skip this step (most recent listed first as the recommendation).
2. **Start the server**: with the chosen `<feature>`, run `scripts/sandtable-mobile-start.sh <feature>` (returns immediately). Do **not** hesitate or hold off because "the phone isn't paired yet / no one has sent a message" — just start the server and dispatch the waiter; pairing and messaging are the user's side.
3. **Sync pairing info (mandatory)**: once the server is up, you **must** show me the Server URL and pairing code verbatim using this template (missing either field means start failed — investigate):

   ```
   📱 Sandtable mobile sync started
   Server URL   : <server_url>
   Pairing code : <pairing_code> (valid for 10 minutes)
   Feature      : <feature>
   How to       : on the phone, enter the URL + 4-digit code (or scan the QR)
   ```

4. **Force-dispatch the waiter**: run `/sandtable-mobile-wait` to dispatch **one** sub-agent that block-polls the inbox, then stay idle until it returns.
5. **Handle the message**: only after the sub-agent returns a message — report `agent-state main=working` → handle → `POST /mailbox/inbox/ack` → `main=idle` → `/sandtable-mobile-wait` again. On error report `main=error`.

Port comes from `.sandtable-runtime/session/server.port`. Other than step 1, do not ask whether to continue.
