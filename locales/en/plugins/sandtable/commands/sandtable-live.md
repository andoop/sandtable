---
description: Implementation rehearsal (field exercise) - fully implement and verify the plan inside isolated git worktrees via parallel subagents; stop immediately on anomalies.
---

Run implementation rehearsal for the current requirement; read and follow `skills/implementation-rehearsal/SKILL.md`.

Execute:
1. Read this requirement’s `plan.md`, `prd.md`, `constraints.md`, and `state.md`; confirm mental rehearsal is already closed (otherwise run `/sandtable-mental` first).
2. Create an **independent git worktree / branch** for each rehearsal, then dispatch implementation subagents in parallel with `implementation-rehearsal-prompt.md`, requiring complete implementation with no TODOs or placeholders.
3. If any run returns `ANOMALY_FOUND` / `BLOCKED` -> verify it personally -> ask me -> fix the plan -> rehearse again.
4. If all return `DONE` -> write reports to `rehearsals/impl-<n>-<branch>.md`, update `state.md` (`impl.last=done`), and tell me I can use `/sandtable-redteam` (against the implementation) or `/sandtable-debrief`.

Iron law: every rehearsal must stay in its own worktree; stop immediately on anomalies instead of editing the plan yourself; no scope creep, no fallback logic; do not trust `DONE` without checking the real diff.
