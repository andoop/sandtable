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

When needed, read the full contents of `skills/<name>/SKILL.md`: `using-sandtable`, `being-truthful`, `state-and-memory`, `gathering-intel`, `writing-prd`, `writing-tests`, `writing-plan`, `autonomous-orchestration`, `mental-rehearsal`, `red-team-wargame`, `implementation-rehearsal`, `evaluating-rehearsals`, `closing-the-loop`, `triaging-feedback`, `bugfix-with-evidence`.

## Close the Loop (FR8)

Load `closing-the-loop` only when a **Sandtable work step** ends. **Do not** close for non-Sandtable tasks, even if `docs/sandtable/` was read.

## Slash Commands

`/sandtable-start` (first five steps), `/sandtable-autopilot` (advance from raw request through debrief unattended), `/sandtable-recon` (reconnaissance), `/sandtable-objectives` (goals and red lines), `/sandtable-plan` (plan), `/sandtable-refine` (iterate and revise), `/sandtable-mental` (mental rehearsal), `/sandtable-redteam` (red-team attack), `/sandtable-live` (implementation rehearsal), `/sandtable-debrief` (score and choose), `/sandtable-rehearse` (run rehearsals plus debrief only), `/sandtable-bug` (intake acceptance feedback), `/sandtable-bugfix` (evidence-driven root-cause fix), `/sandtable-status` (status report), `/sandtable-resume` (resume from disk state).

## Feature Addendum: Real-Issue Mental Rehearsal

- Mental rehearsal is for real issues that affect PRD/plan/code-reality closure, acceptance, implementation feasibility, or key decisions.
- Do not manufacture `ANOMALY_FOUND` from unrelated edge cases, impossible triggers, or scenarios that cannot affect acceptance.
- The truthfulness rule still applies: do not continue with key unknowns. Irrelevant side questions become residual risk, not anomaly.
- If `prd.md` exists without traceable developer confirmation, do not dispatch mental subagents. If the same message confirms the PRD, persist the confirmation evidence to `state.md` or `journal.md` before or while dispatching.

## Feature Addendum: Real Reproducible Breaches

- OPFOR must not help the design, but it also must not invent impossible or unrelated attack surfaces just to win.
- Return `BREACH_FOUND` only for real, relevant, reproducible breaks against PRD acceptance, MUST/MUST-NOT, plan, or implementation behavior.
- Vague risk, speculation, missing trigger steps, or unrelated scenarios are residual risk, not breach.
- If `prd.md` exists without traceable developer confirmation, do not dispatch OPFOR. If the same message confirms the PRD, persist the confirmation evidence before or while dispatching.
