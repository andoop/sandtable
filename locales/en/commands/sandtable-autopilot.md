---
description: Advance from request through debrief without manual handoff
---

Run Sandtable in autonomous mode for the current requirement; read and follow `skills/autonomous-orchestration/SKILL.md`.

Execute:
1. This command explicitly enables `<AUTOPILOT-OVERRIDE>` and it applies only to this `/sandtable-autopilot` run; if I later trigger a manual slash command, obey that command's boundary and do not silently keep the override running.
2. Read `docs/sandtable/project.md`, `constraints.md`, and the current requirement; create or resume the feature directory and `state.md` if needed.
3. Write `autonomy.mode=autopilot` into `state.md`, and initialize or refresh `autonomy.min_rounds`, `autonomy.min_agents_per_round`, `autonomy.completed_rounds`, and `autonomy.last_decision`.
4. Complete `RECON -> OBJECTIVES -> TESTCASES -> PLAN` automatically, without waiting for step-by-step confirmation by default.
5. Then continue through the hard quotas:
   - mental rehearsal: at least 3 rounds, with at least 3 read-only subagents per round
   - red-team attack: at least 3 rounds, with at least 3 red-team subagents per round
   - implementation rehearsal: at least 2 rounds, with at least 2 independent worktree subagents per round
6. On any `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED`: verify it personally first, write the result back into `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md`, then rehearse again from the earliest stage that has not been re-validated; only write `questions.md` and ask me if the issue is truly blocked.
7. After all minimum quotas are satisfied, run the debrief automatically, update `selected_impl`, and report the chosen approach, the verification results, and remaining risks.
