---
name: writing-tests
description: Use after the PRD is confirmed and before writing the change plan, to derive concrete, black-box, human-readable test cases that prove whether the AI truly understands the requirement. Produces docs/sandtable/features/<id>/tests.md.
---

# Writing Test Cases · The Gate That Proves the AI Really Understands

Test cases are the **understanding checkpoint** between the PRD and the plan. They turn abstract acceptance criteria into concrete "given -> when -> then" scenarios that a developer can read and immediately judge. They also become the common attack surface for all three rehearsal types.

The key point: test cases are first and foremost the **AI’s concrete expression of the requirement plus the human-readable detail**. They do **not** all need to be executable code. If a case can be made executable or objectively checkable, great. If not, it is still a valid reference for humans and rehearsals.

**State this when you begin:** "I am using writing-tests to turn the requirement into test cases."

## HARD GATE

<HARD-GATE>
1. Test cases must be based on the **confirmed** `prd.md`.
2. **Mapping rule:** every test case must trace back to a functional requirement, acceptance criterion, MUST, or MUST NOT. If you cannot map it, do not write it.
3. Black-box only: use Given / When / Then with concrete input and observable output; keep it stack-agnostic and free of code-level assertions.
If a requirement detail is still uncertain, return to `being-truthful`; do not invent it inside the test case.
</HARD-GATE>

## Responsibilities of the Three Artifacts

| Artifact | Responsibility | Form |
|------|------|------|
| PRD §5 acceptance criteria | Abstract success definition | High-level binary conditions |
| **`tests.md`** | Concrete scenarios that show the AI’s understanding | Black-box Given / When / Then |
| Plan verification steps | Code / command-level validation that cites TC numbers | Implementation-specific checks |

## What a Test Case Looks Like

- **ID + title**: `TC<N> · one-line scenario`
- **Mapping**: the FR / acceptance criterion / MUST / MUST NOT it proves
- **Given**: preconditions / starting state
- **When**: the trigger plus **concrete input**
- **Then**: **concrete observable result** (never "works correctly" or "normal")
- **Status**: pending / verified

Cover the normal path and the important boundary / error paths, but only when each case still maps back to a requirement.

## Self-Check

| Check | Fix |
|------|------|
| A case cannot map back to any FR / acceptance / MUST / MUST NOT | Delete it or fix the PRD first |
| `Then` says only "correct" / "normal" | Replace it with a concrete expected result |
| Code or framework names appear | Rewrite it as black-box behavior |
| Only the happy path exists | Add important boundary / failure cases |
| PRD §5 contains concrete commands or inputs | Move those details here; keep PRD §5 abstract |

## Red Flags

| Thought | Reality |
|------|------|
| "Copying the acceptance criteria is enough." | Acceptance criteria are abstract; this file must turn them into scenarios. |
| "This case doesn’t map to a requirement, but it feels useful." | Then it is probably invented scope. Do not add it. |
| "Writing code assertions here would be more precise." | This file is black-box; code-level validation belongs in the plan. |
| "A case only counts if it can run automatically." | No. Executable is nice, but human-readable understanding checks still count. |
| "This case is not executable, so I should delete it." | No. Mark it as reference / manual verification if needed. |
| "Then can just say 'correct result'." | Without a concrete expectation, it cannot test understanding. |

After the cases are confirmed, update `state.md` (`phase=PLAN`) and load `writing-plan`.
