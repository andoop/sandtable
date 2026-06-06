---
name: writing-plan
description: Use when you have an approved PRD and test cases and need a concrete change plan before any code or rehearsal. Maps files to touch and breaks work into small, verifiable, ordered tasks with exact paths, code, and checks.
---

# Writing the Change Plan · Detailed Enough to Rehearse

Write the plan for "a capable engineer who knows nothing about this project, has questionable taste, and dislikes writing tests." Every step needs: **exact file paths, what code to write, and how to verify it.** The more concrete the plan is, the more precisely rehearsals can detect deviation.

**State this when you begin:** "I am using writing-plan to create the change plan."

## Prerequisite Gate

<HARD-GATE>
The plan must be based on confirmed `prd.md` and `tests.md`. It must cover every test case in `tests.md`; verification steps must cite TC numbers and may not invent expectations. Every referenced type / function / interface must either already exist in the project (cite `file:line`) or be defined by some task in this plan. If unsure, go back to `being-truthful`.
</HARD-GATE>

## Step 1: File Map

Before task breakdown, list the files to create or modify and the single responsibility of each. Group things that change together; split by responsibility, not by tech layer.

## Step 2: Small Ordered Tasks

Each task should be self-contained, independently verifiable, and clearly ordered. Each step should be a 2-5 minute action.

## Placeholder Ban

The following are plan defects:
- `TBD` / `later` / "fill in details"
- "handle errors appropriately" without code
- "write tests for the above" without concrete test code
- "same as task N" instead of repeating the actual instructions
- naming work without showing how it will be implemented
- referencing types or functions that exist neither in the repo nor in this plan

## Plan Header

The plan should start with:

```markdown
# <feature name> change plan

**Goal:** one sentence
**Architecture:** 2-3 sentences of approach
**PRD:** prd.md
**Rehearsal requirement:** this plan will be rehearsed task by task by mental-rehearsal and implementation-rehearsal subagents.
```

## Self-Check

| Check | Fix |
|------|------|
| PRD coverage: every requirement mapped to a task? | Add missing tasks |
| tests.md coverage: every TC cited by some task or verification step? | Add the missing task / verification |
| Placeholder scan | Fill everything in |
| Type consistency across tasks | Unify names and signatures |
| Task ordering wrong | Reorder |
| Hidden MUST NOT violation or scope creep | Delete or rewrite |

After the plan is complete, update `state.md` (write the task list, set `phase=MENTAL_REHEARSAL`) and load `mental-rehearsal`.

## Red Flags

| Thought | Reality |
|------|------|
| "I’ll keep the steps vague and improvise during implementation." | A vague plan cannot be rehearsed against. Make it concrete. |
| "I can just say 'handle errors properly'." | Show the actual code or it is a placeholder. |
| "I might as well refactor this nearby code too." | Keep changes surgical. The plan covers only work that serves this requirement. |
