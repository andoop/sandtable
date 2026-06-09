---
name: closing-the-loop
description: Use at the end of every Sandtable work turn to report status, offer copy-paste next-message templates, and invoke AskQuestion in manual mode. In autopilot, auto-continue without asking.
---

# Close the Loop · Make the Sandtable Visible

**Declare at start:** "I'm using closing-the-loop to close this turn."

<HARD-GATE>
1. **Positive trigger**: This turn is a Sandtable work step and a phase action finished or needs confirmation/next step → must close (see profile).
2. **Negative trigger · third state**: This turn is **not** a Sandtable work step → **no** close (even if `docs/sandtable/` was read, TC8b).
3. **Negative trigger**: Unrelated to Sandtable → **no** close (whether or not `docs/sandtable/` was touched).
4. `autonomy.mode=manual` and ≥2 valid next steps → **must** use AskQuestion when available.
5. `autonomy.mode=autopilot` and `blocked=false` → **no** AskQuestion "continue?"; resume in same command. `blocked=true` → full close + AskQuestion (FR5 wins).
6. Read active feature `state.md` when applicable; **do not** read disk to trigger close for typo-only tasks.
</HARD-GATE>

## Two close profiles

| profile | When | Structure |
|---------|------|-----------|
| **Full close** | manual; command boundary; blocked; PRD pending confirm | Status / recommend / copy-paste / other paths |
| **Status bulletin** | autopilot non-blocked phase switch; rehearse/autopilot chain mid-step | Status + `autonomy.last_decision` + "auto-resumed to \<phase\>"; omit AskQuestion and full templates |

## Full close block

### 🧭 Status
- feature: `<id>`
- phase: `<PHASE>` · blocked: `<true|false>` · mode: `<manual|autopilot>`

### ➡️ Recommended next
(one line, from phase table)

### 📋 Copy and send
```text
(full next user message with slash + context)
```

### 🔀 Other paths (optional)
```text
(alternate templates)
```

## Feature Addendum: Execute Already-Selected Paths and Persist PRD Evidence

- Priority: real blockers (`blocked=true`, missing product intent, permission, login, external resource, or key fact) come first and require `questions.md`, `blocked=true`, and a question; the PRD confirmation gate comes next; only then execute the user's selected path.
- If the user already selected the next step via AskQuestion or clearly wrote “confirm and continue / continue with X / choose X”, and there is no real blocker, the agent must execute that step in the same turn. Do not ask again and do not merely print the same copy-paste command.
- If the selection confirms the PRD, persist traceable PRD confirmation evidence to `state.md` or `journal.md` before or while entering TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief. AskQuestion evidence records answer id or `source: askquestion:<id>` plus option text and confirmation time; natural-language evidence records quoted user text, confirmation time, and user-message source.
- `/sandtable-start` still stops after writing an unconfirmed PRD. But if AskQuestion or natural language in the same turn already confirms the PRD and asks to continue, persist the evidence and continue directly to TESTCASES; the old command boundary must not override an already selected path.
- `/sandtable-objectives`, `/sandtable-refine`, and `/sandtable-resume` receiving “PRD confirmed, continue to tests.md” must record the natural-language evidence and load `writing-tests` directly. With `phase=OBJECTIVES` and an existing `prd.md`, do not re-enter `writing-prd`.
- `/sandtable-plan`, `writing-tests`, and `writing-plan` must check PRD confirmation first. If the same message confirms the PRD and triggers tests/plan writing, persist evidence before or while writing. Missing `tests.md` with confirmed PRD goes back to TESTCASES; unconfirmed PRD stops at confirmation.
- Refining the PRD still edits the PRD. Refining tests/plan or continuing to rehearsal requires PRD confirmation first. If `blocked=true` and the user also says continue, blocker wins.
- Full closeout has two profiles: if no path is selected, include recommendation and copy-paste templates; if a path was selected and executed, report result, current phase, and next recommendation only. Any template must point to the next stage, not repeat the already executed selection.
