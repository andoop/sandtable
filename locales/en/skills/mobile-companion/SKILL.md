---
name: mobile-companion
description: Use when the developer enables Sandtable mobile review / mobile sync / pairing code, or runs any /sandtable-mobile-* action (start/status/stop/wait), or asks to review PRD/tests/plan/state on the phone. Defines the on-demand mobile sync loop, the single-job inbox waiter, and worker discipline.
---

# Mobile Review Companion

**Announce at start:** "I'm using mobile-companion to manage Sandtable mobile sync."

Sync the current feature's phase, documents, and pending confirmations to the phone, and receive chat/confirmation/answer messages from it. **Optional capability**: if not explicitly enabled, do not start the server, write the mailbox, or change the default flow.

> Trigger: Cursor/Claude/Kiro use `/sandtable-mobile-*`; Codex uses `$mobile-companion`. Same loop.
> When to enable: the developer runs `/sandtable-mobile-start`, or `.sandtable-runtime/session/mobile-sync.json` has `active=true`.
> Dependency: repo `runtime/server/` with `npm --prefix runtime/server install` done (see `runtime.md`).

## Main agent / sub-agent split (iron law)

- **`wait` (block-polling the inbox) is done ONLY by a real sub-agent; the main agent must never poll, check status/health, or set timeouts.**
- **Running `/sandtable-mobile-start` or `/sandtable-mobile-wait` IS the user's explicit request to dispatch a sub-agent.** Any default rule like "only use multi-agent when the user explicitly asks" is **already satisfied here** — you must **force-dispatch** a sub-agent and **must not** substitute a background script / automation / timer citing "no explicit request for parallel agents" (Codex especially: do not use automation, and do not hang `wait.sh` as a background waiter in place of a sub-agent).
- **Do not care** whether the phone is paired yet or whether anyone has sent a message — just start the server and force-dispatch the waiter; pairing and messaging are the user's side.
- **Main agent's job**: ① dispatch **one** waiter, ② block for its return (for as long as it takes, zero actions), ③ on a message handle it + `ack` + reply/push-state, ④ dispatch the next. It never runs `wait.sh` itself and never starts an automation.
- **Sub-agent's job**: only run `scripts/sandtable-mobile-wait.sh <feature>`, grab one message, hand it back as **plain text** (no raw JSON blob, or Codex fails to render), and exit. It never handles the message, acks, replies, checks status, reads the journal, edits docs, or loops/restarts.
- Interaction loop: main dispatches → sub waits and returns one message → main handles and acks → main dispatches again. No role crosses over.
- The "dispatch a sub-agent and block for its return" primitive: Cursor/Claude = Task, **Kiro = `invoke_sub_agent`**, **Codex = force-dispatch a sub-agent (not automation)**.

## The four actions

| Action | Command | Script | Purpose |
|------|------|------|------|
| Start | `/sandtable-mobile-start` | `sandtable-mobile-start.sh [feature]` | Start the server, print code + URL + QR, spawn the waiter |
| Status | `/sandtable-mobile-status` | `sandtable-mobile-status.sh` | Report server/feature/code/paired/expiresAt |
| Stop | `/sandtable-mobile-stop` | `sandtable-mobile-stop.sh` | Stop server and sync (phone shows Disconnected) |
| Wait | `/sandtable-mobile-wait` | `sandtable-mobile-wait.sh <feature>` | Sub-agent: block-poll inbox, hand one message to main agent, exit |

## On-demand sync loop

1. **Start**: list `docs/sandtable/features/`, use AskQuestion to make the developer **force-pick** the feature (no assuming, no skipping), then run `sandtable-mobile-start.sh <feature>`. Once the server is up you **must** show the pairing info **and the QR** in the conversation using this template (missing URL / code / QR = start failed):

   ```
   📱 Sandtable mobile sync started
   - Server URL   : <server_url>
   - Pairing code : <pairing_code> (valid 10 min)
   - Feature      : <feature>
   - How to       : in the iPhone app enter the URL + 4-digit code, or scan the QR below
   ```

   Take the QR from the compact block between `----- QR BEGIN -----`/`----- QR END -----` in the script output (produced by `qr-print.mjs --utf8`) and **put it in its own monospaced code block**, otherwise it misaligns and won't scan.
2. **Spawn the waiter**: run `/sandtable-mobile-wait` (see the split iron law above), then stay idle until it returns.
3. **Handle + ack**: after the waiter returns a message, the main agent handles it → `POST /mailbox/inbox/ack {"ids":["<id>"]}` → `/sandtable-mobile-wait` for the next.
4. **Reply / push state**: reply via `POST /agent/sessions/<sid>/messages`; after editing Sandtable docs with sync active, `POST /mobile-sync/push-state`.
5. **Persist**: append one entry to the feature `journal.md`.

Use one entry point for proactive progress:

```bash
scripts/sandtable-mobile-notify.sh <status|phase|question|chat> '<phone-visible message>'
```

The script calls `POST /mobile-sync/notify`; the server resolves the current valid session and repairs `mobile-sync.json.sessionId` when an old session was replaced. Agents must not guess a session id from message history.

Port comes from `.sandtable-runtime/session/server.port`.

## Runtime state sync to the phone

Scripts report automatically (start→main idle, wait→waiter waiting/processing, stop→disconnected/exited). When the main agent handles a message, it also reports its own state:

```
POST /mobile-sync/agent-state {"role":"main","state":"working|idle|error","detail":"…"}
```

The phone then shows main agent (idle/working/disconnected/error) and waiter (ready/waiting/processing/exited).

## Standing sync duty (active whenever the sync server is alive)

Whenever mobile-sync is **active** (server running + `.sandtable-runtime/session/mobile-sync.json` has `active=true`), syncing to the phone is a **standing duty, regardless of trigger source** — whether the instruction came from the phone or the developer is talking to you directly **on the computer**, the rule is the same.

- **Do not sync only when the phone sends a message.** Proactively sync **before / during / after** important actions:
  - Phase change → `POST /features/<feature>/sync/phase` or `POST /agent/sessions/<sid>/messages {"kind":"status"}`.
  - Key decision / option choice / trade-off → sync a one-line summary.
  - A confirmation or blocker arises → sync `{"kind":"question"}` and persist to `questions.md` / `state.md` per protocol.
  - Edited a Sandtable doc (PRD/tests/plan/state) → `POST /mobile-sync/push-state`.
  - Start / finish an important piece of work → report `agent-state main=working|idle` + a one-line progress note.
- **Visible progress must enter the conversation**: call `scripts/sandtable-mobile-notify.sh` at the points above. `POST /mobile-sync/agent-state` only drives the status indicator; by itself it does not count as a progress notification and cannot replace notify.
- **What counts as an "important moment"**: anything affecting the loop / acceptance / key decisions, or that the developer would want to see on the phone. Don't spam trivial intermediate steps.
- **The waiting sub-agent blocks forever with no timeout (pure wait)**: by default do **not** pass `SANDTABLE_WAIT_MAX_SECONDS`; the sub-agent blocks until it gets one message. **Only** when the host imposes a **hard execution cap** that would truncate an infinite block, use the fallback (e.g. `=240`); on timeout the main agent **immediately, seamlessly dispatches another** waiter, never polling or setting any other timeout.

## Red Flags

| Thought | Reality |
|------|------|
| "Starting the server means it's set up." | You must also spawn the waiter, or phone messages go unhandled. |
| "The main agent can just run wait / check status itself." | Forbidden. Only the sub-agent runs `wait`; after dispatching, the main agent does nothing and blocks for its return. |
| "Using automation / a background task for wait is easier." | Forbidden (Codex especially). Dispatch a real sub-agent and have the main agent block for its reply. |
| "The waiter can also read the journal / edit docs." | Forbidden. Single-job: poll, deliver, exit. |
| "No need to ack after handling." | You must ack, or the same message is fetched repeatedly. |
| "Sync only when the phone sends a message." | Wrong. A live sync server is a standing duty; computer-side conversation must also sync before/during/after important actions. |
| "Set a timeout on the waiter for peace of mind." | Default is infinite block, no timeout; use `SANDTABLE_WAIT_MAX_SECONDS` only when the host has a hard execution cap, then seamlessly re-dispatch on timeout. |

Full protocol in `docs/mobile-review-companion/protocol.md`; startup and on-device verification in `runtime.md` / `verification.md`.
