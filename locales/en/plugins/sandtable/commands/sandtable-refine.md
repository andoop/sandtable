---
description: Revise the deployment - after I review the goals or plan, update, extend, or recreate them until I am satisfied.
---

Refine the current requirement’s goals, understanding, or plan based on my next feedback; read and follow `skills/using-sandtable/SKILL.md`.

Execute:
1. Read this requirement’s `prd.md`, `tests.md`, `plan.md`, `state.md`, and `journal.md` first so you understand the current state.
2. Based on my feedback, decide which layer needs to change:
   - Change **idea / scope / objective** -> load `writing-prd` and update `prd.md` (go back to `gathering-intel` first if more intel is required).
   - Change **test cases** -> load `writing-tests` and update `tests.md`.
   - Change **plan / tasks / implementation path** -> load `writing-plan` and update `plan.md`.
3. If my feedback contains uncertainty or a decision point: do not guess. Use `being-truthful` to inspect code / docs or write the issue into `questions.md` and ask me.
4. The changes must be **surgical**: change only what I explicitly pointed out and the parts directly tied to it; do not casually rewrite unrelated content.
5. Append an "adjustment record" to `journal.md` (what changed, why, and on what basis), and update `state.md` (if rehearsals already ran, invalidate the relevant counts so they must be rerun).
6. Summarize the changes back to me and wait for confirmation or more feedback.

This command may be triggered repeatedly until I say "leave it like this." After major changes, remember to rehearse again.

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
