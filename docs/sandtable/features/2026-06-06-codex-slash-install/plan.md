# Codex 一句话安装与 Slash 命令接线 · 改动计划

**目标:** 让 Codex 用户通过官方 AI 一句话安装 Sandtable 后，也能通过 Codex plugin/commands 获得 Sandtable 命令入口，并清楚知道它不同于 Cursor 的 `.cursor/commands`。
**架构:** 新增一个 marketplace-compatible 的 Codex plugin 分发面：`plugins/sandtable/.codex-plugin/plugin.json` + `plugins/sandtable/commands/` + workspace marketplace 注册文件 `.agents/plugins/marketplace.json`。README/INSTALL 改为按 harness 区分 Cursor、Claude Code、Codex、通用 agent：Codex 的命令来自 Sandtable Codex plugin，不承诺读取 `.cursor/commands`。
**对应 PRD:** `prd.md`
**推演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。重点攻击面：Codex plugin 是否真能承载 commands、文档是否误导 slash 菜单行为、locale pack 是否漏掉 Codex 命令资产、现有 Cursor/Claude 路径是否回退。

---

## 文件地图
- 修改 `README.md` — 更新 Quickstart 与命令入口说明，加入 Codex plugin/commands 的诚实边界。
- 修改 `INSTALL.md` — 加入 Codex 接线步骤、安装映射、验证项与冲突报告规则。
- 创建 `plugins/sandtable/.codex-plugin/plugin.json` — Sandtable Codex plugin manifest。
- 创建 `plugins/sandtable/commands/*.md` — Codex plugin 的中文命令资产，内容与现有 `commands/*.md` 等义。
- 创建 `.agents/plugins/marketplace.json` — workspace marketplace 注册文件，指向 `./plugins/sandtable`。
- 创建/同步 `locales/en/plugins/sandtable/commands/*.md` — 英文 Codex plugin commands 镜像。
- 可选创建 `codex/README.md` — Codex plugin 本地安装/开发说明；仅当 INSTALL 过长或需要独立说明时创建。
- 修改 `locales/en/README` 类资产（若本仓未来已有对应入口）— 保持英文安装说明同步；当前仓库根 README 仍是主入口。
- 不修改 Sandtable skill 的硬门禁、Red Flags、状态机语义。

---

### 任务 T1: 明确 Codex 支持边界与用户路径

**文件:**
- 修改: `README.md`
- 修改: `INSTALL.md`

- [ ] 步骤1: 在 README Quickstart 中把“安装完成后运行 `/sandtable-start`”改成按 harness 区分：
  - Cursor：重载窗口后使用 `/sandtable-start`
  - Codex：安装/启用 Sandtable Codex plugin 后使用 Sandtable 命令入口
  - Claude Code / 通用 agent：可输入 `/sandtable-start` 或“按 `commands/sandtable-start.md` 执行”
- [ ] 步骤1.5: README 顶部“立刻试用”区域和 Quickstart 步骤 3 都必须按工具区分命令入口；不得保留“安装完成后运行 `/sandtable-start`”或“第一条命令：`/sandtable-start`”这种对 Codex 不够精确的一刀切文案。
- [ ] 步骤2: 删除或改写 `README.md:75` 附近“Codex 与 Kiro 走同一条通用安装路径；本仓库不会为它们新增专属 rules / hooks / 脚本接线”的旧边界。新文案必须说明：Codex 可通过 Sandtable Codex plugin 接线；Kiro 仍暂走通用路径。
- [ ] 步骤3: 在 INSTALL 的 harness 接线章节新增 “Codex（plugin/commands）” 小节，明确 `.cursor/commands` 不服务 Codex。
- [ ] 步骤4: 在 README/INSTALL 中加入限制说明：仓库可提供 Codex plugin/commands 资产，但不能承诺未安装 plugin 时 Codex UI 会显示 slash 补全。
- [ ] 步骤5: 验证 `TC1`、`TC2`、`TC5`：人工检查文档是否能让 Codex 用户知道该做什么，且没有再暗示 `.cursor/commands` 会被 Codex 自动发现。

### 任务 T2: 新增 marketplace-compatible Sandtable Codex plugin

**文件:**
- 创建: `plugins/sandtable/.codex-plugin/plugin.json`
- 创建: `.agents/plugins/marketplace.json`
- 可选创建: `codex/README.md`

- [ ] 步骤1: 参考本地 Codex 插件示例创建 `plugins/sandtable/.codex-plugin/plugin.json`，字段包含：
  - `name`: `sandtable`
  - `version`: 与仓库当前版本策略一致；若仓库无版本字段，使用 `0.1.0`
  - `description`: `Sandtable rehearsal-driven development workflow for coding agents`
  - `author.name`: `andoop`
  - `repository`: `https://github.com/andoop/sandtable`
  - `license`: `MIT`
  - `interface.displayName`: `Sandtable`
  - `interface.shortDescription`: 简短说明
  - `interface.category`: `Developer Tools`
  - `interface.capabilities`: `["Interactive", "Write"]`
- [ ] 步骤2: 不在 manifest 中引入 `skills`、MCP、app、hook 或外部依赖，除非同一任务明确创建对应 plugin 内目录；保持最小插件面，避免 manifest 指向不存在的路径。
- [ ] 步骤3: 创建 `.agents/plugins/marketplace.json`，内容必须符合 Codex marketplace 结构：top-level `name` 为 `sandtable-local`，`interface.displayName` 为 `Sandtable Local`，`plugins` 为数组；数组里包含 `sandtable` 条目，`source.source` 为 `local`，`source.path` 为 `./plugins/sandtable`，`policy.installation` 为 `AVAILABLE`，`policy.authentication` 为 `ON_INSTALL`，`category` 为 `Developer Tools`。
- [ ] 步骤4: 若创建 `codex/README.md`，只写本地开发/安装说明，不复制 Sandtable 方法论正文。
- [ ] 步骤5: 验证 `TC5` / `TC7.5`：`plugins/sandtable/.codex-plugin/plugin.json` JSON 可解析，`.agents/plugins/marketplace.json` JSON 可解析，且 marketplace 的 `plugins` 是数组，包含 `sandtable` 条目，`source.path` 在 workspace 根目录下能指向 `plugins/sandtable`，`policy.authentication` 为 `ON_INSTALL`。

### 任务 T3: 准备 Codex plugin commands 资产

**文件:**
- 创建/同步: `plugins/sandtable/commands/*.md`
- 创建/同步: `locales/en/plugins/sandtable/commands/*.md`
- 修改: `INSTALL.md`

- [ ] 步骤1: 使用 `plugins/sandtable/commands/` 作为 Codex plugin-level commands 路径，因为本地 Codex plugin 示例将 plugin 放在 `plugins/<name>/`，commands 为 plugin companion surface。
- [ ] 步骤2: 将根目录现有 `commands/*.md` 同步到 `plugins/sandtable/commands/*.md`，避免改变通用 agent 命令语义；若命令正文引用相对路径，确认从 Codex 执行上下文仍指向目标项目根的 `skills/`/`docs/`。
- [ ] 步骤3: 确保 13 个 Sandtable 命令都存在，并且每个命令 frontmatter `description` 与正文职责不漂移。
- [ ] 步骤4: 英文 locale 若已有 `locales/en/commands/*.md`，将其同步到 `locales/en/plugins/sandtable/commands/*.md`；若缺失，补齐英文镜像，但不靠安装时自由翻译。
- [ ] 步骤5: 验证 `TC3`、`TC4`、`TC7`、`TC7.5`：检查 13 个命令齐全、`/sandtable-start` 仍只负责前五步、英文命令资产存在且等义，marketplace 指向正确 plugin root。

### 任务 T4: 更新安装映射与非覆盖规则

**文件:**
- 修改: `INSTALL.md`

- [ ] 步骤1: 在安装映射中加入 Codex plugin 相关资产：
  - 中文：`plugins/sandtable/.codex-plugin/plugin.json`、`plugins/sandtable/commands/`、`.agents/plugins/marketplace.json`
  - 英文：`plugins/sandtable/.codex-plugin/plugin.json` 可共享时复用中文 manifest；`plugins/sandtable/commands/` 使用英文命令源；`.agents/plugins/marketplace.json` 若含自然语言显示名，按 locale 明确处理
- [ ] 步骤2: 将 Codex plugin 目标路径纳入非覆盖检查：`./plugins/sandtable` 与 `./.agents/plugins/marketplace.json`。若目标已有 marketplace 文件，不覆盖；要么报告 Codex 接线不完整，要么在计划明确给出结构化追加策略并保护已有 plugin entries。
- [ ] 步骤3: 保持 locale pack 整包预检；新增 Codex 命令资产后，一旦任一语言相关目标已存在，不得继续部分复制其它语言命令。
- [ ] 步骤4: 更新验证清单，加入 Codex：
  - `plugins/sandtable/.codex-plugin/plugin.json` 存在
  - `plugins/sandtable/commands/` 存在
  - `.agents/plugins/marketplace.json` 存在并含 `sandtable` 条目
  - 13 个命令齐全
  - 文档说明了 plugin 安装后再使用命令入口
- [ ] 步骤5: 验证 `TC5`、`TC8`：已有目标路径时安装报告不完整；不覆盖、不混语、不伪成功。

### 任务 T5: 一致性扫描与文档验收

**文件:**
- 修改: `README.md`
- 修改: `INSTALL.md`
- 创建/修改: `plugins/sandtable/.codex-plugin/plugin.json`
- 创建/修改: `.agents/plugins/marketplace.json`
- 创建/同步: Codex commands 资产

- [ ] 步骤1: 扫描旧边界文案：
  运行: `rg -n "Codex|Kiro|专属|不新增|通用路径|cursor/commands|\\.cursor/commands|slash" README.md INSTALL.md`
  预期: Codex 被描述为 plugin/commands 接线；Kiro 暂不新增专属接线；没有“Codex 不新增接线”的残留误导。
- [ ] 步骤2: 扫描命令齐全性：
  运行: `find commands plugins/sandtable/commands -maxdepth 1 -name 'sandtable-*.md' | wc -l`
  预期: 根目录通用命令与 Codex plugin 命令各 13 个；如使用单条命令分别检查，两个输出都应为 `13`。
- [ ] 步骤3: 抽查关键命令语义：
  运行: `rg -n "INTAKE|RECON|OBJECTIVES|TESTCASES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|/sandtable-start|/sandtable-rehearse|/sandtable-autopilot" commands .cursor/commands locales/en/commands`
  预期: 关键状态机和命令边界在中英资产里都能命中。
- [ ] 步骤4: 检查 plugin manifest：
  运行: `test -f plugins/sandtable/.codex-plugin/plugin.json`
  预期: 文件存在，JSON 可被 `jq . plugins/sandtable/.codex-plugin/plugin.json` 解析；若 `jq` 不可用，用 Codex CLI 或人工检查 JSON。
- [ ] 步骤5: 检查 workspace marketplace：
  运行: `test -f .agents/plugins/marketplace.json`
  预期: 文件存在，JSON 可解析，top-level `plugins` 是数组，含 `sandtable` 条目，`source.path` 为 `./plugins/sandtable`，`policy.authentication` 为 `ON_INSTALL`。
- [ ] 步骤5.5: INSTALL 的验证代码块不得依赖 `jq`、Python、Node 或其它非 POSIX/coreutils 工具。JSON 结构验证可以写成 AI/人工检查要求：读取 `.agents/plugins/marketplace.json`，确认 `plugins` 数组里存在 `sandtable` 条目，且字段值符合 TC7.5；若不符合，报告 Codex 不完整。
- [ ] 步骤6: 对照 `tests.md` 人工验收 `TC1` 到 `TC8`，所有 Then 条件均成立后进入推演。

---

## 任务与 TC 映射
- `TC1` / `TC2` / `TC5` -> `T1`, `T4`, `T5`
- `TC3` / `TC4` / `TC7` / `TC7.5` -> `T2`, `T3`, `T5`
- `TC6` -> `T1`, `T5`
- `TC8` -> `T4`, `T5`

## 计划红线复核
- 不承诺 Codex 自动读取 `.cursor/commands`。
- 不删除 Cursor / Claude Code / 通用 agent 的既有路径。
- 不改 Sandtable 方法论硬门禁与状态机语义。
- 不写用户全局 Codex 目录，除非后续确认官方稳定路径并获得开发者明确选择。
