---
description: Resume after a handoff, AI swap, or interruption by rebuilding context from persistent state and continuing in the correct mode.
---

Resume and take over the current requirement; read and follow the "resume flow" in `skills/state-and-memory/SKILL.md`.

Execute:
1. Read the global `docs/sandtable/project.md` and `constraints.md` to restore the project goal and red-line context.
2. List `features/` and determine which requirement to resume (ask me if there is more than one candidate).
3. Read that requirement’s `state.md`, prioritizing `autonomy.*`, `phase`, and `tasks`; if `blocked: true`, read `questions.md` first and resolve the blocker.
4. Read recent entries from `journal.md` to rebuild context. **Decisions already written there are authoritative; do not reinvent them.**
5. Read `prd.md`, `tests.md`, `plan.md`, and any reports already in `rehearsals/`.
6. If `autonomy.mode=autopilot` and `blocked=false`, treat this `/sandtable-resume` as an explicit autopilot continuation for this turn only: enable `<AUTOPILOT-OVERRIDE>` and continue from the first incomplete quota in the order `mental -> redteam -> impl -> EVALUATE`; do not count manual `rehearsals.*` reports as `autonomy.completed_rounds`.
7. Only when `autonomy.mode=manual` or `blocked=true`, summarize in 3-5 lines: what we are doing, where we stopped, why we stopped, and what the next step is, then wait for my confirmation only when no traceable confirmation or selected path exists; if this turn already includes a clear selection/confirmation and continuation request, persist the required evidence before or while continuing.

Go back to `being-truthful` only when you detect contradiction or missing information. Do not silently extend autopilot semantics onto a later manual slash command I trigger explicitly.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## Minimum Coverage, Autonomous Judgment, Resume Gate

- `autonomy.min_rounds` and `autonomy.min_agents_per_round` mean minimum coverage, defaulting to `{ mental: 1, redteam: 1, impl: 1 }`. Do not migrate or overwrite historical features that already recorded 3/3/2.
- Only a cold start initializes `phase=RECON` and runs the full `RECON -> OBJECTIVES -> TESTCASES -> PLAN` document chain. If `state.md` or any feature artifact already exists, resume in place and preserve existing `min_rounds`, `min_agents_per_round`, `completed_rounds`, and `phase`.
- Before resuming into TESTCASES/PLAN/MENTAL/REDTEAM/IMPL, enforce the PRD confirmation gate. Confirmation must be traceable to developer input and persisted to `state.md` or `journal.md` before or while continuing. AskQuestion confirmation needs an answer id or `source: askquestion:<id>`; natural-language confirmation needs the quoted user text, confirmation time, and user-message source. Agent-authored progress logs, `autonomy.last_decision`, `phase>=TESTCASES`, vague “AskQuestion answer”, or source-less `prd_confirmed` fields do not count.
- If documents are incomplete, resume from the earliest missing artifact. If `prd.md` exists but is not confirmed, stop at PRD confirmation instead of moving to tests or plan.
- Rehearsal scheduling first fills mental -> redteam -> impl minimum coverage. Once minimum coverage is met, the main agent decides autonomously whether to add more rehearsal or enter `EVALUATE`, based on risk, change surface, lessons hit, recently fixed anomalies, implementation divergence, test confidence, and spot checks. Do not ask the user whether to continue unless truly blocked.
- Implementation `DONE` is not enough to count the impl round or enter `EVALUATE`; the completeness gate must pass, and EVALUATE must re-check the current PRD/tests/plan structured baseline, coverage matrix, live TODO table, and real diff / changed file list.

## PRD Confirmation Gate and Executing Already-Selected Paths

- Priority: real blockers (`blocked=true`, missing product intent, permission, login, external resource, or key fact) come first and require `questions.md`, `blocked=true`, and a question; the PRD confirmation gate comes next; only then execute the user's selected path.
- If the user already selected the next step via AskQuestion or clearly wrote “confirm and continue / continue with X / choose X”, and there is no real blocker, the agent must execute that step in the same turn. Do not ask again and do not merely print the same copy-paste command.
- If the selection confirms the PRD, persist traceable PRD confirmation evidence to `state.md` or `journal.md` before or while entering TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief. AskQuestion evidence records answer id or `source: askquestion:<id>` plus option text and confirmation time; natural-language evidence records quoted user text, confirmation time, and user-message source.
- `/sandtable-start` still stops after writing an unconfirmed PRD. But if AskQuestion or natural language in the same turn already confirms the PRD and asks to continue, persist the evidence and continue directly to TESTCASES; the old command boundary must not override an already selected path.
- `/sandtable-objectives`, `/sandtable-refine`, and `/sandtable-resume` receiving “PRD confirmed, continue to tests.md” must record the natural-language evidence and load `writing-tests` directly. With `phase=OBJECTIVES` and an existing `prd.md`, do not re-enter `writing-prd`.
- `/sandtable-plan`, `writing-tests`, and `writing-plan` must check PRD confirmation first. If the same message confirms the PRD and triggers tests/plan writing, persist evidence before or while writing. Missing `tests.md` with confirmed PRD goes back to TESTCASES; unconfirmed PRD stops at confirmation.
- Refining the PRD still edits the PRD. Refining tests/plan or continuing to rehearsal requires PRD confirmation first. If `blocked=true` and the user also says continue, blocker wins.
- Full closeout has two profiles: if no path is selected, include recommendation and copy-paste templates; if a path was selected and executed, report result, current phase, and next recommendation only. Any template must point to the next stage, not repeat the already executed selection.
