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
