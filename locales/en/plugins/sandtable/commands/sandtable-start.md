---
description: Start the first five Sandtable steps from a single request: recon -> objectives -> test cases -> plan.
---

Start the Sandtable workflow for the requirement I describe next; read and follow `skills/using-sandtable/SKILL.md`.

Execute this sequence (first-five-steps entry only; use `/sandtable-autopilot` or rehearsal commands for later phases):
1. Load `state-and-memory`, create or confirm `docs/sandtable/`; if `project.md` / `constraints.md` are missing, confirm global goals and red lines first (copy from `templates/`).
2. Create `features/<YYYY-MM-DD>-<slug>/` and `state.md` (phase=`INTAKE`); record the raw request.
3. **RECON**: load `gathering-intel`. [same as `/sandtable-recon`]
4. **OBJECTIVES**: load `writing-prd`. [same as `/sandtable-objectives`]
   - After `prd.md`, load `skills/closing-the-loop/SKILL.md`, output **full close** + AskQuestion/confirm templates.
   - **This command ends here**; do not continue steps 5–6 in the same run. After PRD confirm, resume via user message or `/sandtable-refine`.
5. **TESTCASES** (after PRD confirm): load `writing-tests`, produce `tests.md`.
6. **PLAN** (resume step): load `writing-plan`, write `plan.md`.
7. After PLAN, load `closing-the-loop`, output **full close** (templates for `/sandtable-rehearse`, `/sandtable-autopilot`, `/sandtable-refine`; note `/sandtable-rehearse` = four steps in one).

Strictly follow the four rules. Update `state.md` and `journal.md` each step. Use `/sandtable-refine` if requirements change.

My requirement is:

## PRD Confirmation Gate and Executing Already-Selected Paths

- Priority: real blockers (`blocked=true`, missing product intent, permission, login, external resource, or key fact) come first and require `questions.md`, `blocked=true`, and a question; the PRD confirmation gate comes next; only then execute the user's selected path.
- If the user already selected the next step via AskQuestion or clearly wrote “confirm and continue / continue with X / choose X”, and there is no real blocker, the agent must execute that step in the same turn. Do not ask again and do not merely print the same copy-paste command.
- If the selection confirms the PRD, persist traceable PRD confirmation evidence to `state.md` or `journal.md` before or while entering TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief. AskQuestion evidence records answer id or `source: askquestion:<id>` plus option text and confirmation time; natural-language evidence records quoted user text, confirmation time, and user-message source.
- `/sandtable-start` still stops after writing an unconfirmed PRD. But if AskQuestion or natural language in the same turn already confirms the PRD and asks to continue, persist the evidence and continue directly to TESTCASES; the old command boundary must not override an already selected path.
- `/sandtable-objectives`, `/sandtable-refine`, and `/sandtable-resume` receiving “PRD confirmed, continue to tests.md” must record the natural-language evidence and load `writing-tests` directly. With `phase=OBJECTIVES` and an existing `prd.md`, do not re-enter `writing-prd`.
- `/sandtable-plan`, `writing-tests`, and `writing-plan` must check PRD confirmation first. If the same message confirms the PRD and triggers tests/plan writing, persist evidence before or while writing. Missing `tests.md` with confirmed PRD goes back to TESTCASES; unconfirmed PRD stops at confirmation.
- Refining the PRD still edits the PRD. Refining tests/plan or continuing to rehearsal requires PRD confirmation first. If `blocked=true` and the user also says continue, blocker wins.
- Full closeout has two profiles: if no path is selected, include recommendation and copy-paste templates; if a path was selected and executed, report result, current phase, and next recommendation only. Any template must point to the next stage, not repeat the already executed selection.
