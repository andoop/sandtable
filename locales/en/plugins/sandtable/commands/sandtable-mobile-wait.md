---
description: Spawn the inbox waiting sub-agent (single job: block until one phone message arrives, hand it to the main agent, then exit). The main agent blocks quietly the whole time — no polling, no timeouts, no busywork.
---

## Waiting protocol (iron law, identical across tools)

The main agent dispatches **one** waiting sub-agent and then **blocks waiting for it to return, for as long as it takes**. While waiting, the main agent does **nothing** — it does not poll inbox / status / health itself, does not set timeouts, does not repeatedly re-check the sub-agent, does not do any "busywork". This is exactly how Cursor behaves; **Kiro / Claude Code / Codex / other tools must do the same**: do not read "dispatch a sub-agent" as "start a background thing and keep watching it yourself".

> **Never use automation / background tasks / timers / scheduled jobs / background scripts to run `wait` (Codex especially: do NOT use automation, and do NOT hang `wait.sh` as a background waiter in place of a sub-agent). `wait` MUST be run by a real sub-agent that the main agent blocks on.** Using automation/background scripts breaks the "block-and-wait" semantics and turns the main agent into a self-poller — exactly the behavior we are eliminating.

> **On "only dispatch a sub-agent when the user explicitly asks"**: the user running `/sandtable-mobile-start` or `/sandtable-mobile-wait` **is** that explicit request. Here you **must force-dispatch** a sub-agent and may not substitute a background script / automation citing "no explicit request for parallel agents". You need not care whether the phone is paired yet or whether anyone has sent a message — just dispatch the waiting sub-agent.

**Responsibility split (strict main / sub):**
- **Main agent**: only ① dispatches the sub-agent, ② blocks for its return (zero actions), ③ on a message handles it + `ack` + reply/push-state, ④ dispatches the next one. It **never** runs `wait.sh` itself, never polls the inbox, never starts an automation.
- **Sub-agent**: does exactly one thing — block-poll the inbox, hand one message back as plain text, then exit. It **never** handles the message, acks, replies, edits docs, or loops/restarts.

## Execute

1. Determine the **feature id** (read `docs/sandtable/features/*/state.md` or the mobile-sync session; the user may specify it).
2. Using the current tool's "dispatch a sub-agent and **block until it returns**" primitive, dispatch **one** waiting sub-agent:
   - **Cursor / Claude Code**: the Task tool to dispatch a subagent.
   - **Kiro**: `invoke_sub_agent` (e.g. `general-task-execution`).
   - **Codex**: dispatch a sub-agent to run it (**do not use automation / background tasks**).
   - Others: any equivalent "dispatch a sub-agent and block for its return" mechanism (automation/timers likewise forbidden).
   - The sub-agent's prompt contains **only**:
     - Run `scripts/sandtable-mobile-wait.sh <feature-id>` — the script **block-polls the inbox until one message arrives, then returns** (it never times out while empty).
     - On a message, **do not paste the raw JSON blob** (Codex fails with "Markdown couldn't render"); relay as plain text, one line per message `- [message-id] <text>` (with feature/sessionId), then a final `ack-ids: <id…>` line; wrap raw JSON in a ```json code block``` if needed. Then **exit**.
     - The sub-agent **must not** check status/health, read the journal, edit documents, or loop/restart.
3. The main agent **blocks** for that sub-agent's return (however long it takes; no interrupting, no polling). Only after it returns does the main agent act: handle the message → `POST /mailbox/inbox/ack` (port from `.sandtable-runtime/session/server.port`) → run this command again to dispatch the **next** waiter.
4. While there is no message, the main agent stays **idle** — no inbox polling, no status/health checks, no timeouts.

> Fallback (only if your tool has a **hard execution cap** on sub-agents so an infinite block would be truncated): set the env var `SANDTABLE_WAIT_MAX_SECONDS=240` when dispatching. The script then returns `{"messages":[],"timeout":true}` ("no message yet") on timeout, and the main agent dispatches **another** waiting sub-agent — still "dispatch and block for its return", with the main agent **never polling itself and setting no other timeout**.

Do not ask whether to continue.
