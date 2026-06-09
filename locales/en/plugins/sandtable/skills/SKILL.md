---
name: state-and-memory
description: Use at the start of any Sandtable work and whenever you need to record progress, resume after interruption, or hand off to another AI or person. Defines the on-disk state machine and append-only memory under docs/sandtable so work survives context loss and handoffs.
---

# State and Memory · Recoverable Across People and AIs

**Core principle: the process must live in files, not in chat context.** Chat is lossy; AIs get swapped; people hand work over. As long as `docs/sandtable/` exists, anyone can continue.

## Directory Layout (create in the target project root)

```text
docs/sandtable/
  project.md
  constraints.md
  features/
    <YYYY-MM-DD>-<slug>/
      prd.md
      tests.md
      plan.md
      state.md
      journal.md
      questions.md
      rehearsals/
        mental-<n>.md
        redteam-<n>.md
        impl-<n>-<branch>.md
```

Templates live in this plugin’s `templates/`.

## `state.md`: The Single Trusted Progress Record

`state.md` uses YAML frontmatter for machine-readable state and regular markdown for human-readable status:

```markdown
---
feature: 2026-06-01-user-login
phase: PLAN
blocked: false
updated: 2026-06-01T23:00:00+08:00
tasks:
  - id: T1
    title: Login form component
    status: todo
  - id: T2
    title: Auth API integration
    status: todo
rehearsals:
  mental:  { runs: 0, last: none }
  redteam: { runs: 0, last: none }
  impl:    { runs: 0, last: none }
autonomy:
  mode: manual
  min_rounds: { mental: 1, redteam: 1, impl: 1 } # minimum coverage / 最低覆盖
  min_agents_per_round: { mental: 1, redteam: 1, impl: 1 } # minimum coverage / 最低覆盖
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none
selected_impl: none
---
```

Rules:
- Update `state.md` after every action: `phase`, `tasks`, `updated`, and in autopilot also `autonomy.last_decision` and `autonomy.completed_rounds` when needed.
- If `blocked: true`, the main flow pauses and you must resolve `questions.md` first.
- `autonomy.mode` is the only authoritative switch for autonomous mode. Do not invent sibling flags.
- In autopilot, recovery logic is driven by `autonomy.*`, not by `rehearsals.*`.
- Manual `/sandtable-mental`, `/sandtable-redteam`, `/sandtable-live`, and `/sandtable-rehearse` still update `rehearsals.*`, but those manual runs do **not** count toward `autonomy.completed_rounds`.
- On rollback (anomaly -> fix), set `phase` back to the earliest stage that is no longer validated, and record why in `journal.md`; if in autopilot, refresh `autonomy.last_decision` too.
- If an old feature directory is missing the `autonomy` block, treat it explicitly as `manual`; do not infer autopilot state from `rehearsals.*`.

## `journal.md`: Append-Only Memory

Each entry should look like:

```text
## 2026-06-01 23:10 · [decision|Q&A|rehearsal|attack|anomaly|integration]
- Context: ...
- Content: ...
- Basis / source: file:line or developer reply
```

Never delete or rewrite history entries. Corrections are new entries.

## Resume Flow (the core of `/sandtable-resume`)

```dot
digraph resume {
  "Read project.md + constraints.md" [shape=box];
  "List features/ and choose the target requirement" [shape=box];
  "Read state.md for phase / tasks / autonomy" [shape=box];
  "blocked?" [shape=diamond];
  "Read questions.md and resolve blockers first" [shape=box];
  "Read recent journal.md entries to rebuild context" [shape=box];
  "autopilot?" [shape=diamond];
  "Choose next step from minimum coverage plus autonomous judgment" [shape=box];
  "Continue at the indicated phase" [shape=doublecircle];

  "Read project.md + constraints.md" -> "List features/ and choose the target requirement" -> "Read state.md for phase / tasks / autonomy" -> "blocked?";
  "blocked?" -> "Read questions.md and resolve blockers first" [label="Yes"];
  "blocked?" -> "Read recent journal.md entries to rebuild context" [label="No"];
  "Read questions.md and resolve blockers first" -> "Read recent journal.md entries to rebuild context";
  "Read recent journal.md entries to rebuild context" -> "autopilot?";
  "autopilot?" -> "Choose next step from minimum coverage plus autonomous judgment" [label="Yes"];
  "autopilot?" -> "Continue at the indicated phase" [label="No"];
  "Choose next step from minimum coverage plus autonomous judgment" -> "Continue at the indicated phase";
}
```

Do not reinvent already-recorded decisions when resuming. Only go back to `being-truthful` if you find a contradiction or a gap.

Autopilot continuation must follow this exact branch:
1. If `blocked=true`: resolve `questions.md` first.
2. If `autonomy.mode=autopilot` and `blocked=false`:
   - if `completed_rounds.mental < min_rounds.mental`, next is `MENTAL_REHEARSAL`
   - else if `completed_rounds.redteam < min_rounds.redteam`, next is `REDTEAM`
   - else if `completed_rounds.impl < min_rounds.impl`, next is `IMPL_REHEARSAL`
   - else next is `EVALUATE`
3. If `autonomy.mode=manual`, resume from `phase`.

## Red Flags

| Thought | Reality |
|------|------|
| "I can keep progress in my head." | You will be replaced or lose context. Write it into `state.md`. |
| "The journal is too verbose; I’ll skip it." | Without the journal, the next AI effectively starts from zero. |
| "I’ll edit an old journal entry to fix it." | History is append-only. Fixes are new entries. |
| "We’re blocked, but I’ll keep doing other parts." | `blocked=true` means the main flow stops. Resolve `questions.md` first. |

## Feature Addendum: Minimum Coverage, Autonomous Judgment, Resume Gate

- `autonomy.min_rounds` and `autonomy.min_agents_per_round` mean minimum coverage, defaulting to `{ mental: 1, redteam: 1, impl: 1 }`. Do not migrate or overwrite historical features that already recorded 3/3/2.
- Only a cold start initializes `phase=RECON` and runs the full `RECON -> OBJECTIVES -> TESTCASES -> PLAN` document chain. If `state.md` or any feature artifact already exists, resume in place and preserve existing `min_rounds`, `min_agents_per_round`, `completed_rounds`, and `phase`.
- Before resuming into TESTCASES/PLAN/MENTAL/REDTEAM/IMPL, enforce the PRD confirmation gate. Confirmation must be traceable to developer input and persisted to `state.md` or `journal.md` before or while continuing. AskQuestion confirmation needs an answer id or `source: askquestion:<id>`; natural-language confirmation needs the quoted user text, confirmation time, and user-message source. Agent-authored progress logs, `autonomy.last_decision`, `phase>=TESTCASES`, vague “AskQuestion answer”, or source-less `prd_confirmed` fields do not count.
- If documents are incomplete, resume from the earliest missing artifact. If `prd.md` exists but is not confirmed, stop at PRD confirmation instead of moving to tests or plan.
- Rehearsal scheduling first fills mental -> redteam -> impl minimum coverage. Once minimum coverage is met, the main agent decides autonomously whether to add more rehearsal or enter `EVALUATE`, based on risk, change surface, lessons hit, recently fixed anomalies, implementation divergence, test confidence, and spot checks. Do not ask the user whether to continue unless truly blocked.
- Implementation `DONE` is not enough to count the impl round or enter `EVALUATE`; the completeness gate must pass, and EVALUATE must re-check the current PRD/tests/plan structured baseline, coverage matrix, live TODO table, and real diff / changed file list.
