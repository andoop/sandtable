# Superpowers 式多 harness 安装与发布对齐 · PRD

> **状态：已终止（2026-06-06）** — 开发者取消本 feature；下文为终止前草案，**非生效需求**。

> 对应 `project.md` 北极星 / 继承 `constraints.md` 红线。实现细节见 `plan.md`。

## 1. 目标
让 `sandtable` 在「如何让各种 AI agent 安装自己」这件事上，**完整对齐** `superpowers`：README 以 harness-first 安装矩阵为主入口；repo 内补齐全部 companion files 与发布工具链；**把插件发布到各 harness 对应的 marketplace / 官方目录**，使用户能像 superpowers 一样一行安装、搜索安装、官方 marketplace 安装。主矩阵覆盖 `superpowers` 当前 8 个对象，并额外保留 `Kiro / 通用 agent`。

**范围变更（2026-06-06）：** 开发者将 Q3 从「仅 repo-side + 诚实标注发布后可用」升级为「完整方案含 marketplace 发布」。原 Q3=A 作废，见 `questions.md` Q4。

## 2. 背景与现状
- `sandtable` README 仍为 AI-first（`README.md:10-20,61-78`），与 `superpowers/README.md:31-152` harness-first 矩阵不一致。
- **已有：** `.claude-plugin/{plugin,marketplace}.json`、`.cursor-plugin/plugin.json`、`plugins/sandtable/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json`（Codex 本地 dev）。
- **缺失（相对 superpowers）：** 根 `package.json`、`.opencode/**`、`GEMINI.md`、`gemini-extension.json`、`gemini-tools.md`、`.version-bump.json`、`scripts/bump-version.sh`、`scripts/sync-to-codex-plugin.sh`、独立 Copilot marketplace 仓、`docs/PUBLISHING.md`、各平台实际上架。
- **superpowers 发布三层（须镜像）：**
  1. **官方平台 listing**：Claude `@claude-plugins-official`、Codex `openai/plugins`、Cursor 官方 marketplace `/add-plugin`。
  2. **独立 community marketplace 仓**：`obra/superpowers-marketplace`（Claude community + Copilot CLI）。
  3. **仓内 dev marketplace**：`.claude-plugin/marketplace.json`（`superpowers-dev`，`source: "./"`）；Sandtable 已有同仓 `sandtable@sandtable`（github 源）。
- **历史决策：** 2026-06-02 easy-install 曾 drop `.cursor-plugin/marketplace.json`（`source:"."` 不可用）；Cursor 公共市场须**官方提交审核**，不能靠仓内 marketplace.json 免审一行装。

## 3. 方案探索
- **方案 A（已作废）：** 仅 repo-side + 文档，marketplace 写「发布后可用」。—— 不符合开发者新指令。
- **方案 B：repo-side + 发布工具链 + runbook，平台上架由维护者按 checklist 执行。** —— 可交付大部分工程产物；官方审核/合并仍属仓外动作，但 README 在上架完成后须改为现在时。
- **方案 C：本轮必须全部平台上架完成才算 DONE。** —— 依赖 Anthropic/Cursor/OpenAI 审核周期，无法单靠代码保证；作为北极星，拆成「工程 DONE」与「平台上架 DONE」两档验收。

**推荐：方案 B + 方案 C 作为最终北极星。** 工程侧一次性补齐 superpowers 同级资产与脚本；平台上架按 `docs/PUBLISHING.md` checklist 逐项完成，完成后更新 README 措辞与 `state.md` 发布状态表。

## 4. 用户故事 / 场景
- 作为新用户，我希望 README 像 superpowers 一样按 harness 安装，而不是先理解 AI 提示词。
- 作为 Claude Code 用户，我希望 `/plugin install sandtable@claude-plugins-official` 或 community marketplace 一行装好。
- 作为 Codex 用户，我希望在 `/plugins` 搜索 `sandtable` 并安装（官方 marketplace）。
- 作为 Cursor 用户，我希望 `/add-plugin sandtable` 或 marketplace 搜索（官方上架后）。
- 作为 Copilot CLI 用户，我希望 `copilot plugin marketplace add andoop/sandtable-marketplace` + install（独立 marketplace 仓，同 superpowers 模式）。
- 作为维护者，我希望 `scripts/bump-version.sh` + `sync-to-codex-plugin.sh` 与 superpowers 一样可重复发版。

## 5. 功能需求

### 5.1 安装体验（原 FR1–FR7，保留并强化）
- **FR1：** README harness-first 矩阵 + 保留 `Kiro / 通用 agent`；AI-assisted 降为次级。
- **FR2：** OpenCode / Gemini / 现有 Claude·Cursor·Codex repo-side 资产齐全且 README 自洽。
- **FR4：** 双语 `INSTALL.md` 与不覆盖护栏保留。
- **FR5：** 现有 Claude/Cursor/Codex 资产不回退。
- **FR6：** OpenCode companion files **含工具映射**（`Task` 等）。
- **FR7：** Gemini companion files **含 `gemini-tools.md`**。

### 5.2 发布与 marketplace（新增）
- **FR8（版本同步）：** 提供 `.version-bump.json` + `scripts/bump-version.sh`，同步至少：`package.json`、`.claude-plugin/plugin.json`、`.cursor-plugin/plugin.json`、`plugins/sandtable/.codex-plugin/plugin.json`、`gemini-extension.json`、marketplace 插件条目（若适用）。
- **FR9（Codex 官方发布管线）：** 提供 `scripts/sync-to-codex-plugin.sh`（adapted for `plugins/sandtable/` 布局），向 `openai/plugins` 生态提交 PR；README Codex CLI/App 小节对齐 superpowers 官方 marketplace 叙事。
- **FR10（独立 community marketplace 仓）：** 创建并发布 `andoop/sandtable-marketplace`（结构镜像 `obra/superpowers-marketplace`），供 **GitHub Copilot CLI** 与 Claude community 路径使用；README 写 Sandtable 专有命令，禁止 superpowers 标识。
- **FR11（Claude 双路径）：** 保留仓内 `andoop/sandtable` → `sandtable@sandtable`；文档增加 Anthropic 官方 marketplace 申请路径（目标：`sandtable@claude-plugins-official`）；可选增加 dev marketplace 别名（`sandtable-dev`，`source: "./"`）供维护者本地验证。
- **FR12（Cursor 官方上架）：** 完善 `.cursor-plugin/plugin.json`（homepage、repository 等）；执行 Cursor 官方 marketplace 提交；上架后 README 写 `/add-plugin sandtable`。
- **FR13（Factory Droid / Gemini / OpenCode）：** Droid 直接 repo URL marketplace；Gemini `extensions install`；OpenCode git plugin URL——三者在 repo-side 就绪后 README 用 superpowers 同级命令（`andoop/sandtable`）。
- **FR14（发布 runbook）：** `docs/PUBLISHING.md` 含 8 harness + 发版 checklist、平台账号前置条件、上架后 README 更新步骤。

### 5.3 诚实表述（修订 FR3）
- **FR3：** 在平台上架**完成前**，README 对该 harness 标 pending/申请中；**上架完成后**，README 须改为 superpowers 同级的现在时安装命令，并移除该 harness 的「待发布」措辞。禁止永久保留虚假的「发布后可用」当已上架时；禁止未上架时写现在时。

## 6. 验收标准（两档）

### 6.1 工程验收（INTEGRATE 可勾选）
- [ ] README harness-first；OpenCode/Gemini companion files 含工具映射。
- [ ] `.version-bump.json` + `bump-version.sh` 可运行；版本字段一致。
- [ ] `sync-to-codex-plugin.sh` 存在且 dry-run 可执行（或 journal 记录阻塞原因）。
- [ ] `sandtable-marketplace` 仓 scaffold 已创建并 push；Copilot/Claude community 命令可指向它。
- [ ] `docs/PUBLISHING.md` 覆盖全部 harness 发版流程。
- [ ] 无 superpowers 专有 marketplace 标识渗入 Sandtable 产物。

### 6.2 平台上架验收（最终 DONE）
- [ ] Claude：官方和/或 community marketplace 至少一条路径对用户一行可装。
- [ ] Codex：官方 `openai/plugins` 中可搜索 `sandtable` 并安装。
- [ ] Cursor：官方 marketplace 可 `/add-plugin sandtable` 或搜索安装。
- [ ] Copilot CLI：`sandtable-marketplace` 已发布且 install 命令 verified。
- [ ] Gemini / OpenCode / Factory Droid：README 命令经至少一次人工 smoke test。
- [ ] README 各 harness 措辞与实际上架状态一致。

## 7. MUST
- 完整 mirror superpowers 8 harness 安装矩阵 + 保留 Kiro/通用 agent。
- 补齐 repo-side companion files **与** 发布工具链 **与** marketplace 发布（工程 + 执行 checklist）。
- 独立 `sandtable-marketplace` 仓（Copilot 必需；不得长期依赖 `obra/superpowers-marketplace`）。
- 保留双语 INSTALL 与不覆盖护栏。
- 发版必须 bump 统一版本；禁止 marketplace 与 plugin.json 双写 version 导致 update 空转。

## 8. MUST NOT
- 不删除/破坏现有 Claude/Cursor/Codex/Kiro/通用 agent 路径。
- 不复制 superpowers 专有 marketplace 名/URL/agent 名。
- 不为 Cursor 重新引入已证明不可用的 `.cursor-plugin/marketplace.json`（`source:"."`）作为公共一行装方案。
- 不把 Codex 官方 sync 伪装成已完成 PR merge（须如实记录 PR 状态）。
- 不引入新的第三方 npm 运行时依赖（OpenCode plugin 仍零依赖）。

## 9. 非目标
- 不改 Sandtable 方法论状态机/推演语义。
- 不把 Kiro/通用 agent 做成新插件协议。
- 不在主仓重构为 `plugins/sandtable/`  monorepo 根布局（Codex 保持 nested；sync 脚本适配 nested）。

## 10. 未决问题
见 `questions.md` Q5–Q6（Codex fork 目标、Anthropic 官方 listing 账号）。不阻塞 plan 编写，阻塞对应 T9/T10 **执行**。
