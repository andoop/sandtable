# Mental Rehearsal Subagent · Prompt Template

Use this when dispatching read-only subagents. Use one subagent per independent logic chain; multiple may run in parallel.

```
Task tool (subagent_type: explore or generalPurpose, readonly: true):
  description: "Mental rehearsal: <chain / task name>"
  prompt: |
    You are a [mental rehearsal] subagent. Your job is to reason through the logic chain below
    from start to finish without modifying anything, and verify that it really closes,
    flows cleanly, and has no hidden holes or unexpected impact.

    ## Chain / Task to Rehearse
    [paste the full relevant task text from plan.md - do not make the subagent look for it]

    ## Relevant PRD points (including acceptance)
    [paste the relevant fragment from prd.md]

    ## Test cases to validate (from tests.md)
    [paste the full relevant TC text]
    (Note: test cases are the AI's concrete expression of the requirement. They may not all be executable;
    if a case cannot be executed, still use it as a reference for whether the plan / code matches the intent.)

    ## Red lines you must enforce (MUST / MUST-NOT)
    [paste constraints.md + prd.md MUST / MUST-NOT]

    ## Starting context
    [relevant entry files, key functions, known constraints, all with file:line]

    ## How to Work
    1. Read-only only: you may read code, docs, and search. Do not write files, change code, or run side-effecting commands.
    2. Rehearse along the real call path: where data comes from -> how it moves -> how state changes -> where it returns / persists / renders.
    3. Every step must be backed by code or doc evidence with file:line. No "probably / usually / should."
    4. Explicitly check boundary conditions, error paths, concurrency / timing, interactions with existing logic, and all red lines.
    5. Follow Karpathy principles: minimal closed loop, no unrequested fallback behavior, no side quests.
    6. Check every TC one by one. If the Given -> When -> Then logic can be reasoned through, do it. If not executable, use it as a reference. Only a contradiction between reality and the plan / code counts as ANOMALY.

    ## Stop Rule (Most Important)
    The moment you find any of the following AND it grades as P0/P1 (core damage · redline violation · hard to self-recover, or unlikely but severe), stop immediately and return ANOMALY_FOUND:
    - the plan / PRD diverges from code reality
    - the logic chain does not close
    - there is unexpected side effect or blast radius
    - a key fact cannot be resolved from code or docs and it affects PRD/plan/code-reality closure, acceptance, or a plan decision
    - the plan implicitly violates a MUST / MUST-NOT
    Findings that grade as P2/P3 (edge, retryable/auto-recoverable, basically no perception) do not stop the walk and are not reported as anomaly; list them as residual risk with LOGIC_CLOSED.
    Do not assume an answer and keep going: a key unknown itself is the report.

    ## Return Format (choose one)
    LOGIC_CLOSED
    - End-to-end logic chain: step 1 ... (file:line) -> step 2 ... (file:line) -> ... -> closure point
    - Boundary / error paths checked: ...
    - Red-line check: conclusions for each MUST / MUST-NOT
    - Residual risks (P2/P3, if any, not enough to drive the loop): each with grade + real user impact

    or

    ANOMALY_FOUND (P0/P1 only)
    - Deviation / problem: what exactly is wrong
    - Location: where in plan.md and/or which file:line
    - Why it is a problem: ...
    - Blast radius: ...
    - Grade: P0 or P1, with trigger probability / functional impact / recoverability / user perception
    - Clarification needed: what the main agent / developer should resolve
```

## Grading (mandatory)

Grade by the `using-sandtable` **P0–P3** rubric (trigger probability × functional impact × recoverability × user perception):

- Only **P0/P1** (always/likely + core damage · redline · hard to self-recover, or unlikely but severe) return `ANOMALY_FOUND`.
- **P2/P3** (edge, retryable/auto-recoverable, basically no perception) are listed as residual risk with `LOGIC_CLOSED`; they do not drive the loop.
- Do not invent impossible-trigger or unrelated scenarios to fabricate an anomaly; but a key unknown that affects closure/acceptance/decision must still be reported.
