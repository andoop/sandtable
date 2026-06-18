---
description: Mental rehearsal (map exercise) - read-only subagents reason through the entire logic chain end-to-end, validate closure, and stop immediately on anomalies.
---

Run mental rehearsal for the current requirement; read and follow `skills/mental-rehearsal/SKILL.md`.

Execute:
1. Read this requirement’s `plan.md`, `prd.md`, `tests.md`, `constraints.md`, and `state.md`.
2. Prepare full context for each independent logic chain, and dispatch **read-only** subagents in parallel using `mental-rehearsal-prompt.md`.
3. If any subagent returns `ANOMALY_FOUND` -> verify it personally -> ask me in `questions.md` if needed -> fix `prd.md` / `tests.md` / `plan.md` -> rehearse again.
4. If all return `LOGIC_CLOSED` -> write the report to `rehearsals/mental-<n>.md`, update `state.md` (`mental.last=closed`), and tell me I can proceed to `/sandtable-redteam` or `/sandtable-live`.

Iron law: read-only only; no code changes; stop immediately on anomalies; do not invent fallback behavior; do not trust subagents blindly, spot-check their citations.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## Issue Grading and Restraint (P0–P3)

- Grade by the `skills/_shared/issue-grading.md` P0–P3 rubric (trigger probability × functional impact × recoverability × user perception).
- Only **P0/P1** (core damage · redline violation · hard to self-recover, or unlikely but severe) return `ANOMALY_FOUND` and drive the loop; **P2/P3** (edge, retryable/auto-recoverable, basically no perception) are residual risk listed with `LOGIC_CLOSED` for me to decide.
- Many P0/P1 in one round → suspect the design itself, go back to PLAN/OBJECTIVES, don't patch one by one.
- Explain to me in plain language: what was found, what grade, real user impact, recommendation.
- Do not fabricate impossible-trigger or unrelated scenarios for logical perfection (`being-truthful` no-guessing unchanged: do not continue with key unknowns).

## PRD Confirmation Gate

Full rules in `skills/_shared/prd-gate.md`. In particular: if `prd.md` exists without traceable developer confirmation, do not dispatch mental subagents. If the same message confirms the PRD, persist the confirmation evidence to `state.md` or `journal.md` before or while dispatching.
