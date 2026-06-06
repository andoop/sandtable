# Superpowers 式多 harness 安装对齐 · 改动计划

**目标:** 让 `sandtable` **完整对齐** `superpowers`：harness-first README、全部 companion files、版本/同步发布工具链、独立 marketplace 仓、各平台实际上架；并保留 `Kiro / 通用 agent`。
**架构:** 分四阶段——①仓内 harness parity（T1–T5）②发布基础设施（T6–T7）③marketplace 仓与平台上架（T8–T11）④总验收（T12）。Codex 保持 `plugins/sandtable/` nested 布局，sync 脚本适配而非整仓重构。
**对应 PRD:** `prd.md`（Q4 已扩 scope 至含 marketplace 发布）
**预演要求:** 重点攻击面在原有四项基础上，增加：⑤版本 bump 是否覆盖全部 manifest ⑥sync 脚本是否适配 nested Codex ⑦独立 marketplace 仓是否与 Copilot/Claude 命令自洽 ⑧平台上架后 README 是否及时从 pending 改为 live。

---

## 文件地图
- 修改 `README.md` — 把首页安装入口改成 harness-first 矩阵，并为每个 harness 给出主路径/诚实边界；保留 AI-assisted 与 `Kiro / 通用 agent` 次级路径。
- 修改 `INSTALL.md` — 从首页主入口降为次级/备用路径，解释何时使用 AI-assisted 安装，并保留现有双语 locale-pack 与不覆盖规则。
- 创建 `package.json` — 为 OpenCode plugin 提供根包入口，`main` 指向 `.opencode/plugins/sandtable.js`。
- 创建 `.opencode/INSTALL.md` — OpenCode 的详细安装说明，供 README 的 OpenCode 小节下沉引用；plugin URL 必须指向 `andoop/sandtable`，禁止保留 superpowers 专有 URL。
- 创建 `.opencode/plugins/sandtable.js` — OpenCode plugin bootstrap：注册 `skills/` 路径、向首条消息注入 `using-sandtable`，并注入 OpenCode 工具映射（至少覆盖 `Task` → subagent、`TodoWrite`、`Skill`）。
- 创建 `GEMINI.md` — Gemini CLI context file，加载 `using-sandtable` 与 Sandtable 工具映射参考。
- 创建 `gemini-extension.json` — Gemini 扩展元数据，声明 `contextFileName`。
- 创建 `skills/using-sandtable/references/gemini-tools.md` — Gemini CLI 工具映射（`Task tool` → `@generalist` 等），因 Sandtable 推演 prompt 模板绑定 Claude 工具名。
- 创建 `.version-bump.json` — 跨 manifest 版本同步声明（mirror superpowers）。
- 创建 `scripts/bump-version.sh` — 一键 bump 全部 manifest version。
- 创建 `scripts/sync-to-codex-plugin.sh` — 向 `openai/plugins` fork 同步 `plugins/sandtable/` 内容并开 PR。
- 创建 `docs/PUBLISHING.md` — 8 harness 发版与上架 checklist。
- 创建 `templates/sandtable-marketplace/` — 独立仓 `andoop/sandtable-marketplace` 的 scaffold（push 到 GitHub 为 T9 步骤）。

---

### 任务 T1: 重写 README 为 harness-first 安装矩阵

**文件:**
- 修改: `README.md`

- [ ] 步骤1: **移除或替换**当前 `README.md` 全部 AI-first 首屏入口，再插入 harness-first 矩阵。必须处理的落点：`README.md:10-20`（「立刻试用」+ 两条官方提示词）、`:45`（导航锚点 `[立刻试用](#quickstart)`）、`:61-78`（`## Quickstart` 仍复述 AI 提示词流）。替换后首页第一视觉位置必须是类似 `superpowers` 的安装矩阵，至少列出 `Claude Code`、`Codex CLI`、`Codex App`、`Factory Droid`、`Gemini CLI`、`OpenCode`、`Cursor`、`GitHub Copilot CLI`，并在主矩阵之外保留 `Kiro / 通用 agent` 说明。
- [ ] 步骤2: 每个小节区分 **live**（已上架，现在时命令）与 **pending**（工程就绪、平台审核中）。初始实现时多数 harness 为 pending；**T10/T11 完成后**须回改 README 把已上架 harness 改为 live 措辞（FR3）。
- [ ] 步骤3: `Claude / Cursor / Codex` 小节要正确引用现有 repo-side 资产与边界：Claude 对应 `.claude-plugin/*`，Cursor 对应 `.cursor-plugin/plugin.json`，Codex 对应 `plugins/sandtable/.codex-plugin/plugin.json` 与 `.agents/plugins/marketplace.json`；其中 Codex 本地 marketplace 路径可保留为开发/本地路径，但不能冒充“官方已上线”。**Cursor 小节**：仓内仅有 `.cursor-plugin/plugin.json`、无 marketplace 上架证据时，不得用现在时写 `/add-plugin sandtable` 或“在 marketplace 搜索即可安装”；必须标“发布后可用”或指向下文 AI-assisted 路径。
- [ ] 步骤4: `OpenCode` 小节改成像 `superpowers` 一样的“看 `.opencode/INSTALL.md`”模式；`Gemini CLI` 小节明确对照根目录 `GEMINI.md` 与 `gemini-extension.json`。
- [ ] 步骤4b: `Factory Droid` / `GitHub Copilot CLI` 小节写 **Sandtable 专有** 命令（T8 完成后）：
  - `Claude Code`：**Official**（pending→`sandtable@claude-plugins-official`）+ **Community**（`andoop/sandtable-marketplace` 或仓内 `andoop/sandtable`）。
  - `Factory Droid`：`droid plugin marketplace add https://github.com/andoop/sandtable` + `droid plugin install sandtable@sandtable`。
  - `GitHub Copilot CLI`：`copilot plugin marketplace add andoop/sandtable-marketplace` + `copilot plugin install sandtable@sandtable-marketplace`（T9 独立仓就绪后）。
  - 禁止 `obra/superpowers-marketplace` / `superpowers@superpowers-marketplace`。
- [ ] 步骤5: 把当前两条官方中文/英文 AI 提示词与 `INSTALL.md` 下沉到 README 的次级/备用安装区域，明确这是“AI-assisted install / generic path”，仍可用于 `Kiro / 通用 agent` 或未走平台原生安装的场景。
- [ ] 步骤6: 验证步骤引用 `TC1` / `TC2` / `TC3` / `TC6` / `TC7` / `TC9`：人工检查首页第一眼是 harness 矩阵；`Kiro / 通用 agent` 仍在；`Claude / Cursor / Codex` 没回退；所有“发布后可用”边界措辞真实、不夸大。

### 任务 T2: 为 OpenCode 补齐 repo-side companion files

**文件:**
- 创建: `package.json`
- 创建: `.opencode/INSTALL.md`
- 创建: `.opencode/plugins/sandtable.js`

- [ ] 步骤1: 创建根 `package.json`，最小结构对齐 `superpowers/package.json` 的角色，只声明 OpenCode plugin 所需入口：
```json
{
  "name": "sandtable",
  "version": "0.1.0",
  "type": "module",
  "main": ".opencode/plugins/sandtable.js"
}
```
- [ ] 步骤2: 创建 `.opencode/INSTALL.md`，章节结构仿照 `superpowers/.opencode/INSTALL.md`：说明在 `opencode.json` 的 `plugin` 数组中添加 **Sandtable 本仓** Git URL（示例：`sandtable@git+https://github.com/andoop/sandtable.git`）；重启 OpenCode；用一个最小 Sandtable 触发语句验证扩展已生效；并明确“若同时使用其它 harness，需要分别安装”。禁止保留 `obra/superpowers` 或 `superpowers@git` 等 superpowers 专有 URL。
- [ ] 步骤3: 创建 `.opencode/plugins/sandtable.js`，实现与 `superpowers` 同类的三件事：把仓库根 `skills/` 注入 OpenCode 的 skills path；把 `skills/using-sandtable/SKILL.md` 的正文注入会话首条用户消息，形成 bootstrap；在 bootstrap 末尾注入 **OpenCode 工具映射**（参照 `superpowers/.opencode/plugins/superpowers.js:76-83`，至少覆盖 `Task` → OpenCode subagent、`TodoWrite` → `todowrite`、`Skill` → OpenCode `skill` 工具）。依据：Sandtable 推演 prompt 模板（`skills/mental-rehearsal/mental-rehearsal-prompt.md:6`、`skills/red-team-wargame/opfor-prompt.md:7`、`skills/implementation-rehearsal/implementation-rehearsal-prompt.md:6`）均绑定 `Task tool`，无映射则三类推演在 OpenCode 上断链。代码结构保持零依赖、ESM 风格，核心骨架如下：
```js
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const skillsDir = path.resolve(__dirname, "../../skills");
const bootstrapPath = path.join(skillsDir, "using-sandtable", "SKILL.md");

export const SandtablePlugin = async () => ({
  config: async (config) => {
    config.skills = config.skills || {};
    config.skills.paths = config.skills.paths || [];
    if (!config.skills.paths.includes(skillsDir)) config.skills.paths.push(skillsDir);
  },
  "experimental.chat.messages.transform": async (_input, output) => {
    // 读取 using-sandtable 内容并注入首条 user message，避免重复注入
  }
});
```
- [ ] 步骤4: 插件注入文案必须围绕 `using-sandtable` + 工具映射，而不是把整套技能或 README 摘要硬编码进 JS；读取失败时给出最小、诚实的 fallback，不伪造 skill 内容。
- [ ] 步骤5: 验证步骤引用 `TC4` / `TC9`：确认 `package.json`、`.opencode/INSTALL.md`、`.opencode/plugins/sandtable.js` 三者同时存在，路径相互引用自洽，README 的 OpenCode 小节也指向这些文件。

### 任务 T3: 为 Gemini CLI 补齐 repo-side companion files

**文件:**
- 创建: `GEMINI.md`
- 创建: `gemini-extension.json`
- 创建: `skills/using-sandtable/references/gemini-tools.md`

- [ ] 步骤1: 创建 `gemini-extension.json`，结构对齐 `superpowers/gemini-extension.json` 的角色，最小字段保持可读且自洽：
```json
{
  "name": "sandtable",
  "description": "Sandtable rehearsal-driven development workflow for coding agents",
  "version": "0.1.0",
  "contextFileName": "GEMINI.md"
}
```
- [ ] 步骤2: 创建 `GEMINI.md`，加载 `using-sandtable` 与 Sandtable 工具映射（对齐 `superpowers/GEMINI.md:1-2` 的双文件模式），例如：
```md
@./skills/using-sandtable/SKILL.md
@./skills/using-sandtable/references/gemini-tools.md
```
- [ ] 步骤3: 创建 `skills/using-sandtable/references/gemini-tools.md`，提供 Sandtable 自己的 Gemini 工具映射：至少把 `Task tool (subagent_type: …)` 映射到 `@generalist`（或 Gemini 等价 subagent），并覆盖 `TodoWrite`、`Skill` 等 Sandtable skills 中出现的 Claude 工具名。结构可参考 `superpowers/skills/using-superpowers/references/gemini-tools.md`，但 agent 名与示例必须 Sandtable 化（如 `explore`/`generalPurpose` readonly 推演），禁止保留 `superpowers:implementer` 等 superpowers 专有 agent 名。
- [ ] 步骤4: README 的 Gemini CLI 小节要把安装命令与这两个文件联动起来，避免出现“README 里说支持 Gemini，但仓库内没有任何 Gemini 落点”的伪支持状态。
- [ ] 步骤5: 验证步骤引用 `TC5` / `TC9`：确认 `GEMINI.md` 与 `gemini-extension.json` 都存在，字段自洽，README 的 Gemini 小节能回指到这两个 companion files。

### 任务 T4: 重写 INSTALL.md 为次级/备用路径，并保持现有护栏

**文件:**
- 修改: `INSTALL.md`

- [ ] 步骤1: 在 `INSTALL.md` 开头明确它不再承担 README 首页主入口角色，而是“AI-assisted / generic install path”的详细说明；保留当前两条官方中文/英文提示词、语言判断规则、locale-pack 预检与不覆盖安装护栏。
- [ ] 步骤2: 把 `INSTALL.md` 的受众描述调整为：当用户不走 harness 原生安装路径、或使用 `Kiro / 通用 agent`、或平台侧尚未上架时，可使用本文件引导 AI 进行项目内安装。
- [ ] 步骤3: 对 `Claude / Cursor / Codex` 的现有说明做层级整理：官方 / 平台路径与本地开发路径分开写，确保与新 README 的主矩阵不冲突；其中 Codex 本地 workspace marketplace 继续保留，但标成本地/开发路径，而不是官方默认路径。
- [ ] 步骤3b: 重写 `INSTALL.md` §5.2「按 harness 接线」的层级：在节首明确这是 **AI-assisted 项目内文件复制**，不是 README 主矩阵中的 harness-native 安装；各 harness 小节开头加一句「harness-native 安装见 README §Installation 对应小节」。避免 README 写 marketplace/插件而 INSTALL §5.2 仍写向用户项目复制 `.cursor/*` 且无交叉标注（TC9）。
- [ ] 步骤4: 明确 `Kiro / 通用 agent` 仍走 `AGENTS.md` + `commands/*.md` 的通用行为基线；这条路径继续被支持，但在整份文档中的优先级低于 README 主矩阵中的 harness-native 路径。
- [ ] 步骤5: 保持现有中英安装提示词、locale-pack 预检、`scripts/test-sandtable-init.sh` 不安装、以及“不覆盖已有文件即报告不完整”的规则不漂移，不因为 README 改版而回退。
- [ ] 步骤6: 验证步骤引用 `TC2` / `TC3` / `TC6` / `TC8` / `TC9`：确认 AI-assisted 路径仍存在但已降级；`Kiro / 通用 agent` 仍可用；双语与不覆盖护栏都还在；README 与 INSTALL 对同一 harness 的说法不矛盾。

### 任务 T5: 一致性与诚实性总复核

**文件:**
- 修改: `README.md`
- 修改: `INSTALL.md`
- 创建: `package.json`
- 创建: `.opencode/INSTALL.md`
- 创建: `.opencode/plugins/sandtable.js`
- 创建: `GEMINI.md`
- 创建: `gemini-extension.json`
- 创建: `skills/using-sandtable/references/gemini-tools.md`

- [ ] 步骤1: 对照 `TC1`–`TC9` 逐条人工验收，特别检查：
  - 首页是否真的已从 AI-first 改成 harness-first。
  - `OpenCode` / `Gemini CLI` 是否有真实 repo-side 文件。
  - `Claude / Cursor / Codex / Kiro / 通用 agent` 是否被意外回退。
  - 文档是否把“发布后可用”写成了“现在可用”。
- [ ] 步骤2: 运行定点文本检查：
  - `rg -n "Claude Code|Codex CLI|Codex App|Factory Droid|Gemini CLI|OpenCode|Cursor|GitHub Copilot CLI|Kiro|通用 agent" README.md INSTALL.md`
  - `rg -n "发布后可用|上架后可用|官方提示词|INSTALL.md|Kiro|通用 agent" README.md INSTALL.md`
  - `rg -n "obra/superpowers-marketplace|superpowers@superpowers-marketplace|superpowers@git|obra/superpowers" README.md INSTALL.md .opencode/ GEMINI.md skills/using-sandtable/references/gemini-tools.md`
  - `rg -n "using-sandtable|skills.paths|experimental.chat.messages.transform|Tool Mapping|Task" .opencode/plugins/sandtable.js`
  - `rg -n "contextFileName|GEMINI.md" gemini-extension.json`
  - `rg -n "gemini-tools|Task tool|@generalist" GEMINI.md skills/using-sandtable/references/gemini-tools.md`
  - 负向：`rg -n "立刻试用|Quickstart" README.md` 的首屏区（矩阵之前）应无 AI-first 提示词块；`/add-plugin sandtable` 若出现，同节或相邻须伴「发布后可用」
  预期：支持矩阵完整出现；诚实边界措辞存在；不得出现 superpowers 专有标识；OpenCode bootstrap 含工具映射；Gemini 双文件加载；README 首屏非 AI-first。
- [ ] 步骤3: 对新增 JSON 做语法检查，对新增 JS 做最小静态检查；若本地环境没有对应工具，需在 `journal.md` 如实记录“未运行何种检查以及原因”，不能跳过不报。

---

## Phase 2 · 发布基础设施

### 任务 T6: 版本同步工具链

**文件:**
- 创建: `.version-bump.json`
- 创建: `scripts/bump-version.sh`

- [ ] 步骤1: 创建 `.version-bump.json`，声明须同步的文件（adapt superpowers 列表至 Sandtable 路径）：
  - `package.json` → `version`
  - `.claude-plugin/plugin.json` → `version`
  - `.cursor-plugin/plugin.json` → `version`
  - `plugins/sandtable/.codex-plugin/plugin.json` → `version`
  - `gemini-extension.json` → `version`
  - **不写** marketplace 插件条目 version（单一来源 = plugin.json，对标 easy-install 决策）
- [ ] 步骤2: 创建 `scripts/bump-version.sh`（可从 superpowers 改编），支持 `./scripts/bump-version.sh patch|minor|major`。
- [ ] 步骤3: 验证：bump 后 `rg '"version"'` 各 manifest 一致；`bash -n scripts/bump-version.sh`。
- [ ] 步骤4: 验证引用 `TC10`。

### 任务 T7: Codex 官方 marketplace 同步脚本

**文件:**
- 创建: `scripts/sync-to-codex-plugin.sh`

- [ ] 步骤1: 从 `superpowers/scripts/sync-to-codex-plugin.sh` 改编，关键差异：
  - `DEST_REL="plugins/sandtable"`（OpenAI marketplace 侧路径）
  - **源目录** = 本仓 `plugins/sandtable/`（含 `.codex-plugin/`、`commands/`、`skills/`），而非仓库根
  - `FORK` 默认 `andoop/openai-codex-plugins` 或 Q5 确认的 fork（须 journal 记录）
  - EXCLUDES 排除主仓 `.claude-plugin/`、`.cursor-plugin/`、`.opencode/`、`docs/sandtable/` 等
- [ ] 步骤2: 支持 `-n` dry-run、`--bootstrap` 首次创建目标目录。
- [ ] 步骤3: 在 `docs/PUBLISHING.md`（T8）记录：需 `gh` 认证、fork 权限、PR 模板。
- [ ] 步骤4: 验证：`-n` dry-run 无报错；引用 `TC11`。

---

## Phase 3 · Marketplace 仓与平台上架

### 任务 T8: 发布 runbook

**文件:**
- 创建: `docs/PUBLISHING.md`

- [ ] 步骤1: 写发版总流程：bump version → 更新 CHANGELOG（若有）→ 按 harness checklist 发布。
- [ ] 步骤2: 分 harness 小节（mirror superpowers README 结构）：Claude official/community、Codex official、Codex App、Cursor submit、Copilot marketplace 仓、Droid、Gemini、OpenCode。
- [ ] 步骤3: 每节含：前置账号、命令、验证 smoke test、README 从 pending→live 的更新模板。
- [ ] 步骤4: 维护 `docs/sandtable/features/.../state.md` 中的 **发布状态表**（可选列：harness / live / PR链接 / 验证日期）。
- [ ] 步骤5: 验证引用 `TC14`。

### 任务 T9: 独立 `sandtable-marketplace` 仓

**文件:**
- 创建: `templates/sandtable-marketplace/.claude-plugin/marketplace.json`
- 创建: `templates/sandtable-marketplace/README.md`

- [ ] 步骤1: Scaffold 镜像 `obra/superpowers-marketplace`：
```json
{
  "name": "sandtable-marketplace",
  "owner": { "name": "andoop" },
  "metadata": { "description": "Sandtable plugin marketplace" },
  "plugins": [{
    "name": "sandtable",
    "source": { "source": "url", "url": "https://github.com/andoop/sandtable.git" },
    "description": "...",
    "strict": true
  }]
}
```
- [ ] 步骤2: README 含 Copilot + Claude community 安装命令。
- [ ] 步骤3: **执行发布**：在 GitHub 创建 `andoop/sandtable-marketplace` 并 push scaffold（需 maintainer 权限）。
- [ ] 步骤4: Smoke test：`copilot plugin marketplace add andoop/sandtable-marketplace`（或 Claude `/plugin marketplace add`）——结果记入 journal。
- [ ] 步骤5: 回改 T1 README Copilot/Claude community 小节为 live 或 pending+PR 链接；验证 `TC12`。

### 任务 T10: Claude official + Cursor 官方上架

**文件:**
- 修改: `.cursor-plugin/plugin.json`
- 修改: `README.md`（上架后）
- 可选: `.claude-plugin/marketplace-dev.json` 或文档说明 dev marketplace

- [ ] 步骤1: 完善 `.cursor-plugin/plugin.json`：补 `homepage`、`repository`（对标 superpowers cursor manifest）。
- [ ] 步骤2: **Cursor 官方提交**：按 cursor.com/marketplace/publish 提交 `.cursor-plugin/plugin.json` 所在仓；journal 记录 ticket/状态。
- [ ] 步骤3: **Anthropic 官方 listing 申请**（目标 `sandtable@claude-plugins-official`）：按 Anthropic 插件市场流程申请；journal 记录。
- [ ] 步骤4: 上架成功后 README Cursor 小节改为 `/add-plugin sandtable` 现在时；Claude official 小节改为 `@claude-plugins-official` 命令。
- [ ] 步骤5: 验证 `TC13` / `TC7`（live harness 不得仍标 pending）。

### 任务 T11: Codex official PR + 其余 harness smoke test

**文件:**
- 执行: `scripts/sync-to-codex-plugin.sh`
- 修改: `README.md`（Codex 上架后）

- [ ] 步骤1: 运行 `sync-to-codex-plugin.sh` 向 Q5 确认的 fork 开 PR；journal 记录 PR URL。
- [ ] 步骤2: PR merge 后 smoke test：Codex CLI `/plugins` 搜索 `sandtable`；Codex App Plugins  sidebar。
- [ ] 步骤3: Smoke test Gemini（`gemini extensions install https://github.com/andoop/sandtable`）、OpenCode（`.opencode/INSTALL.md` 流程）、Factory Droid（repo URL marketplace）。
- [ ] 步骤4: 通过的 harness 更新 README 为 live；未通过标 pending + journal 阻塞原因。
- [ ] 步骤5: 验证 `TC11` / `TC13`。

---

## Phase 4 · 总验收

### 任务 T12: 完整 parity 总复核

**文件:** 全部 T1–T11 产物

- [ ] 步骤1: 对照 `TC1`–`TC14` 与 PRD §6.1/§6.2 两档验收。
- [ ] 步骤2: 扩展 T5 的 `rg` 至 `docs/PUBLISHING.md`、`scripts/`、`templates/sandtable-marketplace/`。
- [ ] 步骤3: 发布状态表：每个 harness 标注 live/pending/blocked。
- [ ] 步骤4: 确认 Claude `/plugin update sandtable` 在 bump version 后可拉新版本（easy-install 版本模型）。

---

## 任务与 TC 映射
- `TC1`–`TC9` → `T1`–`T5`, `T12`
- `TC10` → `T6`, `T12`
- `TC11` → `T7`, `T11`, `T12`
- `TC12` → `T9`, `T12`
- `TC13` → `T10`, `T11`, `T12`
- `TC14` → `T8`, `T12`

## 计划红线复核
- 目标已扩大为含 marketplace 发布（Q4）；工程 DONE ≠ 全部平台 live，但 checklist 必须可执行。
- 不删除或回退现有 `Claude / Cursor / Codex / Kiro / 通用 agent` 路径。
- 不回退 `INSTALL.md` 双语与不覆盖护栏。
- 不重新引入 Cursor `.cursor-plugin/marketplace.json`（`source:"."`）。
- Codex sync 适配 nested 布局，不整仓重构目录。
