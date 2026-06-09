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

## Feature Addendum: Real Reproducible Breaches

- OPFOR must not help the design, but it also must not invent impossible or unrelated attack surfaces just to win.
- Return `BREACH_FOUND` only for real, relevant, reproducible breaks against PRD acceptance, MUST/MUST-NOT, plan, or implementation behavior.
- Vague risk, speculation, missing trigger steps, or unrelated scenarios are residual risk, not breach.
- If `prd.md` exists without traceable developer confirmation, do not dispatch OPFOR. If the same message confirms the PRD, persist the confirmation evidence before or while dispatching.
