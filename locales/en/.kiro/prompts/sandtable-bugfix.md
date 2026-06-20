---
description: bugfix mode — start the evidence-driven root-cause loop for a defect: auto-collect logs, instrument, confirm the root cause via logs at 100%, root-cause fix, clean up.
---

Start the bugfix loop for the defect I describe next; read and follow `skills/bugfix-with-evidence/SKILL.md`.

Steps:
1. Reproduce and define expected vs actual; list ≥2 parallel hypotheses (think broad + deep + divergent).
2. **Auto-collect logs first** (if you can adb/read files/capture repro output, don't ask the user); collected artifacts land in a **directory outside the repo / temp dir** (contains secrets, never commit); instrument key points with the project's native logging framework under the unified tag `[SANDTABLE-BUGFIX:<feature-or-bug-id>]`.
3. For non-trivial defects, dispatch ≥3 parallel investigation subagents (centralized collection, read-only subagents; they may take mental/recon/red-team stances, red team falsifies the candidate root cause).
4. Falsify hypotheses one by one until a single root cause is locked — **the root cause MUST be confirmed by log/runtime evidence at 100%; code-reading inference alone does not count**; if logs truly can't be obtained (and it isn't statically determinable), set blocked, write questions.md and ask the developer, never downgrade unilaterally.
5. Root-cause fix (cause not symptom, no surface/temporary fix); verify the repro is gone; clean temp logs by tag.
6. Write the root cause/fix back to `feedback.md` and journal; return to `triaging-feedback` to produce the regression case (into tests.md) + the trio (root cause/prevention/lesson); accumulate the lesson into the global `lessons.md`. Closing requires user-confirmed convergence.
7. When done, load `skills/closing-the-loop/SKILL.md` for the close-out.

The defect I want to investigate is:
