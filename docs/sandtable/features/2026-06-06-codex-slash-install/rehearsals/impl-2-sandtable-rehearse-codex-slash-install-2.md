# Implementation Rehearsal 2 · sandtable/rehearse/codex-slash-install-2

## Result
ANOMALY_FOUND

## Worker Result
The worker reported `DONE` from `/private/tmp/sandtable-codex-slash-live-2`.

## Main-Agent Verification
Main-agent verification confirmed that the marketplace JSON shape was fixed, but found two remaining deviations:

### A1 · README still has old one-size command wording
- `README.md` still says “安装完成后运行 `/sandtable-start`” near the top and “第一条命令：`/sandtable-start`” in Quickstart.
- This conflicts with T1, which requires README to distinguish Cursor, Codex plugin, and Claude/Kiro/generic paths.
- Impact: TC1 can still mislead Codex users into expecting slash commands before plugin installation/enabling.

### A2 · INSTALL verification introduces a `jq` dependency
- `INSTALL.md` verification code uses `jq -e ...`.
- Project constraints require supporting scripts to stay dependency-free and forbid new third-party dependencies. Even though this is a docs snippet rather than a repo script, installation instructions should not make Codex verification depend on `jq`.
- Impact: TC5 can fail on machines without `jq`, and the install path no longer feels “one prompt / no extra dependency”.

## Decision
Do not select impl-2. 回修 plan:
- README must replace both top quick command text and Quickstart step 3 with harness-specific wording.
- INSTALL verification must avoid `jq`; it may ask the AI to read/parse JSON structurally and report mismatch, but the shell snippet should remain presence-only / POSIX-friendly.

Then rerun implementation rehearsal in a fresh worktree.
