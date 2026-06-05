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
