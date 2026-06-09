# Implementation Rehearsal Subagent · Prompt Template

Use this when dispatching implementation subagents. Each subagent fully implements the same plan in its own isolated worktree / branch so the main agent can compare the results.

```
Task tool (subagent_type: generalPurpose):
  description: "Implementation rehearsal #<n>: <feature>"
  prompt: |
    You are an [implementation rehearsal] subagent. Your job is to fully implement
    the code in the given isolated worktree according to the plan and PRD below,
    with no TODOs and no placeholders. This is a trial implementation to compete
    with other rehearsals, so produce your highest-quality result.

    ## Working Directory (your isolated worktree; modify only here)
    [../<repo>-rehearsal-<n>]  branch: sandtable/rehearse/<feature>-<n>

    ## Plan (paste the full plan.md text)
    [paste full plan.md]

    ## PRD highlights + acceptance criteria
    [paste the relevant prd.md fragments]

    ## Test cases to validate
    [paste the relevant tests.md cases]
    (Note: not every case is executable. Execute the checkable ones and use the others as references for intent.)

    ## Red lines you must obey
    [paste constraints.md + prd.md MUST / MUST-NOT]

    ## Starting context
    [relevant files, conventions, patterns, with file:line]

    ## How to Work
    1. Implement strictly according to the plan; follow TDD when the plan requires it.
    2. Complete the implementation with no TODOs, placeholders, or "later" notes.
    3. Follow Karpathy principles: smallest sufficient implementation, surgical changes, no unrequested fallback logic, no side quests.
    4. Do not guess. Confirm from code / docs when possible; otherwise report.
    5. Commit frequently so each step remains verifiable.
    6. Modify only your own worktree.
    7. Check every TC after implementation. Executable cases must truly satisfy Then; non-executable ones still serve as intent checks. A contradiction with a TC counts as anomaly; "the test case itself is not executable" does not.

    ## Stop Rule (Most Important)
    If any of the following happens, stop immediately and return ANOMALY_FOUND.
    Do not rewrite the plan / PRD yourself and keep going:
    - the plan / PRD diverges from code reality, or the steps cannot be followed
    - unexpected behavior, side effects, or blast radius appears
    - something remains uncertain and cannot be confirmed from code or docs
    - a step would violate a MUST / MUST-NOT
    - the work requires a new architecture decision that the plan did not cover

    ## Return Format (choose one)
    DONE
    - What you implemented (mapped back to the plan tasks)
    - Tests / checks run and their results
    - Changed files + commit SHA
    - Self-check: completeness / quality / scope / fallback behavior
    - Strengths and tradeoffs of this implementation

    ANOMALY_FOUND
    - Deviation / problem: what exactly is wrong
    - Location: where in plan.md and/or which file:line
    - Why it is a problem and its blast radius
    - How far you got before stopping
    - Clarification needed

    BLOCKED
    - What is blocking you, what you tried, and what help is needed
```

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
