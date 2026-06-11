---
description: Commander’s intent - define what success is, what MUST happen, what MUST NOT happen, the red lines, and the acceptance criteria based on recon.
---

Define the mission objectives for the current requirement based on the existing intel; read and follow `skills/writing-prd/SKILL.md`.

Execute:
1. Read the intel brief in this requirement’s `journal.md`, the north star in `project.md`, and the global red lines in `constraints.md`. If the intel is insufficient, tell me to run `/sandtable-recon` first.
2. Ask one question at a time to align on intent and success criteria (do not guess; ask when something is missing; do not invent requirements).
3. Write or update `prd.md`, focusing on:
   - **Goal** (and how it relates to the north star)
   - **MUST**: what this requirement absolutely needs
   - **MUST NOT**: what is absolutely forbidden, including no unrequested fallback logic and no side quests; inherit the global red lines
   - **Acceptance criteria**: verifiable and testable
4. Self-check for placeholders, contradictions, ambiguity, and scope, then ask me to confirm.
5. After confirmation, update `state.md` (`phase=TESTCASES`), load `writing-tests`, produce `tests.md`, and tell me I can iterate on the cases with `/sandtable-refine`.

The objective must be verifiable. Missing red lines prevent later rehearsals from recognizing when the plan crosses the boundary, so write them completely.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## PRD Confirmation Gate and Executing Already-Selected Paths

- Priority: real blockers (`blocked=true`, missing product intent, permission, login, external resource, or key fact) come first and require `questions.md`, `blocked=true`, and a question; the PRD confirmation gate comes next; only then execute the user's selected path.
- If the user already selected the next step via AskQuestion or clearly wrote “confirm and continue / continue with X / choose X”, and there is no real blocker, the agent must execute that step in the same turn. Do not ask again and do not merely print the same copy-paste command.
- If the selection confirms the PRD, persist traceable PRD confirmation evidence to `state.md` or `journal.md` before or while entering TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief. AskQuestion evidence records answer id or `source: askquestion:<id>` plus option text and confirmation time; natural-language evidence records quoted user text, confirmation time, and user-message source.
- `/sandtable-start` still stops after writing an unconfirmed PRD. But if AskQuestion or natural language in the same turn already confirms the PRD and asks to continue, persist the evidence and continue directly to TESTCASES; the old command boundary must not override an already selected path.
- `/sandtable-objectives`, `/sandtable-refine`, and `/sandtable-resume` receiving “PRD confirmed, continue to tests.md” must record the natural-language evidence and load `writing-tests` directly. With `phase=OBJECTIVES` and an existing `prd.md`, do not re-enter `writing-prd`.
- `/sandtable-plan`, `writing-tests`, and `writing-plan` must check PRD confirmation first. If the same message confirms the PRD and triggers tests/plan writing, persist evidence before or while writing. Missing `tests.md` with confirmed PRD goes back to TESTCASES; unconfirmed PRD stops at confirmation.
- Refining the PRD still edits the PRD. Refining tests/plan or continuing to rehearsal requires PRD confirmation first. If `blocked=true` and the user also says continue, blocker wins.
- Full closeout has two profiles: if no path is selected, include recommendation and copy-paste templates; if a path was selected and executed, report result, current phase, and next recommendation only. Any template must point to the next stage, not repeat the already executed selection.
