---
description: Red-team wargame (OPFOR) - dispatch hostile subagents to attack the current plan or implementation and find reproducible ways it fails.
---

Launch a red-team attack for the current requirement; read and follow `skills/red-team-wargame/SKILL.md`.

Execute:
1. Ask me (or infer from state) whether this round attacks the **plan** or the **implementation**. Read the relevant material: `plan.md` or the diff / branch from an implementation rehearsal, plus the acceptance criteria in `prd.md` and the red lines in `constraints.md`.
2. Use `opfor-prompt.md` to assign attack vectors to each red-team subagent (counterexample, boundary assault, assumption decapitation, flank attack, red-line infiltration, regression ambush, scope creep, requirement drift) and attack in parallel. Every successful strike must be reproducible.
3. Collect the battle reports:
   - If there is `BREACH_FOUND` -> **personally verify whether the strike is real** -> if it is, record it as an ANOMALY -> ask me / fix the PRD, test cases, or plan -> rehearse again.
   - If all return `HELD` -> record why each vector failed to break the plan as evidence of confidence.
4. Write the round to `rehearsals/redteam-<n>.md`, append to `journal.md`, and update `state.md` (red-team counts).

Iron law: let the red team attack brutally; vague "there may be risk" does not count, only reproducible strikes do; the main agent trusts neither red nor blue without checking.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## Issue Grading and Restraint (P0–P3)

- Grade each strike by the `using-sandtable` P0–P3 rubric (trigger probability × functional impact × recoverability × user perception).
- Only **P0/P1** (core damage · redline violation · hard to self-recover, or unlikely but severe) become `BREACH_FOUND` driving the loop; **P2/P3** (edge, retryable/auto-recoverable, basically no perception) are residual risk listed with `HELD` for me to decide.
- Many P0/P1 in one round → suspect the design itself, go back to PLAN/OBJECTIVES, don't plug holes one by one.
- Explain to me in plain language: what was attacked, how many broke, at what grades, real user impact, recommendation.
- OPFOR must not help the design, nor invent impossible-trigger or unrelated attack surfaces; attack only real, relevant, reproducible breaks affecting acceptance / redlines / closure.

## PRD Confirmation Gate

- If `prd.md` exists without traceable developer confirmation, do not dispatch OPFOR. If the same message confirms the PRD, persist the confirmation evidence to `state.md` or `journal.md` before or while dispatching.
