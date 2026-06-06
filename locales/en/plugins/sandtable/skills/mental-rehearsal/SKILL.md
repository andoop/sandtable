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

- `LOGIC_CLOSED` - include the end-to-end chain with `file:line`, the checked boundary / error paths, and the MUST / MUST-NOT conclusions.
- `ANOMALY_FOUND` - include the exact deviation, where it appears in the plan / code, why it is a problem, the impact, and what clarification is needed.
- The dispatch template is `./mental-rehearsal-prompt.md`.

## Red Flags

| Thought | Reality |
|------|------|
| "The plan missed a case; I’ll invent a fallback and keep going." | Stop and report an anomaly. |
| "That error path probably never happens." | "Probably" means unverified. Confirm it or report it. |
| "The subagent said it closes, so it’s fine." | Spot-check its citations and reasoning. |
| "One subagent can walk every chain." | Split independent chains for better focus and cross-checking. |
