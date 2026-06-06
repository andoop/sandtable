---
description: Intake one acceptance feedback/bug, record it in feedback.md and triage, entering the FEEDBACK phase (post-landing loop entry).
---

Intake the acceptance feedback I describe next; read and follow `skills/triaging-feedback/SKILL.md`.

Steps:
1. Confirm the current feature (read `docs/sandtable/`). **If the reported code has no matching feature dir**, auto-create a lightweight feature `<date>-bugfix-<slug>` (minimal state.md/feedback.md, reusing init idempotent logic) first. Append the feedback as a BUG entry to that feature's `feedback.md` (use `templates/feedback.md`): lifecycle/repro/expected/actual/severity.
2. Triage into one of three classes (real defect / missing requirement / misread or expected), with sourced conclusions (file:line or PRD item).
3. Real defect → suggest `/sandtable-bugfix` for the root-cause loop; missing requirement → roll back to OBJECTIVES to amend PRD/tests; misread → explain, no change.
4. Update `state.md` (phase=FEEDBACK), append `[feedback]` to journal. FEEDBACK is human-in-the-loop: autopilot doesn't drive it; no close without user-confirmed convergence.
5. When done, load `skills/closing-the-loop/SKILL.md` for the close-out.

The problem I'm reporting is:
