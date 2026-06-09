---
name: autonomous-orchestration
description: Use when the developer wants Sandtable to progress from intake through debrief without manual handoff between phases. Defines autonomous progression, minimum coverage and autonomous continuation rules, rollback rules, and required state updates.
---

# Autonomous Sandtable Orchestration

**State this when you begin:** "I am using autonomous-orchestration to run the Sandtable flow unattended."

## HARD GATE

<HARD-GATE>
1. Autonomous mode must cover the full chain: `INTAKE -> RECON -> OBJECTIVES -> TESTCASES -> PLAN -> MENTAL_REHEARSAL -> REDTEAM -> IMPL_REHEARSAL -> EVALUATE`.
2. Minimum minimum coverage are hard requirements:
   - mental: at least 1 round, at least 1 read-only subagent per round
   - redteam: at least 1 round, at least 1 red-team subagent per round
   - impl: at least 1 round, at least 1 independent worktree subagent per round
3. Any `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED` must be verified by the main agent first; then write back into `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md`, and restart from the earliest stage that is no longer validated. Failed rounds do not count toward minimum coverage.
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
2. First decide whether this is a cold start / explicit restart or a continuation of an existing feature:
   - Only a cold start (new feature, no existing `state.md` or feature documents, or the developer explicitly asks to restart from the raw request) initializes `autonomy.mode=autopilot`, `autonomy.min_rounds={ mental: 1, redteam: 1, impl: 1 }`, `autonomy.min_agents_per_round={ mental: 1, redteam: 1, impl: 1 }`, `autonomy.completed_rounds={ mental: 0, redteam: 0, impl: 0 }`, `autonomy.last_decision=entered autopilot, starting RECON; minimum coverage is one mental/redteam/impl round`, and `phase=RECON`.
   - When continuing an existing feature/docs/state, write or preserve `autonomy.mode=autopilot` only; do not overwrite existing `min_rounds`, `min_agents_per_round`, `completed_rounds`, or `phase`. Refresh only the necessary `autonomy.last_decision` explaining that autopilot is resuming from current state.
3. Only the cold-start path may automatically complete `RECON -> OBJECTIVES -> TESTCASES -> PLAN`. Resume/continuation must check document completeness and the PRD confirmation gate before TESTCASES/PLAN/MENTAL/REDTEAM/IMPL. If `prd.md` exists without traceable developer confirmation, stop at PRD confirmation; if this same turn confirms the PRD, persist that evidence to `state.md` or `journal.md` before or while continuing.
4. On every automatic advance or rollback, update `state.md.updated`, `phase`, and `autonomy.last_decision`, and append the reason to `journal.md`.
5. Once inside the rehearsal chain, advance by minimum coverage plus autonomous judgment:
   - while `autonomy.completed_rounds.mental < autonomy.min_rounds.mental`, continue mental rehearsal
   - then while `autonomy.completed_rounds.redteam < autonomy.min_rounds.redteam`, continue red-team
   - then while `autonomy.completed_rounds.impl < autonomy.min_rounds.impl`, continue implementation rehearsal
   - once all three minimum-coverage sets are satisfied and the implementation completeness gate is still valid, autonomously decide whether to add more rehearsal or enter `EVALUATE`, and record the reason in `autonomy.last_decision`
6. In autopilot, `phase` is a record, not the scheduler. On resume, first enforce the PRD confirmation gate and document-completeness checks, then use `autonomy.completed_rounds`, completeness-gate validity, and autonomous judgment to decide the next step.

## Round Counting

- A mental round counts only if it has at least 1 read-only subagent and all return `LOGIC_CLOSED`.
- A red-team round counts only if it has at least 1 red-team subagent and all return `HELD`.
- An implementation round counts only if it has at least 1 independent worktree subagent and all return `DONE`.
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
| "The phase in state.md is enough; I do not need to check minimum coverage." | Wrong. In autopilot, resume and continuation are driven by minimum coverage plus autonomous judgment first. |

## Feature Addendum: Minimum Coverage, Autonomous Judgment, Resume Gate

- `autonomy.min_rounds` and `autonomy.min_agents_per_round` mean minimum coverage, defaulting to `{ mental: 1, redteam: 1, impl: 1 }`. Do not migrate or overwrite historical features that already recorded 3/3/2.
- Only a cold start initializes `phase=RECON` and runs the full `RECON -> OBJECTIVES -> TESTCASES -> PLAN` document chain. If `state.md` or any feature artifact already exists, resume in place and preserve existing `min_rounds`, `min_agents_per_round`, `completed_rounds`, and `phase`.
- Before resuming into TESTCASES/PLAN/MENTAL/REDTEAM/IMPL, enforce the PRD confirmation gate. Confirmation must be traceable to developer input and persisted to `state.md` or `journal.md` before or while continuing. AskQuestion confirmation needs an answer id or `source: askquestion:<id>`; natural-language confirmation needs the quoted user text, confirmation time, and user-message source. Agent-authored progress logs, `autonomy.last_decision`, `phase>=TESTCASES`, vague “AskQuestion answer”, or source-less `prd_confirmed` fields do not count.
- If documents are incomplete, resume from the earliest missing artifact. If `prd.md` exists but is not confirmed, stop at PRD confirmation instead of moving to tests or plan.
- Rehearsal scheduling first fills mental -> redteam -> impl minimum coverage. Once minimum coverage is met, the main agent decides autonomously whether to add more rehearsal or enter `EVALUATE`, based on risk, change surface, lessons hit, recently fixed anomalies, implementation divergence, test confidence, and spot checks. Do not ask the user whether to continue unless truly blocked.
- Implementation `DONE` is not enough to count the impl round or enter `EVALUATE`; the completeness gate must pass, and EVALUATE must re-check the current PRD/tests/plan structured baseline, coverage matrix, live TODO table, and real diff / changed file list.
