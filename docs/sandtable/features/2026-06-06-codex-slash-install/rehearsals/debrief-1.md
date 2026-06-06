# Debrief 1 · Codex Slash Install

## Result
SELECTED: `sandtable/rehearse/codex-slash-install-3`

## Candidates

| Rehearsal | Result | Decision |
| --- | --- | --- |
| impl-1 `sandtable/rehearse/codex-slash-install-1` | ANOMALY_FOUND | Rejected: malformed marketplace JSON shape and missing `policy.authentication`. |
| impl-2 `sandtable/rehearse/codex-slash-install-2` | ANOMALY_FOUND | Rejected: stale README command wording and `jq` dependency in install verification. |
| impl-3 `sandtable/rehearse/codex-slash-install-3` | DONE | Selected: passes main-agent verification after prior plan fixes. |

## Score

Only impl-3 reached `DONE` after the fix-and-rerun loop, so it is selected without comparing multiple DONE candidates.

| Dimension | Score | Notes |
| --- | ---: | --- |
| Requirement fit | 5/5 | Covers Codex plugin/commands, marketplace registration, locale commands, README/INSTALL docs. |
| Redline fit | Pass | No global Codex writes, no `.cursor/commands` auto-discovery claim, no new runtime dependency. |
| Correctness evidence | 5/5 | JSON validates, marketplace shape checked, command counts are 13/13/13, command mirrors diff clean. |
| Minimality | 4/5 | Adds the necessary plugin surface and docs; avoids extra MCP/app/hooks. |
| Surgical scope | 5/5 | Touches README, INSTALL, and Codex plugin assets only. |
| Maintainability | 4/5 | Duplicated command mirrors are mechanical but explicit for locale/plugin packaging. |
| Existing-pattern fit | 5/5 | Matches local Codex marketplace-compatible plugin structure. |

## Integration Decision
Integrate impl-3 into the main worktree, then verify the same checks in the main worktree.
