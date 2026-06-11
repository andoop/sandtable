---
name: red-team-wargame
description: Use to attack a plan or implementation adversarially before committing to it. Dispatches OPFOR subagents whose mission is to find real, relevant, reproducible breaks in the design and expose reproducible ways it breaks.
---

# Red-Team Wargame · OPFOR

**Military principle: the enemy will find the hole you missed.** A normal review is friendly and often too gentle. Red-team wargaming is adversarial: the red team’s only mission is to **break** the current plan or implementation. Every successful strike becomes an anomaly to feed back into the fix loop.

**State this when you begin:** "I am using red-team-wargame to launch a red-team attack."

## When to Attack

- **Attack the plan**: after mental rehearsal and before implementation rehearsal.
- **Attack the implementation**: after implementation rehearsal is `DONE` and before debrief.
- Use either or both; the riskier or more ambiguous the requirement, the more you should attack.

## Attack Vectors

Assign one or more attack vectors per red-team subagent:
- counterexample
- boundary assault
- assumption decapitation
- flank attack / hidden coupling
- red-line infiltration
- regression ambush
- scope creep
- requirement drift
- lesson review: **if** `docs/sandtable/lessons.md` exists, re-attack along past lessons it records (re-hit previously escaped bugs first)

## Main-Agent Role

Choose whether the round attacks the plan or implementation, dispatch OPFOR subagents with `opfor-prompt.md`, collect reports, personally verify any claimed strike, register real strikes as anomalies, fix docs / plan, and rerun until the blue side holds.

Red-team silence is not proof of safety. Record what was attacked and why it held.

## Adjudication Rules

- A red-team strike must be **reproducible**: concrete inputs / scenario / steps plus expected failure and supporting `file:line`. Vague risk, speculation, impossible triggers, or unrelated scenarios do not count as `BREACH_FOUND`.
- Grade each strike by the `using-sandtable` **P0–P3** rubric (trigger probability × functional impact × recoverability × user perception). **Only P0/P1 become `BREACH_FOUND` driving the fix loop** (a MUST/MUST-NOT violation is P0/P1 by definition); P2/P3 (edge, retryable/auto-recoverable, basically no perception) are **residual risk** listed with `HELD` for the developer to decide.
- The main agent verifies every claimed strike personally; trust neither red nor blue.
- Red-team silence is not proof of safety; record what was attacked and why it held.
- **Many P0/P1 in one round → suspect the design itself**, go back to PLAN/OBJECTIVES instead of plugging holes one by one.
- Each round writes `rehearsals/redteam-<n>.md`, appends to `journal.md`, and increments `rehearsals.redteam`. Explain to the developer in plain language: what was attacked, how many broke, at what grades, the real user impact, and the recommendation.

## Relationship to the Three Rehearsals

Red-team attack is the adversarial member of the trio:
- mental rehearsal asks "does the logic close?"
- red-team asks "can it be broken?"
- implementation rehearsal asks "can it be built correctly?"

Any anomaly flows through the same loop: **verify -> ask developer if needed -> fix -> rehearse again**.

## Red Flags

| Thought | Reality |
|------|------|
| "The red team didn’t find anything major, so we’re good enough." | Change attack vectors and run another round, especially against red-line infiltration or hidden coupling. |
| "The red team says there may be risk, but they did not reproduce it." | That does not count as a breach. |
| "The breach is small; I’ll note it and fix it later." | Grade P0–P3: P0/P1 drive the loop; P2/P3 are residual risk for the developer—don't force-polish. |
| "The blue side says it held, so I can trust that." | The main agent must verify. |
| "A whole pile of breaches, plug each one." | Many P0/P1 → suspect the design, go back to PLAN/OBJECTIVES, don't patch one by one. |

Dispatch template: `./opfor-prompt.md`.

## PRD Confirmation Gate

- If `prd.md` exists without traceable developer confirmation, do not dispatch OPFOR. If the same message confirms the PRD, persist the confirmation evidence to `state.md` or `journal.md` before or while dispatching.
