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

## PRD Confirmation Gate and Executing Already-Selected Paths

**Before this action, you must fully read and follow every rule in `skills/_shared/prd-gate.md` (PRD confirmation gate and already-selected paths); do not skip or paraphrase from memory.**
