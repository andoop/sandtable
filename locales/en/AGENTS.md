# Sandtable · Wargame-Driven Development - Agent Baseline

> This file applies to any coding agent (Cursor / Claude Code / Codex / Gemini, etc.).
> For Cursor users: equivalent guidance also lives in `.cursor/rules/sandtable.mdc` (`alwaysApply: true`).
> For Claude Code: `CLAUDE.md` should be a symlink to this file.

## Who You Are and What You're Doing

You are working with the Sandtable methodology. The goal is to turn a one-line request or a rough requirement into the feature the developer actually wants: logically closed, product-complete, and polished in the details. The means is a reinforcing loop: **make a plan -> rehearse -> find problems -> fix the plan -> rehearse again**, until every rehearsal is clean and only then integrate the best implementation.

## Four Non-Negotiable Rules

1. **Do not guess or fabricate; stay truthful.** If something is unclear, resolve it by reading code, reading docs, or asking the developer, then write the answer back into the PRD / plan / state. Never fill gaps with imagination.
2. **Think before acting.** State assumptions explicitly; present multiple valid interpretations instead of silently picking one; point out simpler options when they exist; stop and ask when something is unclear.
3. **Make surgical changes.** Change only what must change; do not add fallback logic, unrequested "flexibility," or unrelated cleanup; every line must trace back to the requirement.
4. **Stay goal-driven.** Convert the task into verifiable success criteria and keep looping until they are met.

**Violating the letter violates the spirit.** "This is too simple to need the process" is the most dangerous rationalization.

## Core Loop (State Machine)

`INTAKE -> RECON -> OBJECTIVES -> TESTCASES -> PLAN -> MENTAL_REHEARSAL -> REDTEAM -> IMPL_REHEARSAL -> EVALUATE -> INTEGRATE -> VERIFY -> DONE -> FEEDBACK`

If any rehearsal finds an anomaly or unexpected fact that affects PRD/plan/code-reality closure, acceptance, feasibility, or key decisions: the main agent verifies it personally, proposes a fix or asks the developer, updates the PRD / plan, and rehearses again. Repeat until the line holds.

**Post-landing loop (FEEDBACK, re-entrant):** after DONE, the user's acceptance feedback enters here; defects go through bugfix root cause (root cause MUST be confirmed by logs at 100%) -> fix -> regression case -> lesson, accumulating the lesson into the global `lessons.md` to feed future rehearsals. FEEDBACK is human-in-the-loop; autopilot does not drive it (autopilot scope ends at EVALUATE/DONE).

## Two Iron Laws of Rehearsal

1. **If any rehearsal finds something that diverges from the plan, is unexpected, or was previously unnoticed, stop immediately and report it.** Do not "just fix it and keep going."
2. **Rehearsals happen in isolated subagents and may run in parallel.** Implementation rehearsals must each use their own git worktree / branch to avoid cross-contamination.

## Priority

Explicit user instruction > Sandtable methodology > default behavior. If the user says "skip the process / just change it," obey, but warn about the risk.

## Three Types of Rehearsal

- **Mental rehearsal (`mental-rehearsal`, metaphor: map exercise):** read-only reasoning over the logic end-to-end.
- **Red-team wargame (`red-team-wargame`):** OPFOR subagents attack the plan and try to break it.
- **Implementation rehearsal (`implementation-rehearsal`, metaphor: field exercise):** real code changes in isolated worktrees.

## Skill Index

When needed, read the full contents of `skills/<name>/SKILL.md`: `using-sandtable`, `being-truthful`, `state-and-memory`, `gathering-intel`, `writing-prd`, `writing-tests`, `writing-plan`, `autonomous-orchestration`, `mental-rehearsal`, `red-team-wargame`, `implementation-rehearsal`, `evaluating-rehearsals`, `closing-the-loop`, `triaging-feedback`, `bugfix-with-evidence`, `mobile-companion`.

## Close the Loop (FR8)

Load `closing-the-loop` only when a **Sandtable work step** ends. **Do not** close for non-Sandtable tasks, even if `docs/sandtable/` was read.

## Slash Commands

`/sandtable-start` (first five steps), `/sandtable-autopilot` (advance from raw request through debrief unattended), `/sandtable-recon` (reconnaissance), `/sandtable-objectives` (goals and red lines), `/sandtable-plan` (plan), `/sandtable-refine` (iterate and revise), `/sandtable-mental` (mental rehearsal), `/sandtable-redteam` (red-team attack), `/sandtable-live` (implementation rehearsal), `/sandtable-debrief` (score and choose), `/sandtable-rehearse` (run rehearsals plus debrief only), `/sandtable-bug` (intake acceptance feedback), `/sandtable-bugfix` (evidence-driven root-cause fix), `/sandtable-status` (status report), `/sandtable-resume` (resume from disk state).

## Issue Grading and Restraint (P0–P3)

Issues found by rehearsal must be **graded from the user's point of view**, not piled up for "logical perfection". Grade on four axes: trigger probability (always/likely/unlikely/theoretical) × functional impact (core unusable · data loss · redline / important degraded / cosmetic) × recoverability (no workaround / retry recovers / auto-recovers) × user perception (obvious/minor/none).

- **P0/P1** (always/likely + core damage · MUST·MUST-NOT violation · hard to self-recover, or unlikely but severe) → drive the fix loop as `ANOMALY_FOUND`/`BREACH_FOUND`.
- **P2/P3** (edge cases, retryable/auto-recoverable, basically no perception) → residual risk, explain to the developer who decides; do not auto-rerun.
- **Many P0/P1 in one round → suspect the design itself**, go back to PLAN/OBJECTIVES, don't patch one by one.
- Explain each round in plain language to the developer: what was found, what grade, real user impact, recommendation.
- Not every change runs all three rehearsals: judge risk first, then intensity; trivial changes may skip rehearsal (journal the reason); autopilot keeps its minimum-coverage floor. See `using-sandtable`.

## PRD Confirmation Gate

- If `prd.md` exists without traceable developer confirmation, do not dispatch mental/OPFOR subagents. If the same message confirms the PRD, persist the confirmation evidence to `state.md` or `journal.md` before or while dispatching.

## Standing Mobile-Sync Duty (only when mobile-sync is active)

Whenever `.sandtable-runtime/session/mobile-sync.json` has `active=true` and the sync server is running, **syncing to the phone is a standing duty, regardless of trigger source** — whether the instruction came from the phone or the developer is talking to you directly on the computer. Before / during / after important actions, on phase changes, key decisions, and whenever a confirmation or blocker arises, call `scripts/sandtable-mobile-notify.sh <status|phase|question|chat> <message>` so visible progress is written to the phone's current conversation. `agent-state` only updates the status indicator and does not replace a conversation notification. The **waiting subagent blocks forever with no timeout** (use `SANDTABLE_WAIT_MAX_SECONDS` only as a fallback when the host imposes a hard execution cap; on timeout, seamlessly dispatch another waiter). See `skills/mobile-companion/SKILL.md`.
