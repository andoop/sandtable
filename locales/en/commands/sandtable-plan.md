---
description: Operational plan - turn the confirmed objectives into an executable, rehearsal-ready change plan (file map + small tasks).
---

Create or recreate the operational plan for the current requirement; read and follow `skills/writing-plan/SKILL.md`.

Execute:
1. Read the confirmed `prd.md` and `tests.md`; the plan must be based on them, and every verification step must cite TC numbers instead of inventing new expectations. Every referenced type / function / interface must either already exist in the project (cite `file:line`) or be defined by some task in this plan.
2. Start with a **file map** (which files will be created or changed, and the single responsibility of each).
3. Break the work into 2-5 minute tasks with exact paths, complete code, verification commands, and expected results (TDD, frequent commits).
4. No placeholders (`TBD`, "handle it appropriately", "write tests for the above" without actual code, etc.).
5. Self-check: PRD coverage, placeholder scan, type consistency, task order, and hidden scope creep.
6. Write `plan.md`, update `state.md` (write the task list, set `phase=MENTAL_REHEARSAL`), and tell me I can continue with `/sandtable-mental`.

Do not guess about uncertain points. Go back to reconnaissance or ask.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## Feature Addendum: Execute Already-Selected Paths and Persist PRD Evidence

- Priority: real blockers (`blocked=true`, missing product intent, permission, login, external resource, or key fact) come first and require `questions.md`, `blocked=true`, and a question; the PRD confirmation gate comes next; only then execute the user's selected path.
- If the user already selected the next step via AskQuestion or clearly wrote “confirm and continue / continue with X / choose X”, and there is no real blocker, the agent must execute that step in the same turn. Do not ask again and do not merely print the same copy-paste command.
- If the selection confirms the PRD, persist traceable PRD confirmation evidence to `state.md` or `journal.md` before or while entering TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief. AskQuestion evidence records answer id or `source: askquestion:<id>` plus option text and confirmation time; natural-language evidence records quoted user text, confirmation time, and user-message source.
- `/sandtable-start` still stops after writing an unconfirmed PRD. But if AskQuestion or natural language in the same turn already confirms the PRD and asks to continue, persist the evidence and continue directly to TESTCASES; the old command boundary must not override an already selected path.
- `/sandtable-objectives`, `/sandtable-refine`, and `/sandtable-resume` receiving “PRD confirmed, continue to tests.md” must record the natural-language evidence and load `writing-tests` directly. With `phase=OBJECTIVES` and an existing `prd.md`, do not re-enter `writing-prd`.
- `/sandtable-plan`, `writing-tests`, and `writing-plan` must check PRD confirmation first. If the same message confirms the PRD and triggers tests/plan writing, persist evidence before or while writing. Missing `tests.md` with confirmed PRD goes back to TESTCASES; unconfirmed PRD stops at confirmation.
- Refining the PRD still edits the PRD. Refining tests/plan or continuing to rehearsal requires PRD confirmation first. If `blocked=true` and the user also says continue, blocker wins.
- Full closeout has two profiles: if no path is selected, include recommendation and copy-paste templates; if a path was selected and executed, report result, current phase, and next recommendation only. Any template must point to the next stage, not repeat the already executed selection.
