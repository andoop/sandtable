---
description: Start the first five Sandtable steps from a single request: recon -> objectives -> test cases -> plan.
---

Start the Sandtable workflow for the requirement I describe next; read and follow `skills/using-sandtable/SKILL.md`.

Execute this sequence (this is only the first-five-steps entry; use separate commands or `/sandtable-autopilot` for rehearsals and debrief):
1. Load `state-and-memory`, create or confirm the `docs/sandtable/` structure in the target project; if `project.md` / `constraints.md` do not exist, confirm the global goal and red lines with me first (copy from `templates/`).
2. Create `features/<YYYY-MM-DD>-<slug>/` and `state.md` (phase=`INTAKE`) for this requirement, and record the raw request (one sentence or the product doc I give you).
3. **RECON**: load `gathering-intel` and recon the terrain (inspect the codebase, list unknowns, batch questions for me). [same as `/sandtable-recon`]
4. **OBJECTIVES**: load `writing-prd`, define the goals, MUST / MUST-NOT, red lines, and acceptance criteria, then ask me to confirm. [same as `/sandtable-objectives`]
5. **TESTCASES**: load `writing-tests` and produce `tests.md` (calibration targets that verify your understanding). Iterate with `/sandtable-refine` if needed.
6. **PLAN**: load `writing-plan` and write `plan.md`. [same as `/sandtable-plan`]
7. When done, tell me: I can keep refining with `/sandtable-refine`; to continue with rehearsals only, use `/sandtable-mental` -> `/sandtable-redteam` -> `/sandtable-live` -> `/sandtable-debrief` or `/sandtable-rehearse`; if I want unattended progression from request through debrief, use `/sandtable-autopilot`.

Strictly follow the four rules throughout (no guessing, think before acting, surgical changes, goal-driven). Update `state.md` and `journal.md` at every step. If I change the requirement at any point, handle it the `/sandtable-refine` way.

My requirement is:
