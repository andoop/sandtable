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

## PRD Confirmation Gate and Executing Already-Selected Paths

**Before this action, you must fully read and follow every rule in `skills/_shared/prd-gate.md` (PRD confirmation gate and already-selected paths); do not skip or paraphrase from memory.**
