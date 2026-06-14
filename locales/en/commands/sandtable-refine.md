---
description: Revise the deployment - after I review the goals or plan, update, extend, or recreate them until I am satisfied.
---

Refine the current requirement’s goals, understanding, or plan based on my next feedback; read and follow `skills/using-sandtable/SKILL.md`.

Execute:
1. Read this requirement’s `prd.md`, `tests.md`, `plan.md`, `state.md`, and `journal.md` first so you understand the current state.
2. Based on my feedback, decide which layer needs to change:
   - Change **idea / scope / objective** -> load `writing-prd` and update `prd.md` (go back to `gathering-intel` first if more intel is required).
   - Change **test cases** -> load `writing-tests` and update `tests.md`.
   - Change **plan / tasks / implementation path** -> load `writing-plan` and update `plan.md`.
3. If my feedback contains uncertainty or a decision point: do not guess. Use `being-truthful` to inspect code / docs or write the issue into `questions.md` and ask me.
4. The changes must be **surgical**: change only what I explicitly pointed out and the parts directly tied to it; do not casually rewrite unrelated content.
5. Append an "adjustment record" to `journal.md` (what changed, why, and on what basis), and update `state.md` (if rehearsals already ran, invalidate the relevant counts so they must be rerun).
6. Summarize the changes back to me and wait for confirmation or more feedback.

This command may be triggered repeatedly until I say "leave it like this." After major changes, remember to rehearse again.

8. When done, load `skills/closing-the-loop/SKILL.md`, read `state.md`, and output the close block (skip for in-command chain steps; use status bulletin for in-chain switches). Do not run unlisted next phases except `/sandtable-autopilot` and `/sandtable-rehearse`.

## PRD Confirmation Gate and Executing Already-Selected Paths

**Before this action, you must fully read and follow every rule in `skills/_shared/prd-gate.md` (PRD confirmation gate and already-selected paths); do not skip or paraphrase from memory.**
