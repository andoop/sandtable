# Implementation Rehearsal 1 · sandtable/rehearse/codex-slash-install-1

## Result
ANOMALY_FOUND

## Worker Result
The worker reported `DONE` from `/private/tmp/sandtable-codex-slash-live-1`, with changes to README, INSTALL, `.agents/plugins/marketplace.json`, and Codex plugin command assets.

## Main-Agent Verification
Main-agent verification found that `.agents/plugins/marketplace.json` did not match the local Codex marketplace schema:

- Worker output used a `plugins` object keyed by `sandtable`.
- The local plugin creator spec requires top-level `plugins` to be an array.
- The worker output omitted `policy.authentication`, while the marketplace generation rules say every entry must include `policy.installation`, `policy.authentication`, and `category`.

## Evidence
- Worktree file: `/private/tmp/sandtable-codex-slash-live-1/.agents/plugins/marketplace.json`
- Local spec: `/Users/andoop/.codex/.tmp/plugins/.agents/skills/plugin-creator/references/plugin-json-spec.md`
- Plan gap before correction: `plan.md` requested `policy.installation` and `category`, but did not explicitly require `policy.authentication` or the array shape.

## Impact
- TC5 and TC7.5 are not guaranteed: Codex may not discover the workspace plugin from a malformed marketplace file.
- The implementation cannot be selected for integration.

## Decision
回修 `tests.md` / `plan.md` to require the precise marketplace shape:
- top-level `name`
- optional `interface.displayName`
- `plugins` array
- `sandtable` entry with `source.source=local`, `source.path=./plugins/sandtable`
- `policy.installation=AVAILABLE`
- `policy.authentication=ON_INSTALL`
- `category=Developer Tools`

Then rerun implementation rehearsal in a fresh worktree.
