---
description: Run the Sandtable rehearsal chain in order: mental rehearsal -> red-team attack -> implementation rehearsal -> debrief.
---

Run the three rehearsal types plus debrief in sequence for the current requirement; read and follow `skills/using-sandtable/SKILL.md`.

Execute:
1. If the requirement is "go from raw request all the way through debrief unattended," use `/sandtable-autopilot` instead; this command handles only rehearsals and debrief, not the earlier `RECON / OBJECTIVES / TESTCASES / PLAN` stages.
2. Read `docs/sandtable/features/<current-feature>/state.md`, `prd.md`, `tests.md`, `plan.md`, and `constraints.md`, and confirm the current phase.
3. **Mental rehearsal**: load `mental-rehearsal`, dispatch read-only subagents in parallel with `mental-rehearsal-prompt.md`. [same as `/sandtable-mental`]
   - Any `ANOMALY_FOUND` -> verify personally -> ask me in `questions.md` if needed -> fix `prd.md` / `tests.md` / `plan.md` -> rehearse again.
   - All `LOGIC_CLOSED` -> continue.
4. **Red-team wargame**: load `red-team-wargame` and attack the plan with OPFOR subagents. [same as `/sandtable-redteam`]
   - Any verified `BREACH_FOUND` -> record an ANOMALY -> ask me / fix the docs -> return to step 2 and rehearse again.
   - All `HELD` -> continue.
5. **Implementation rehearsal**: load `implementation-rehearsal`, create isolated git worktrees / branches, and dispatch implementation subagents in parallel. [same as `/sandtable-live`]
   - Any `ANOMALY_FOUND` / `BLOCKED` -> verify personally -> ask me -> fix the plan -> return to step 2 and rehearse again.
   - All `DONE` -> continue to debrief.
6. **Debrief and choose**: load `evaluating-rehearsals`, score the implementations, and write the selected one into `state.md`. [same as `/sandtable-debrief`]
7. Write each round into `rehearsals/` and `journal.md`. In-chain phase switches use **status bulletin** only (never omit). On command end / block / anomaly stop, load `closing-the-loop` for **full close** (choice + copy-paste templates).

Two iron laws: stop and report on anomalies immediately, and run rehearsals in isolated subagents. Do not trust subagent conclusions without spot-checking their citations and diffs.

## Feature Addendum: Implementation Completeness Gate

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
