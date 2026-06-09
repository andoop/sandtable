---
name: implementation-rehearsal
description: Use after mental rehearsal is clean, to fully implement the plan as real code inside isolated git worktrees via parallel subagents, with no omitted details, before choosing an approach.
---

# Implementation Rehearsal · Real Code in Isolated Worktrees

**Core idea: actually build and verify the full code according to the plan and PRD, with no missing details.** Mental rehearsal proves the logic is plausible; implementation rehearsal proves the code can truly be built and behaves correctly. This is a trial implementation in an isolated workspace before selecting the best one.

**State this when you begin:** "I am using implementation-rehearsal for implementation rehearsal."

## Why Isolated Worktrees + Parallel Subagents

- Implementation rehearsal changes real code. Multiple rehearsals in one worktree would overwrite and contaminate each other.
- Each implementation-rehearsal subagent works in its **own git worktree / branch**.
- Multiple rehearsals may run in parallel and then be compared, matching the best-of-N selection model.

## Two Iron Laws

1. **If the subagent finds anything that diverges from the plan, is unexpected, or was previously unnoticed, stop immediately and return `ANOMALY_FOUND`. Do not fix the plan yourself and continue.**
2. **Implement completely, with no missing detail**: no TODOs, placeholders, or "fill this later." Either finish and verify (`DONE`), report an anomaly (`ANOMALY_FOUND`), or report a real blocker (`BLOCKED`).

## Main-Agent Role

Create one isolated worktree / branch per rehearsal, dispatch implementation subagents with `implementation-rehearsal-prompt.md`, collect `DONE / ANOMALY / BLOCKED`, verify any anomaly personally, fix docs / plan when needed, and only after all implementations are `DONE` and the completeness gate has passed proceed to `evaluating-rehearsals`.

The main agent does not trust `DONE` blindly. Collect the diff and test results, then run the completeness gate against the coverage matrix, live TODO table, independently recomputed baseline, and real diff / changed-file list. Score/evaluate only after the gate passes.

Each round writes `rehearsals/impl-<n>-<branch>.md` and a journal entry.

## Example Worktree Creation

```bash
git worktree add ../<repo>-rehearsal-1 -b sandtable/rehearse/<feature>-1
git worktree add ../<repo>-rehearsal-2 -b sandtable/rehearse/<feature>-2
```

Point each subagent at its own worktree. Clean up unselected worktrees / branches after the choice.

## Status Handling

| Status | Main-agent action |
|------|------|
| `DONE` | collect diff + test results, run the completeness gate, and score/evaluate only after the coverage matrix, live TODO table, independently recomputed baseline, and real diff / changed-file-list checks all pass |
| `ANOMALY_FOUND` | verify personally -> ask developer if needed -> fix plan -> rehearse again |
| `BLOCKED` | assess the blocker: gather missing context, split the task, or return to PLAN if the plan itself is wrong |

## Red Flags

| Thought | Reality |
|------|------|
| "The plan is slightly wrong; I’ll adjust it during implementation and keep going." | Stop and report an anomaly. Plan changes belong to the main agent plus developer. |
| "Trying it in the main workspace is faster." | That contaminates the real tree. Use isolated worktrees. |
| "A TODO is fine for rehearsal." | No. Implementation rehearsal must be complete. |
| "The subagent said DONE, so I can merge it." | Run the completeness gate first; score/evaluate only after the matrix, TODO table, independent baseline, and real diff checks pass. |
| "I’ll optimize nearby code while I’m here." | Surgical changes only. Scope creep is an anomaly. |

Dispatch template: `./implementation-rehearsal-prompt.md`. After all implementations are `DONE` and the completeness gate passes, load `evaluating-rehearsals`.

## Feature Addendum: Implementation Completeness Gate

`DONE` is only the candidate's self-report. Do not enter `evaluating-rehearsals`, debrief, or EVALUATE until the completeness gate passes. After all candidates report `DONE`, the main agent must run the gate itself for simple candidates or may dispatch read-only mental/redteam-style reviewers for complex or high-risk candidates.

The gate must include:
- The main agent independently reads the current `prd.md`, `tests.md`, and `plan.md` and recomputes the structured verification baseline. Candidate-embedded baselines, coverage matrices, or TODO tables are inputs, not facts.
- Stable keys: `FRx` from PRD numbering; `PRD-AC1...n` from top-level bullets in the PRD acceptance criteria section; `MUST-1...n` and `MNOT-1...n` from top-level MUST / MUST NOT bullets; `TCx` from tests; `PLAN Tx/step x` from every checkbox in `plan.md`, preserving decimal step numbers.
- Body hash: normalize each item as UTF-8 text, LF newlines, trim trailing whitespace, preserve internal order and indentation semantics, then compute SHA-256. Any added, removed, renamed, changed, or missing-hash FR/PRD-AC/MUST/MNOT/TC/PLAN checkbox changes the baseline.
- The gate conclusion records review time, candidate worktree/branch, the current three-document structured baseline, and a real diff or changed-file-list summary. Do not use impl report mtime, coarse prose summaries, or id sets alone for staleness.
- Check the coverage matrix and live execution TODO table against the real diff / changed file list. Empty diff, missing planned file families, no main-agent diff check, omitted keys, aggregate keys, unsupported `not-applicable`, `missing`, or `blocked` all fail the gate.

Each candidate `DONE` report must include:
- Coverage matrix: PRD `FRx`, PRD acceptance `PRD-ACx`, PRD redlines `MUST-x/MNOT-x`, TESTS `TCx`, and PLAN `Tx/step x`, each with status and evidence. Do not replace checkbox-level PLAN coverage with task-level summaries.
- Live execution TODO table with `item` / `source` / `status` / `evidence`; items use `PRD FRx`, `PRD-ACx`, `MUST-x`, `MNOT-x`, `TCx`, or `PLAN Tx/step x`; status is only `done`, `not-applicable`, `blocked`, or `missing`. This table lives inside the candidate report only; it does not create a separate TODO file or replace `plan.md` / `state.md`.
- The matrix and TODO table must have matching PRD FR, PRD-AC, MUST/MNOT, TC, and PLAN step key sets. Conflicts use the finer-grained `missing` / `blocked` result.
