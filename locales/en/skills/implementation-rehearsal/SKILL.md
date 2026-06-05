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

Create one isolated worktree / branch per rehearsal, dispatch implementation subagents with `implementation-rehearsal-prompt.md`, collect `DONE / ANOMALY / BLOCKED`, verify any anomaly personally, fix docs / plan when needed, and only when all implementations are `DONE` proceed to `evaluating-rehearsals`.

The main agent does not trust `DONE` blindly. Spot-check the diff, the tests, and whether the implementation quietly added unrequested behavior.

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
| `DONE` | collect diff + test results and move toward scoring |
| `ANOMALY_FOUND` | verify personally -> ask developer if needed -> fix plan -> rehearse again |
| `BLOCKED` | assess the blocker: gather missing context, split the task, or return to PLAN if the plan itself is wrong |

## Red Flags

| Thought | Reality |
|------|------|
| "The plan is slightly wrong; I’ll adjust it during implementation and keep going." | Stop and report an anomaly. Plan changes belong to the main agent plus developer. |
| "Trying it in the main workspace is faster." | That contaminates the real tree. Use isolated worktrees. |
| "A TODO is fine for rehearsal." | No. Implementation rehearsal must be complete. |
| "The subagent said DONE, so I can merge it." | Score it first and verify the real diff before INTEGRATE. |
| "I’ll optimize nearby code while I’m here." | Surgical changes only. Scope creep is an anomaly. |

Dispatch template: `./implementation-rehearsal-prompt.md`. After all implementations are `DONE`, load `evaluating-rehearsals`.
