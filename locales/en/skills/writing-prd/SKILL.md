---
name: writing-prd
description: Use after the request is clarified and before writing test cases and the plan, to capture goals, requirements, acceptance criteria, and MUST / MUST-NOT red lines for a feature. Produces docs/sandtable/features/<id>/prd.md.
---

# Writing the PRD · Goals, Requirements, Acceptance, Red Lines

The PRD is the factual foundation of the requirement. It answers: **why are we doing this, what counts as success, what absolutely must happen, and what absolutely must not happen.** Implementation detail belongs in the plan, not here.

**State this when you begin:** "I am using writing-prd to solidify the requirement into a PRD."

## HARD GATE

<HARD-GATE>
You must perform reconnaissance (`gathering-intel`) before writing the PRD. Any unclear or missing requirement point must be resolved through `being-truthful`; do not invent requirements inside the PRD. After the PRD is written, the developer must confirm it before you move to TESTCASES.
</HARD-GATE>

## Flow

```dot
digraph prd {
  "Read project.md + constraints.md" [shape=box];
  "Clarify intent one question at a time" [shape=box];
  "Present 2-3 options + recommendation" [shape=box];
  "Write PRD sections" [shape=box];
  "Self-check: placeholders / contradictions / ambiguity / scope" [shape=box];
  "Developer confirmed?" [shape=diamond];
  "Enter writing-tests" [shape=doublecircle];

  "Read project.md + constraints.md" -> "Clarify intent one question at a time" -> "Present 2-3 options + recommendation" -> "Write PRD sections" -> "Self-check: placeholders / contradictions / ambiguity / scope" -> "Developer confirmed?";
  "Developer confirmed?" -> "Write PRD sections" [label="Needs changes"];
  "Developer confirmed?" -> "Enter writing-tests" [label="Approved"];
}
```

## Required PRD Sections

1. **Goal**: one sentence that states what the requirement achieves for the user and how it relates to `project.md`.
2. **Background and current state**: factual context about relevant modules / code, with `file:line`.
3. **User stories / scenarios**: who is doing what, in which scenario, and why.
4. **Functional requirements**: numbered, traceable items, each with a source.
5. **Acceptance criteria (abstract success definition)**: keep this section abstract; concrete rehearsal-ready scenarios belong in `tests.md`.
6. **MUST**: hard requirements.
7. **MUST NOT**: boundaries and red lines, including no fallback logic and no side quests; inherit `constraints.md`.
8. **Non-goals / out of scope**: explicitly cut items (YAGNI).
9. **Open questions**: point to `questions.md`.

## Option Exploration

Before locking the requirements, present **2-3 different approaches**, list the tradeoffs, and recommend one with reasons. Do not silently choose.

## Self-Check

| Check | Fix |
|------|------|
| Placeholders (`TBD`, "later", "probably") | Clarify first or move to `questions.md` |
| Internal contradiction | Rewrite until consistent |
| Ambiguous wording | Choose a clear interpretation and write it explicitly, or ask |
| Scope too large | Split into multiple requirements |
| Acceptance not verifiable | Rewrite as measurable conditions |

## Red Flags

| Thought | Reality |
|------|------|
| "The requirement is obvious; I can write the plan directly." | Without a PRD and acceptance criteria, rehearsals cannot judge correctness. |
| "I’ll fill missing PRD details with common sense." | Missing requirements must be asked, not invented. |
| "MUST NOT is optional." | Without red lines, rehearsals cannot detect scope violations. |

After the PRD is confirmed, update `state.md` to `phase=TESTCASES` and load `writing-tests`.
