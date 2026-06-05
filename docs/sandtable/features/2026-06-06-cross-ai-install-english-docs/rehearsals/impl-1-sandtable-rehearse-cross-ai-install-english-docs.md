# 实现预演 #1 · Prompt-Language Localized Install Assets

## 结论
`DONE`

隔离 worktree：`/Users/andoop/Documents/projects/sss/sandtable-rehearsal-1`  
分支：`sandtable/rehearse/cross-ai-install-english-docs-1`

本轮实现按计划完成，没有触发新的实现级 anomaly。主 agent 已亲自抽查 worktree 的真实 diff、关键入口文件和新增 locale 资产目录。

## 改动摘要
- 修改 `README.md`
  - 加入中英两条官方安装提示词。
  - 保留统一 `INSTALL.md` 路径，并把 Codex / Kiro 明确收口到通用安装对象。
- 修改 `INSTALL.md`
  - 写入“整条官方提示词正文精确命中才自动判语言”的契约。
  - 加入 locale-pack 预检、文件级 `hooks/` 处理、`templates/en` 单模板根、以及不安装 `scripts/test-sandtable-init.sh` 的约束。
- 修改 `hooks/run-hook.cmd`
  - 根目录版本改为中文 user-facing `usage` 文本，作为 `zh` 安装源。
- 修改 `hooks/session-start`
  - 根目录版本改为中文 wrapper 与 fallback 错误文本，作为 `zh` 安装源。
- 新增 `locales/en/`
  - `AGENTS.md`
  - `.cursor/rules/sandtable.mdc`
  - `commands/*.md`
  - `.cursor/commands/*.md`
  - `skills/**`（含 `SKILL.md` 与 prompt 模板）
  - `scripts/sandtable-init.sh`
  - `hooks/run-hook.cmd`
  - `hooks/session-start`
- 新增 `templates/en/*.md`
  - 保持 `templates/` 仍是唯一模板根目录。

## 主 agent 抽查
- `git status --short`：worktree 中只有这轮实现相关改动，未见越界文件。
- `git diff --stat`：4 个已跟踪文件被修改，`locales/` 与 `templates/en/` 为新增未跟踪资产目录，符合计划结构。
- 关键入口抽查：
  - `README.md` 已并列中英官方提示词，并强调“原样”使用。
  - `INSTALL.md` 已写入精确匹配、澄清分支、locale-pack 预检、`hooks/` 文件级处理与 `templates/en` 映射。
  - 根目录 `hooks/run-hook.cmd` / `hooks/session-start` 已切到中文 user-facing 文本。
- 新增资产抽查：
  - `locales/en/` 共 46 个文件，覆盖 `AGENTS`、rules、commands、skills prompt 模板、scripts、hooks。
  - `templates/en/` 共 8 个模板文件。
  - 抽样读取 `locales/en/skills/using-sandtable/SKILL.md`、`locales/en/skills/red-team-wargame/opfor-prompt.md`、`templates/en/project.md`，确认并非空壳复制。

## 验证结果
- `bash -n`：
  - `scripts/sandtable-init.sh`
  - `locales/en/scripts/sandtable-init.sh`
  - `hooks/run-hook.cmd`
  - `hooks/session-start`
  - `locales/en/hooks/run-hook.cmd`
  - `locales/en/hooks/session-start`
  - 结果：全部通过
- JSON 解析：
  - `hooks/hooks.json`
  - `hooks/hooks-cursor.json`
  - 结果：通过
- 资产布局检查：
  - `locales/en/**` 共 46 个文件
  - `templates/en/*.md` 共 8 个文件
  - 结果：存在且与计划覆盖面一致
- 编辑区域 lint：
  - 结果：无 linter errors

## 评分（单方案）
- 需求符合度：5/5
- 红线符合度：通过
- 正确性证据：4/5
- 极简度：4/5
- 改动外科性：4/5
- 可读可维护：4/5
- 与现有模式契合：4/5

综合判断：当前是可选中的实现预演方案。

## 残余风险
- 这套安装切换仍是**文档驱动**而非专用安装程序驱动，正确性依赖执行安装的 AI 严格遵守 `INSTALL.md`。
- 目前没有自动化机制去持续比较中文源与英文 locale 资产的语义同步，未来更新时仍需要人工约束或后续 tooling。

## 择优建议
只有这一版实现预演，且它已满足当前 PRD / tests / plan 并通过主 agent 抽查，建议将其设为 `selected_impl`，等待开发者确认后再进入 `INTEGRATE`。
