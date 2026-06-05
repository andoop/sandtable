---
name: autonomous-orchestration
description: Use when the developer wants Sandtable to progress from intake through debrief without manual handoff between phases. Defines autonomous progression, minimum rehearsal quotas, rollback rules, and required state updates.
---

# Autonomous Sandtable Orchestration

**State this when you begin:** "I am using autonomous-orchestration to run the Sandtable flow unattended."

## HARD GATE

<HARD-GATE>
1. Autonomous mode must cover the full chain: `INTAKE -> RECON -> OBJECTIVES -> TESTCASES -> PLAN -> MENTAL_REHEARSAL -> REDTEAM -> IMPL_REHEARSAL -> EVALUATE`.
2. Minimum quotas are hard requirements:
   - mental: at least 3 rounds, at least 3 read-only subagents per round
   - redteam: at least 3 rounds, at least 3 red-team subagents per round
   - impl: at least 2 rounds, at least 2 independent worktree subagents per round
3. Any `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED` must be verified by the main agent first; then write back into `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md`, and restart from the earliest stage that is no longer validated. Failed rounds do not count toward quotas.
4. Only stop and ask the developer when you truly need product intent, login / auth / approval, or tool permission that cannot be self-resolved.
</HARD-GATE>

## AUTOPILOT-OVERRIDE

<AUTOPILOT-OVERRIDE>
1. This applies only when the developer explicitly triggers `/sandtable-autopilot`, or explicitly requests autopilot continuation through `/sandtable-resume`.
2. The scope is only the current command run. If the developer later triggers a manual slash command, obey that manual command’s boundary.
3. Manual commands may still write `rehearsals/`, `rehearsals.*.runs`, and `rehearsals.*.last`, but those records do not count toward `autonomy.completed_rounds`.
</AUTOPILOT-OVERRIDE>

## Autonomous Flow

1. Load `state-and-memory`, ensure `docs/sandtable/`, the feature directory, and `state.md` exist; if the feature does not exist, create it from templates with `phase=INTAKE`.
2. As soon as autonomous mode starts, write:
   - `autonomy.mode=autopilot`
   - `autonomy.min_rounds={ mental: 3, redteam: 3, impl: 2 }`
   - `autonomy.min_agents_per_round={ mental: 3, redteam: 3, impl: 2 }`
   - `autonomy.last_decision=entered autopilot, starting RECON`
   - `phase=RECON`
3. Complete `RECON -> OBJECTIVES -> TESTCASES -> PLAN` automatically.
4. On every automatic advance or rollback, update `state.md.updated`, `phase`, and `autonomy.last_decision`, and append the reason to `journal.md`.
5. Once inside the rehearsal chain, advance by quota closure:
   - while `autonomy.completed_rounds.mental < autonomy.min_rounds.mental`, continue mental rehearsal
   - then while `autonomy.completed_rounds.redteam < autonomy.min_rounds.redteam`, continue red-team
   - then while `autonomy.completed_rounds.impl < autonomy.min_rounds.impl`, continue implementation rehearsal
   - once all three quota sets are satisfied, enter `EVALUATE`
6. In autopilot, `phase` is a record, not the scheduler. On resume, quota closure decides the next step first.

## Round Counting

- A mental round counts only if it has at least 3 read-only subagents and all return `LOGIC_CLOSED`.
- A red-team round counts only if it has at least 3 red-team subagents and all return `HELD`.
- An implementation round counts only if it has at least 2 independent worktree subagents and all return `DONE`.
- If any subagent in the round returns anomaly / breach / blocked, the round does not count and must be rerun after the fix.

## Blocking and Rollback Decisions

| Signal | Main-agent decision | `state.md` action |
|------|------|------|
| `ANOMALY_FOUND` | verify personally, fix docs / plan, rehearse again | `blocked=false`; reset `phase` to the earliest invalidated stage; refresh `autonomy.last_decision` |
| `BREACH_FOUND` | verify personally, fix docs / plan, then re-validate from mental rehearsal | `blocked=false`; `phase=MENTAL_REHEARSAL`; refresh `autonomy.last_decision` |
| `BLOCKED` (internally fixable) | treat as a fixable blocker; fix and rehearse again | `blocked=false`; roll `phase` back as needed; refresh `autonomy.last_decision` |
| `BLOCKED` (external dependency) | escalate to a real blocker and ask the developer | `blocked=true`; keep current `phase`; record the reason in `autonomy.last_decision` |

## Required Writes

After each autonomous action, write all of:
- `state.md`: `phase`, `updated`, `autonomy.*`, and `selected_impl` when needed
- `journal.md`: why you advanced, rolled back, or escalated a blocker
- `rehearsals/`: one report per round, such as `mental-<n>.md`, `redteam-<n>.md`, `impl-<n>-<branch>.md`

## Red Flags

| Thought | Reality |
|------|------|
| "I should ask the user before every next step." | In autonomous mode, you continue by default unless there is a real blocker. |
| "This round found an anomaly, but I’ll still count it and make up the quota later." | No. Failed rounds do not count. Fix first, then rerun. |
| "I ran mental manually once, so that can count for autopilot." | No. Manual runs do not backfill `autonomy.completed_rounds`. |
| "The phase in state.md is enough; I do not need to check quotas." | Wrong. In autopilot, resume and continuation are driven by quota closure first. |
