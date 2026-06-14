# Issue Grading and Restraint (P0–P3, shared rehearsal verdict)

> Sandtable shared fragment (single source of truth). Commands and skills reference this file; **do not copy the full text elsewhere**. Change the rule only here.

Issues found by rehearsal (mental / red-team) must be **graded from the user's point of view**, not piled up for the sake of "logical perfection". Grade first, then decide whether it drives the fix loop.

Grade along four axes:

- **Trigger probability**: always / likely / unlikely / only theoretical
- **Functional impact**: core unusable · data loss · redline violation / important feature degraded / cosmetic
- **Recoverability**: user cannot work around / user retry recovers / system auto-recovers
- **User perception**: obvious / minor / basically none

| Level | Typical combination | Handling |
|------|---------|------|
| **P0** | Always/likely + core unusable / data loss / MUST·MUST-NOT violation, obvious to user and unrecoverable | Must drive the fix loop as `ANOMALY_FOUND`/`BREACH_FOUND`; blocks integration |
| **P1** | Likely degrades an important feature, or unlikely but severe (data/security/money), perceived and hard to self-recover | Fix in the loop; deferring needs explicit developer consent |
| **P2** | Edge/unlikely, degraded but retryable or auto-recoverable, minor perception | Record as **residual risk**, explain to developer, who decides whether to fix this round |
| **P3** | Only theoretical / pure cosmetic, no/negligible perception | Log for the record, does not drive the loop |

**Verdict iron law: only P0/P1 drive the fix loop; P2/P3 are residual risk for the developer to decide—do not auto-trigger reruns, do not polish endlessly for "logical perfection".** The truthfulness lens still holds: report only real, relevant, reproducible issues that affect acceptance / redlines / closure; do not manufacture `ANOMALY_FOUND`/`BREACH_FOUND` from impossible triggers or unrelated scenarios (`being-truthful`'s no-guessing rule is unchanged: do not continue with key unknowns).

**Restraint and reflection**: if one rehearsal round surfaces **many P0/P1**, first suspect the **design itself** (too complex, boundaries not converged, requirement misread) and go back to PLAN/OBJECTIVES, instead of patching one by one. A pile of issues is usually a design signal, not a patch list.

**Explain to the developer**: each round's conclusion in plain language—what was found, what grade, why it is (or is not) a real issue, the real user impact, and the recommendation. No jargon dumps, no perfection-for-its-own-sake pseudo-issues.
