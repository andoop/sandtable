---
description: Commander’s intent - define what success is, what MUST happen, what MUST NOT happen, the red lines, and the acceptance criteria based on recon.
---

Define the mission objectives for the current requirement based on the existing intel; read and follow `skills/writing-prd/SKILL.md`.

Execute:
1. Read the intel brief in this requirement’s `journal.md`, the north star in `project.md`, and the global red lines in `constraints.md`. If the intel is insufficient, tell me to run `/sandtable-recon` first.
2. Ask one question at a time to align on intent and success criteria (do not guess; ask when something is missing; do not invent requirements).
3. Write or update `prd.md`, focusing on:
   - **Goal** (and how it relates to the north star)
   - **MUST**: what this requirement absolutely needs
   - **MUST NOT**: what is absolutely forbidden, including no unrequested fallback logic and no side quests; inherit the global red lines
   - **Acceptance criteria**: verifiable and testable
4. Self-check for placeholders, contradictions, ambiguity, and scope, then ask me to confirm.
5. After confirmation, update `state.md` (`phase=TESTCASES`), load `writing-tests`, produce `tests.md`, and tell me I can iterate on the cases with `/sandtable-refine`.

The objective must be verifiable. Missing red lines prevent later rehearsals from recognizing when the plan crosses the boundary, so write them completely.
