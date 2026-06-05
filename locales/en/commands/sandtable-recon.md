---
description: Reconnaissance - actively gather code and doc intel, map the terrain, list unknowns, and ask the developer proactively instead of guessing.
---

Run reconnaissance for the current requirement; read and follow `skills/gathering-intel/SKILL.md`.

Execute:
1. Read `docs/sandtable/project.md`, `constraints.md`, and the raw record for this requirement.
2. Sweep the terrain systematically: relevant code (cite `file:line`), existing conventions, dependencies and boundaries, relevant history / commits, and risk hotspots. For large reconnaissance, you may dispatch read-only subagents in parallel across subsystems and then synthesize the result.
3. Produce two lists: **confirmed facts (with sources)** and **unknowns / clarifications needed**.
4. For unknowns that can still be self-resolved, keep reading code and docs; for unknowns that cannot, batch them into `questions.md` and ask me once.
5. Write the intel brief into `journal.md`, and update `state.md` (`phase=OBJECTIVES`).

Discipline: do not guess or fabricate; give every fact a source; ask the important questions in one batch rather than drip-feeding or suppressing them.
