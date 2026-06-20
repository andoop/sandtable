---
inclusion: always
---

# Sandtable — Always-Loaded Baseline (Concise)

> The Kiro CLI default agent always loads this concise baseline (equivalent to Cursor's `.cursor/rules/sandtable.mdc`).
> **The full methodology loads on demand**: the entry point for any Sandtable work is reading `skills/using-sandtable/SKILL.md`; read other details in each `skills/<name>/SKILL.md`. Do not keep all rules resident in context.

## What you're doing
Use Sandtable to turn a one-line requirement into what the developer **actually wants** — closed logical loop, closed product loop, perfect details. The method is a cycle: **make a plan → rehearse → find problems → fix the plan → rehearse again**, until rehearsals pass, then integrate the best.

## Four non-negotiable bottom lines
1. **No guessing, no fabrication, be truthful**: when unsure, read code/docs or ask the developer, and write it back to PRD/plan/state.
2. **Think before acting**: state assumptions explicitly; lay out multiple options; if unclear, stop and ask.
3. **Surgical changes**: touch only what must change; no catch-alls, no unrequested "flexibility"; every line traceable to a requirement.
4. **Goal-driven**: turn the task into verifiable success criteria and loop until they pass.

"Too simple to need the process" is the most dangerous rationalization — every requirement goes through the process; a simple one can have a very short process.

## Core loop (state machine)
`INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN → MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE → INTEGRATE → VERIFY → DONE → FEEDBACK`

Any rehearsal finding that affects the loop/acceptance/feasibility/key decisions → **stop immediately and report** → main agent verifies → propose a fix or ask the developer → fix PRD/plan → re-rehearse.

## Two iron laws of rehearsal
1. The moment any rehearsal finds something off-plan, unexpected, or previously unnoticed, **stop immediately and report** — do not "patch it and keep running."
2. Rehearsals run in **isolated sub-agents**, possibly in parallel; implementation rehearsals each use their own git worktree/branch.

## Priority
Explicit user instruction > Sandtable methodology > default behavior. If the user says "skip the process / just change it," do so, but flag the risk.

## Command entry (Kiro CLI)
Trigger with `/prompts sandtable-<name>` or `@sandtable-<name>` (`@` + Tab to complete); `/prompts` lists all. Main entry `sandtable-start`; autonomous `sandtable-autopilot`; resume `sandtable-resume`; status `sandtable-status`.

## Skill index (read `skills/<name>/SKILL.md` on demand)
`using-sandtable` (main entry), `being-truthful`, `state-and-memory`, `gathering-intel`, `writing-prd`, `writing-tests`, `writing-plan`, `autonomous-orchestration`, `mental-rehearsal`, `red-team-wargame`, `implementation-rehearsal`, `evaluating-rehearsals`, `closing-the-loop`, `triaging-feedback`, `bugfix-with-evidence`, `mobile-companion`.
Issue grading (P0–P3), turn-closing, and the details of the three rehearsal types live in `using-sandtable` and related skills — read them when you enter that step, not resident here.

## Two standing gates
- **PRD confirmation gate**: if `prd.md` exists without traceable developer confirmation, do not dispatch mental/OPFOR subagents; when the same message confirms the PRD, first persist the evidence to `state.md`/`journal.md`.
- **Standing mobile-sync duty** (only when `.sandtable-runtime/session/mobile-sync.json` has `active=true` and the sync server is running): syncing to the phone is a standing duty regardless of trigger source (phone instruction or direct computer-side conversation alike); call `scripts/sandtable-mobile-notify.sh <kind> <message>` before/during/after important actions, on phase changes, key decisions, confirmations, or blockers; `agent-state` does not replace a conversation notification; main reports working as its first action after wait returns and idle as its last action after handling, while the server never infers main state from inbox GET; multi-fact phone messages must use `chat/question` multi-line Markdown, never raw JSON or unstructured long paragraphs; the waiting sub-agent blocks forever with no timeout. See `skills/mobile-companion/SKILL.md`.
