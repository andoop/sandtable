---
name: mobile-companion
description: Use when the developer enables Sandtable mobile review / mobile sync / pairing code, or runs any /sandtable-mobile-* action (start/status/stop/wait), or asks to review PRD/tests/plan/state on the phone. Defines the on-demand mobile sync loop, the single-job inbox waiter, and worker discipline.
---

# Mobile Review Companion

**Announce at start:** "I'm using mobile-companion to manage Sandtable mobile sync."

Sync the current feature's phase, documents, and pending confirmations to the phone, and receive chat/confirmation/answer messages from it. **Optional capability**: if not explicitly enabled, do not start the server, do not write the mailbox, and do not change the default Sandtable flow.

> Trigger: Cursor/Claude/Kiro use the `/sandtable-mobile-*` commands; Codex uses `$mobile-companion`. Both run the same loop.

## When to enable

- The developer runs `/sandtable-mobile-start` (or asks to "turn on mobile sync / pair the phone / watch progress on the phone").
- `.sandtable-runtime/session/mobile-sync.json` exists with `active=true`.

Dependency: the repo must contain `runtime/server/` with deps installed (`npm --prefix runtime/server install`); see `docs/mobile-review-companion/runtime.md`.

## The four actions

| Action | Command | Script | Purpose |
|------|------|------|------|
| Start | `/sandtable-mobile-start` | `scripts/sandtable-mobile-start.sh [feature]` | Start the daemon server, print a 4-digit code + Server URL + QR, and spawn the inbox waiter |
| Status | `/sandtable-mobile-status` | `scripts/sandtable-mobile-status.sh` | Report whether the server runs, feature, code, paired, expiresAt |
| Stop | `/sandtable-mobile-stop` | `scripts/sandtable-mobile-stop.sh` | Stop the server and sync; the phone shows Disconnected |
| Wait | `/sandtable-mobile-wait` | `scripts/sandtable-mobile-wait.sh <feature>` | Single-job sub-agent: poll the inbox, hand one message to the main agent, exit |

## On-demand sync loop

1. **Start**: run `scripts/sandtable-mobile-start.sh [feature-id]`; print the pairing code, Server URL, and three-step progress. The computer needs no extra "connect"; the phone enters URL + 4-digit code (or scans the QR).
2. **Spawn the waiter**: run `/sandtable-mobile-wait` — the sub-agent **only** runs `scripts/sandtable-mobile-wait.sh <feature>` (polls inbox every 5s), hands one message verbatim to the main agent, then **exits immediately**; it **must not** check status/health, read the journal, or edit documents.
3. **Handle the phone message**: after the main agent handles it:
   - `curl -X POST http://127.0.0.1:8765/mailbox/inbox/ack -H 'content-type: application/json' -d '{"ids":["<message-id>"]}'`
   - then run `/sandtable-mobile-wait` to spawn the next waiter.
4. **Reply / push state**: reply to the phone via `POST /agent/sessions/<sid>/messages` (kind: chat/answer/confirmation); after updating Sandtable docs, if sync is active: `curl -X POST http://127.0.0.1:8765/mobile-sync/push-state`.
5. **Persist**: append a sync/handling entry to the feature `journal.md`.

## Persistent worker discipline

- Before ending a phase action, the main agent must renew `.sandtable-runtime/session/continuation.json` and hand mailbox waiting to one or more cheap/free waiting workers.
- Waiting workers may only wait, deduplicate, renew leases, notify, relay, or stop; unless explicitly assigned, they must not edit PRD/tests/plan or make product decisions for the main agent.
- Only a computer-side stop, a stop mailbox event, or an explicit developer stop request may mark the continuation stopped.

## Channel choice

- When MCP is available, prefer the Sandtable MCP handler for phase, document summary, pending confirmations, and blocked-state sync.
- Without MCP, read/write `.sandtable-runtime/mailbox/` per `docs/mobile-review-companion/protocol.md`.

## Red Flags

| Thought | Reality |
|------|------|
| "Starting the server means it's set up." | You must also spawn the inbox waiter, or phone messages go unhandled. |
| "The waiter can also check status / read the journal." | No. The waiter is single-job: poll inbox, deliver, exit. |
| "No need to ack after handling." | You must ack, or the same message is fetched repeatedly. |
| "No need to push state after editing docs." | When sync is active, push-state so the phone updates. |
| "It works without the runtime installed." | It needs repo `runtime/server` + npm deps; install per runtime.md first. |

Full protocol in `docs/mobile-review-companion/protocol.md`; startup and on-device verification in `runtime.md` / `verification.md`.
