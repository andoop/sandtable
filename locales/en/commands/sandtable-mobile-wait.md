---
description: Spawn the inbox waiting sub-agent (single job: wait for one phone message, hand it to the main agent, then exit).
---

**The sub-agent does exactly one thing**: poll the inbox, hand any new message to the main agent, then exit.

Execute:
1. Read `docs/sandtable/features/*/state.md` or the mobile-sync session to determine the **feature id** (the user may specify it).
2. Use Task to launch a **background sub-agent** whose prompt contains **only**:
   - Run `scripts/sandtable-mobile-wait.sh <feature-id>` (polls the inbox every 5s; **must not** check status/health/outbox).
   - Once the script stdout emits JSON, hand the `messages` **verbatim** to the main agent, then the sub-agent **exits**.
   - **Must not** read the journal, edit the PRD, check server status, or loop/restart.
3. After the main agent handles the message:
   - `curl -X POST http://127.0.0.1:8765/mailbox/inbox/ack -H 'content-type: application/json' -d '{"ids":["<message-id>"]}'`
   - Then run `/sandtable-mobile-wait` to spawn the next waiter.

Do not ask whether to continue.
