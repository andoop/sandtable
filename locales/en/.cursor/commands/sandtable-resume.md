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

**You must fully read and follow every rule in `skills/_shared/autopilot-coverage.md` (minimum coverage, autonomous judgment, resume gate); do not skip or paraphrase from memory.**

## PRD Confirmation Gate and Executing Already-Selected Paths

**Before this action, you must fully read and follow every rule in `skills/_shared/prd-gate.md` (PRD confirmation gate and already-selected paths); do not skip or paraphrase from memory.**
