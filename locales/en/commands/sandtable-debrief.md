---
description: After-action review - when all implementation rehearsals succeeded, score them with an objective rubric and choose the strongest one to integrate.
---

Debrief and score the implementation rehearsal results for the current requirement; read and follow `skills/evaluating-rehearsals/SKILL.md`.

Execute:
1. Gate check: only score this round if **every** implementation rehearsal is `DONE` and the completeness gate has passed. The gate must check the coverage matrix, live TODO table, independently recomputed baseline, and real diff / changed-file list. If any run is `ANOMALY` / `BLOCKED`, the gate is missing, or the gate fails, do not score; go back into the fix loop (fix the plan -> rehearse again).
2. The main agent must **personally read the real diff from every rehearsal**, not just trust self-reports.
3. Score each option with the rubric (requirements fit x3, evidence of correctness x3, minimalism x2, surgical scope x2, readability x1, fit with project conventions x1; red-line compliance is a veto).
4. Choose the highest score; if scores are close, prefer the simpler option with the smaller change set.
5. Write the chosen implementation into `state.md` as `selected_impl`, set `phase=INTEGRATE`, record the scores and rationale in `journal.md`, and clean up unselected worktrees / branches.
6. Give me a brief comparison (total score per option, key differences, and why X won), then wait for confirmation before integration. User instruction may override the choice.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## Implementation Completeness Gate

`DONE` is only the candidate's self-report. Do not enter `evaluating-rehearsals`, debrief, or EVALUATE until the completeness gate passes. After all candidates report `DONE`, the main agent must run the gate itself for simple candidates or may dispatch read-only mental/redteam-style reviewers for complex or high-risk candidates.

The gate must include:
- The main agent independently reads the current `prd.md`, `tests.md`, and `plan.md` and recomputes the structured verification baseline. Candidate-embedded baselines, coverage matrices, or TODO tables are inputs, not facts.
- Stable keys: `FRx` from PRD numbering; `PRD-AC1...n` from top-level bullets in the PRD acceptance criteria section; `MUST-1...n` and `MNOT-1...n` from top-level MUST / MUST NOT bullets; `TCx` from tests; `PLAN Tx/step x` from every checkbox in `plan.md`, preserving decimal step numbers.
- Body hash: normalize each item as UTF-8 text, LF newlines, trim trailing whitespace, preserve internal order and indentation semantics, then compute SHA-256. Any added, removed, renamed, changed, or missing-hash FR/PRD-AC/MUST/MNOT/TC/PLAN checkbox changes the baseline.
- The gate conclusion records review time, candidate worktree/branch, the current three-document structured baseline, and a real diff or changed-file-list summary. Do not use impl report mtime, coarse prose summaries, or id sets alone for staleness.
- Check the coverage matrix and live execution TODO table against the real diff / changed file list. Empty diff, missing planned file families, no main-agent diff check, omitted keys, aggregate keys, unsupported `not-applicable`, `missing`, or `blocked` all fail the gate.

Each candidate `DONE` report must include:
- Coverage matrix: PRD `FRx`, PRD acceptance `PRD-ACx`, PRD redlines `MUST-x/MNOT-x`, TESTS `TCx`, and PLAN `Tx/step x`, each with status and evidence. Do not replace checkbox-level PLAN coverage with task-level summaries.
- Live execution TODO table with `item` / `source` / `status` / `evidence`; items use `PRD FRx`, `PRD-ACx`, `MUST-x`, `MNOT-x`, `TCx`, or `PLAN Tx/step x`; status is only `done`, `not-applicable`, `blocked`, or `missing`. This table lives inside the candidate report only; it does not create a separate TODO file or replace `plan.md` / `state.md`.
- The matrix and TODO table must have matching PRD FR, PRD-AC, MUST/MNOT, TC, and PLAN step key sets. Conflicts use the finer-grained `missing` / `blocked` result.
