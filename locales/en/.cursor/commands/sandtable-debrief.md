---
description: After-action review - when all implementation rehearsals succeeded, score them with an objective rubric and choose the strongest one to integrate.
---

Debrief and score the implementation rehearsal results for the current requirement; read and follow `skills/evaluating-rehearsals/SKILL.md`.

Execute:
1. Gate check: only score this round if **every** implementation rehearsal is `DONE`. If any run is `ANOMALY` / `BLOCKED`, do not score; go back into the fix loop (fix the plan -> rehearse again).
2. The main agent must **personally read the real diff from every rehearsal**, not just trust self-reports.
3. Score each option with the rubric (requirements fit x3, evidence of correctness x3, minimalism x2, surgical scope x2, readability x1, fit with project conventions x1; red-line compliance is a veto).
4. Choose the highest score; if scores are close, prefer the simpler option with the smaller change set.
5. Write the chosen implementation into `state.md` as `selected_impl`, set `phase=INTEGRATE`, record the scores and rationale in `journal.md`, and clean up unselected worktrees / branches.
6. Give me a brief comparison (total score per option, key differences, and why X won), then wait for confirmation before integration. User instruction may override the choice.
