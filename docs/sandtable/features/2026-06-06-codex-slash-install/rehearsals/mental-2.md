# Mental Rehearsal 2 · Codex Slash Install

## Result
LOGIC_CLOSED

## End-to-End Logic Chain
1. T2 creates `plugins/sandtable/.codex-plugin/plugin.json` and keeps the manifest minimal, avoiding references to nonexistent plugin-local directories.
2. Local Codex plugin examples support this shape: plugins live under `plugins/<name>/`, with `.codex-plugin/plugin.json` required and `commands/` available as a companion surface.
3. T2 creates `.agents/plugins/marketplace.json` with `source.path=./plugins/sandtable`; local examples confirm workspace marketplace paths resolve relative to the workspace.
4. T3 syncs root `commands/*.md` to `plugins/sandtable/commands/*.md` and syncs English commands to `locales/en/plugins/sandtable/commands/*.md`.
5. The existing command sets contain 13 Sandtable commands and use the same frontmatter + markdown command format found in Codex plugin examples.
6. `/sandtable-start` retains the Sandtable front-five semantics: load `skills/using-sandtable/SKILL.md`, then run `INTAKE -> RECON -> OBJECTIVES -> TESTCASES -> PLAN`.
7. T5 verifies manifest, marketplace registration, command count, command semantics, and removal of old misleading Codex wording.

## Checked Boundaries
- Existing README/INSTALL still contain old wording today, but T1/T5 explicitly require replacing it; this is an implementation task, not a plan anomaly.
- Marketplace conflict and non-overwrite behavior are now covered in T4.
- Command references to `skills/...` remain valid because existing install mapping installs `skills/` to the target project root.

## Redline Check
- Does not claim Codex auto-discovers `.cursor/commands`.
- Provides workspace marketplace registration.
- Covers 13 commands and locale mirrors.
- Does not write user-global Codex directories.

## Residual Risk
Codex UI slash completion timing still depends on Codex itself; the plan already requires docs to avoid promising instant completion before plugin install/refresh.
