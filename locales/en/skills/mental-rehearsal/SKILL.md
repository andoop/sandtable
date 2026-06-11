---
name: mental-rehearsal
description: Use after a plan exists and before writing real code, to reason through the full logic end-to-end via read-only subagents over code and docs, surfacing holes and side effects without changing anything.
---

# Mental Rehearsal · Read-Only Logical Walkthrough

**Core idea: without writing a single line of code, walk the entire logic chain from start to finish and verify that it closes, flows, and does not create holes or unexpected impact.** It is cheaper to expose problems with thought than with implementation.

**State this when you begin:** "I am using mental-rehearsal for mental rehearsal."

## What It Does / Does Not Do

- **Does**: read the plan, PRD, code, and docs; trace the real call path, data flow, control flow, state transitions, boundary conditions, and error paths; check MUST / MUST-NOT compliance.
- **Does not**: modify code, create files, or run commands with side effects.
- **No compromise, no fallback, no side quests**: if the plan misses something, do not invent a fallback. That is an ANOMALY to report.

## Two Iron Laws

1. **The moment you find anything that diverges from the plan, is unexpected, or was previously unnoticed, stop and return `ANOMALY_FOUND`.**
2. **Mental rehearsal runs in isolated subagents and may be parallelized.**

## What the Main Agent Does

Prepare the right context for each key logic chain, dispatch read-only subagents with `mental-rehearsal-prompt.md`, collect results, verify anomalies personally, fix docs when needed, and rerun until every chain returns `LOGIC_CLOSED`.

The main agent must not trust a "logic closed" report blindly; spot-check the reasoning and citations. Each round writes `rehearsals/mental-<n>.md` and a journal entry.

## Required Subagent Return Format

- `LOGIC_CLOSED` - include the end-to-end chain with `file:line`, the checked boundary / error paths, the MUST / MUST-NOT conclusions, and any residual risk (P2/P3).
- `ANOMALY_FOUND` - include the exact deviation, where it appears in the plan / code, why it is a problem, the impact, the **grade (P0–P3, per the `using-sandtable` grading rubric)**, and what clarification is needed. **Only P0/P1 return `ANOMALY_FOUND` and drive the loop; P2/P3 are listed as residual risk alongside `LOGIC_CLOSED`.**
- The dispatch template is `./mental-rehearsal-prompt.md`.

## Red Flags

| Thought | Reality |
|------|------|
| "The plan missed a case; I’ll invent a fallback and keep going." | Stop and report an anomaly. |
| "That error path probably never happens." | "Probably" means unverified. Confirm it or report it. |
| "The subagent said it closes, so it’s fine." | Spot-check its citations and reasoning. |
| "One subagent can walk every chain." | Split independent chains for better focus and cross-checking. |
| "Found a pile of issues, report and fix each." | Grade P0–P3 first; only P0/P1 drive the loop, P2/P3 are residual risk. A pile means suspect the design. |

## Issue Grading and Restraint

Grade every finding by the `using-sandtable` **P0–P3 rubric** (trigger probability × functional impact × recoverability × user perception):

- **Only P0/P1** (always/likely + core damage · redline violation · hard to self-recover, or unlikely but severe) become `ANOMALY_FOUND` driving the fix loop.
- **P2/P3** (edge cases, retryable/auto-recoverable, basically no perception) are listed as **residual risk** alongside `LOGIC_CLOSED` for the developer to decide; do not auto-rerun.
- Do not manufacture impossible-trigger or unrelated scenarios for the sake of logical perfection (`being-truthful` no-guessing unchanged: do not continue with key unknowns).
- Many P0/P1 in one round → suspect the **design itself**, go back to PLAN/OBJECTIVES, don't patch one by one.
- Explain in plain language to the developer: what was found, what grade, real user impact, recommendation.

## PRD Confirmation Gate

- If `prd.md` exists without traceable developer confirmation, do not dispatch mental subagents. If the same message confirms the PRD, persist the confirmation evidence to `state.md` or `journal.md` before or while dispatching.
