---
description: Advance from request through debrief without manual handoff
---

Run Sandtable in autonomous mode for the current requirement; read and follow `skills/autonomous-orchestration/SKILL.md`.

Execute:
1. This command explicitly enables `<AUTOPILOT-OVERRIDE>` and it applies only to this `/sandtable-autopilot` run; if I later trigger a manual slash command, obey that command's boundary and do not silently keep the override running.
2. Read `docs/sandtable/project.md`, `constraints.md`, and the current requirement; create or resume the feature directory and `state.md` if needed.
3. First decide whether this is a cold start / explicit restart or a continuation. Only a new feature, no existing `state.md`/feature documents, or an explicit request to restart from the raw requirement may initialize `phase=RECON`, `autonomy.min_rounds`, `autonomy.min_agents_per_round`, `autonomy.completed_rounds`, and `autonomy.last_decision`. For an existing feature/docs/state, preserve existing `min_rounds`, `min_agents_per_round`, `completed_rounds`, and `phase`; only write/preserve `autonomy.mode=autopilot` and refresh the necessary `last_decision`.
4. Only the cold-start path may automatically complete `RECON -> OBJECTIVES -> TESTCASES -> PLAN`. Resume/continuation must first enforce the PRD confirmation gate and document-completeness checks; before TESTCASES/PLAN/MENTAL/REDTEAM/IMPL, stop at PRD confirmation if `prd.md` exists without traceable developer confirmation. If the same message confirms the PRD, persist that evidence to `state.md` or `journal.md` before or while continuing.
5. Then continue through the hard minimum coverage:
   - mental rehearsal: at least 1 round, with at least 1 read-only subagent per round
   - red-team attack: at least 1 round, with at least 1 red-team subagent per round
   - implementation rehearsal: at least 1 round, with at least 1 independent worktree subagent per round
6. On any `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED`: verify it personally first, write the result back into `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md`, then rehearse again from the earliest stage that has not been re-validated; only write `questions.md` and ask me if the issue is truly blocked.
7. Do not wait between phases; on phase switch update state and output **status bulletin** close, then continue in the same command. After all minimum coverage and debrief, load `closing-the-loop` for **full close** (with copy-paste templates). If `blocked=true`, use **full close** and AskQuestion (FR5 overrides autopilot silence).

## Feature Addendum: Minimum Coverage, Autonomous Judgment, Resume Gate

- `autonomy.min_rounds` and `autonomy.min_agents_per_round` mean minimum coverage, defaulting to `{ mental: 1, redteam: 1, impl: 1 }`. Do not migrate or overwrite historical features that already recorded 3/3/2.
- Only a cold start initializes `phase=RECON` and runs the full `RECON -> OBJECTIVES -> TESTCASES -> PLAN` document chain. If `state.md` or any feature artifact already exists, resume in place and preserve existing `min_rounds`, `min_agents_per_round`, `completed_rounds`, and `phase`.
- Before resuming into TESTCASES/PLAN/MENTAL/REDTEAM/IMPL, enforce the PRD confirmation gate. Confirmation must be traceable to developer input and persisted to `state.md` or `journal.md` before or while continuing. AskQuestion confirmation needs an answer id or `source: askquestion:<id>`; natural-language confirmation needs the quoted user text, confirmation time, and user-message source. Agent-authored progress logs, `autonomy.last_decision`, `phase>=TESTCASES`, vague “AskQuestion answer”, or source-less `prd_confirmed` fields do not count.
- If documents are incomplete, resume from the earliest missing artifact. If `prd.md` exists but is not confirmed, stop at PRD confirmation instead of moving to tests or plan.
- Rehearsal scheduling first fills mental -> redteam -> impl minimum coverage. Once minimum coverage is met, the main agent decides autonomously whether to add more rehearsal or enter `EVALUATE`, based on risk, change surface, lessons hit, recently fixed anomalies, implementation divergence, test confidence, and spot checks. Do not ask the user whether to continue unless truly blocked.
- Implementation `DONE` is not enough to count the impl round or enter `EVALUATE`; the completeness gate must pass, and EVALUATE must re-check the current PRD/tests/plan structured baseline, coverage matrix, live TODO table, and real diff / changed file list.
