# Codex 一句话安装与 Slash 命令接线 · 测试用例

> tests.md = 理解闸门。以下用例用于验证 AI 是否真正理解需求；不强求全部自动执行。

## TC1 · Codex 用户看到正确的一句话安装路径
- **映射**: FR1, FR2, 验收 1
- **Given**: 一个从未安装 Sandtable 的 Codex 用户打开 README 或 INSTALL。
- **When**: 用户阅读 Quickstart / 官方提示词区域。
- **Then**: 用户能看到中文和英文两条官方 AI 安装提示词；同时能看到 Codex 用户若想获得 slash 命令入口，需要安装 Sandtable Codex plugin/commands 接线，而不是只复制 `.cursor/commands`。
- **状态**: 待验证

## TC2 · 文档不再误导 Codex 自动读取 Cursor 命令
- **映射**: FR2, FR5, MUST NOT 1
- **Given**: 目标项目已安装 `.cursor/commands/sandtable-start.md`。
- **When**: Codex 用户查阅 README / INSTALL 中关于 Codex slash 命令的说明。
- **Then**: 文档明确说明 `.cursor/commands` 服务 Cursor；不能承诺 Codex 会自动从 `.cursor/commands` 生成 slash 菜单。
- **状态**: 待验证

## TC3 · Codex plugin 资产完整覆盖 13 个 Sandtable 命令
- **映射**: FR3, FR4, 验收 2
- **Given**: 仓库内新增 Sandtable Codex plugin 包。
- **When**: 检查 `plugins/sandtable/commands/` 目录。
- **Then**: 能找到 13 个命令文档：`sandtable-start`、`sandtable-autopilot`、`sandtable-recon`、`sandtable-objectives`、`sandtable-plan`、`sandtable-refine`、`sandtable-mental`、`sandtable-redteam`、`sandtable-live`、`sandtable-debrief`、`sandtable-rehearse`、`sandtable-status`、`sandtable-resume`；每个命令描述与现有 `commands/*.md` 的职责一致。
- **状态**: 待验证

## TC4 · `/sandtable-start` 在 Codex 中保持 Sandtable 前五步语义
- **映射**: FR4, MUST 3
- **Given**: Codex 用户安装了 Sandtable Codex plugin 并输入 `/sandtable-start 需求：增加登录页`。
- **When**: Codex 读取该命令。
- **Then**: 命令要求执行 `INTAKE -> RECON -> OBJECTIVES -> TESTCASES -> PLAN`，并要求读取 `skills/using-sandtable/SKILL.md`，不得跳过 PRD、测试用例或计划阶段。
- **状态**: 待验证

## TC5 · Codex plugin 安装说明可执行且诚实
- **映射**: FR5, 验收 3, MUST NOT 2
- **Given**: Codex 用户按 INSTALL 中的 Codex 章节安装。
- **When**: 用户只按文档操作，不额外猜测隐藏路径。
- **Then**: 文档提供明确的 plugin 安装/注册步骤和安装后验证步骤，包括 workspace marketplace 注册文件 `.agents/plugins/marketplace.json`；如果某个 Codex UI 行为无法由仓库保证，文档用限制说明表达，而不是承诺一定出现补全菜单。
- **状态**: 待验证

## TC6 · Cursor / Claude Code / 通用 agent 路径不回退
- **映射**: FR7, MUST NOT 4
- **Given**: 一个 Cursor 用户或 Claude Code 用户使用现有安装路径。
- **When**: 用户查看 README / INSTALL 并执行安装。
- **Then**: Cursor 仍能获得 `.cursor/rules` 与 `.cursor/commands`；Claude Code 仍保留 `CLAUDE.md` / hooks 相关说明；通用 agent 仍以 `AGENTS.md` 作为行为基线。
- **状态**: 待验证

## TC7 · 中英 locale 规则覆盖 Codex 命令资产
- **映射**: FR6, MUST 1
- **Given**: 用户分别使用中文官方提示词和英文官方提示词安装 Sandtable。
- **When**: 安装过程涉及 Codex plugin/commands 资产。
- **Then**: 中文安装使用中文 Codex 命令资产，英文安装使用英文 Codex 命令资产；安装说明不得要求 AI 在运行时自由翻译命令或 skill 文本。
- **状态**: 待验证

## TC7.5 · Codex workspace marketplace 能发现 Sandtable plugin
- **映射**: FR3, FR5, MUST 2
- **Given**: Sandtable 安装到目标项目后，目标项目包含 `plugins/sandtable/.codex-plugin/plugin.json` 与 `.agents/plugins/marketplace.json`。
- **When**: 检查 `.agents/plugins/marketplace.json` 的插件条目。
- **Then**: 该文件使用 Codex marketplace 结构：top-level `plugins` 是数组；数组内包含 `sandtable` 插件条目；该条目的 `source.source` 为 `local`，`source.path` 指向 `./plugins/sandtable`，`policy.installation` 为 `AVAILABLE`，`policy.authentication` 为 `ON_INSTALL`，`category` 为 `Developer Tools`；且 `./plugins/sandtable` 在目标项目根目录下能解析到 Sandtable plugin 包。
- **状态**: 待验证

## TC8 · 已存在文件时不为 Codex 接线破坏非覆盖红线
- **映射**: FR1, FR5, MUST NOT 3
- **Given**: 目标项目已存在 Sandtable 语言相关资产或 Codex plugin 目标路径。
- **When**: 用户再次运行安装，想切换语言或补装 Codex 命令。
- **Then**: 安装说明要求跳过冲突路径并报告安装不完整/未切换完成；不得覆盖已有文件，也不得静默形成半中文半英文的命令集。
- **状态**: 待验证
