# Mental Rehearsal 1 · Codex Slash Install

## Result
ANOMALY_FOUND

## Summary
Two read-only mental-rehearsal subagents independently found that the plan did not close the Codex plugin discovery chain.

## Anomalies

### A1 · Missing marketplace registration
- 偏差/问题: 计划只加入 `.codex-plugin/plugin.json` 和 commands，没有把 Codex plugin marketplace 注册文件纳入安装映射、非覆盖检查和验证清单。
- 位置: `plan.md` T4 原步骤只列 `.codex-plugin/plugin.json`、Codex commands 源、必要 `skills/`。
- 依据: 本地 Codex plugin 示例说明 Codex plugin discovery is marketplace-based，plugin 通过 `marketplace.json` 被发现；workspace 级路径为 `<workspace>/.agents/plugins/marketplace.json`。
- 影响: TC5 的“安装/注册步骤可执行”无法闭环；TC8 的已有 marketplace 冲突也没有非覆盖策略。

### A2 · Plugin root layout not marketplace-compatible
- 偏差/问题: 计划把 plugin manifest 放在仓库根目录 `.codex-plugin/plugin.json`，但本地 Codex marketplace 示例的插件结构是 `plugins/<name>/.codex-plugin/plugin.json`。
- 位置: `plan.md` T2/T3/T5 原计划。
- 依据: 本地插件示例 README 写明每个 plugin 位于 `plugins/<name>/`，包含 `.codex-plugin/plugin.json`，可选 companion surfaces 包括 plugin-level `commands/`；`codex plugin add --help` 只安装已配置 marketplace 中的插件名。
- 影响: TC3/TC5 无法证明根目录 `.codex-plugin` 会被 Codex 识别。

## Decision
主 agent 核实后确认 anomaly 成立。修正方向：
- 使用 marketplace-compatible 结构：`plugins/sandtable/.codex-plugin/plugin.json` 与 `plugins/sandtable/commands/`。
- 新增 workspace marketplace 注册：`.agents/plugins/marketplace.json`，指向 `./plugins/sandtable`。
- 将 marketplace 文件纳入 README/INSTALL、locale、非覆盖检查和验证清单。

## Next
修正 `prd.md`、`tests.md`、`plan.md` 后重跑头脑预演。
