# Implementation Rehearsal 3 · sandtable/rehearse/codex-slash-install-3

## Result
DONE

## Worktree
- Path: `/private/tmp/sandtable-codex-slash-live-3`
- Branch: `sandtable/rehearse/codex-slash-install-3`
- Commit: none

## Implemented
- README now distinguishes command entry by tool:
  - Cursor uses `.cursor/commands`.
  - Codex uses Sandtable Codex plugin/commands.
  - Claude Code / Kiro / generic agents can send `/sandtable-start` as a normal message and rely on `AGENTS.md` + `commands/sandtable-start.md`.
- INSTALL now documents Codex plugin/commands and workspace marketplace registration without claiming Codex discovers `.cursor/commands`.
- Added marketplace-compatible Codex plugin assets:
  - `.agents/plugins/marketplace.json`
  - `plugins/sandtable/.codex-plugin/plugin.json`
  - `plugins/sandtable/commands/*.md`
  - `locales/en/plugins/sandtable/commands/*.md`
- INSTALL maps Codex plugin commands through locale packs and treats plugin manifest / marketplace as shared machine assets.
- INSTALL validation avoids adding `jq`, Python, Node, or other non-core dependencies to the user-facing verification snippet.

## Main-Agent Verification
- Stale wording scan passed: no matches for the old one-size `/sandtable-start` README wording, old “Codex/Kiro generic only” claim, or `jq -e` in README/INSTALL.
- `plugins/sandtable/.codex-plugin/plugin.json` parses as JSON and does not reference nonexistent plugin-local `skills`, MCP, apps, or hooks.
- `.agents/plugins/marketplace.json` parses as JSON and uses top-level `plugins` array with the `sandtable` entry:
  - `source.path=./plugins/sandtable`
  - `policy.installation=AVAILABLE`
  - `policy.authentication=ON_INSTALL`
  - `category=Developer Tools`
- Command counts:
  - root `commands`: 13
  - `plugins/sandtable/commands`: 13
  - `locales/en/plugins/sandtable/commands`: 13
- Command mirrors:
  - `diff -rq commands plugins/sandtable/commands`: no differences
  - `diff -rq locales/en/commands locales/en/plugins/sandtable/commands`: no differences

## Changed Files
- `README.md`
- `INSTALL.md`
- `.agents/plugins/marketplace.json`
- `plugins/sandtable/.codex-plugin/plugin.json`
- `plugins/sandtable/commands/*.md`
- `locales/en/plugins/sandtable/commands/*.md`

## Residual Risk
- Codex UI refresh/plugin enablement behavior is controlled by Codex. The docs now avoid promising instant slash completion before the plugin is installed/enabled/loaded.
