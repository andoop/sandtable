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
