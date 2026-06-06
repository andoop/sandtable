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
