# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/预演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-06 12:43 · [决策] 立项：Superpowers harness parity
- 背景：开发者在 `/sandtable-start` 中提出“模仿 superpowers，支持它支持的、并按它一样的方式支持各种 AI agent 安装自己”。
- 内容：判定这不是对现有某个已完成 feature 的小修，而是一个新的安装/分发范围需求，单独建立 `2026-06-06-superpowers-harness-parity/` 目录推进。
- 依据/来源：开发者原话；目标项目根经确认是 `sandtable/` 仓库本身。

## 2026-06-06 12:45 · [问答+决策] 目标项目根确认
- 背景：当前工作区同时包含 `sandtable/` 与 `superpowers/`，若项目根判断错误，后续 RECON / PRD / plan 都会落错位置。
- 内容：开发者明确选择 `1`，即把 `sandtable/` 仓库本身作为本轮 Sandtable 流程的目标项目根。
- 依据/来源：开发者答复“1”。

## 2026-06-06 12:46 · [决策] RECON 摘要与阻塞点成形
- 背景：进入 OBJECTIVES 前，对照 `sandtable` 与 `superpowers` 的安装面做第一轮情报侦察。
- 内容：
  - `sandtable` 当前 README / INSTALL 的默认路径是“把官方提示词发给 AI，让 AI 读取 `INSTALL.md` 安装”，显式支持对象主要是 `Cursor / Claude Code / Codex / Kiro / 通用 agent`。来源：`README.md:10-20`、`README.md:61-78`、`INSTALL.md:3-39`、`INSTALL.md:174-223`。
  - `sandtable` 当前仓库已有部分 harness 资产：`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json`、`.cursor-plugin/plugin.json`、`plugins/sandtable/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json`、`hooks/*`。来源：`.claude-plugin/plugin.json:1-24`、`.claude-plugin/marketplace.json:1-19`、`.cursor-plugin/plugin.json:1-18`、`plugins/sandtable/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json`、`hooks/hooks.json:1-16`、`hooks/hooks-cursor.json:1-10`。
  - `sandtable` 目前没有 `package.json`、没有 `.opencode/`，仓库内也没有 `gemini extensions` / `copilot plugin` / `droid plugin` / `Codex App` 相关接线资产或文案。来源：对 `sandtable/` 的 `package.json`、`.opencode/**`、`.github/**` glob 结果为空；以及仓内针对 `opencode|gemini extensions|copilot plugin|droid plugin|Codex App|Codex CLI` 的全文检索结果。
  - `superpowers` 则把安装支持矩阵明确写成 `Claude Code`、`Codex CLI`、`Codex App`、`Factory Droid`、`Gemini CLI`、`OpenCode`、`Cursor`、`GitHub Copilot CLI`，并按 harness 分别提供 marketplace / extension / plugin 安装方式。来源：`../superpowers/README.md:31-152`。
  - `superpowers` 仓库还存在 `package.json`、`.opencode/INSTALL.md`、`.opencode/plugins/superpowers.js`、`.claude-plugin/*`、`hooks/*` 等配套资产，说明其“多 harness 安装自己”的实现不仅是文案层。来源：`../superpowers/package.json:1-6`、`../superpowers/.opencode/INSTALL.md:1-111`、`../superpowers/.opencode/plugins/superpowers.js:1-135`、`../superpowers/.claude-plugin/plugin.json:1-20`、`../superpowers/.claude-plugin/marketplace.json:1-20`、`../superpowers/hooks/session-start:1-57`、`../superpowers/hooks/run-hook.cmd:1-46`。
- 结论：若按“完全跟 superpowers 对齐”推进，至少会影响支持矩阵、README / INSTALL 主叙事、以及多个 harness 的 repo-side 接线资产；其中有些安装路径可能依赖仓库外的 marketplace 发布状态，不能由主 agent 擅自假定。
- 依据/来源：上述所有核读结果。

## 2026-06-06 12:49 · [问答+决策] 开发者确认范围分歧
- 背景：`Q1/Q2/Q3` 会直接决定本轮 PRD、tests、plan 的边界，不能由主 agent 猜测。
- 内容：
  - 支持矩阵采用 `superpowers` 当前 8 个对象，并额外保留 `Kiro / 通用 agent` 作为 Sandtable 附加支持对象。
  - README 主安装叙事改为像 `superpowers` 一样的 harness-first 安装矩阵；“让 AI 读取 INSTALL.md 自助安装”降为次级路径。
  - 本轮只要求 repo-side 资产与文档对齐；凡依赖官方 marketplace / 平台上架的路径，文档必须诚实表述为“发布后可用”或等义状态，不把仓外发布动作算作本轮实现内容。
- 依据/来源：开发者对 `Q1/Q2/Q3` 的直接答复。

## 2026-06-06 12:50 · [决策] 补充侦察：Gemini parity 需要真实 repo-side 资产
- 背景：为把“完全跟 superpowers 对齐”写成可执行 PRD，继续核查各 harness 在 `superpowers` 中究竟是纯文档支持还是包含仓库内接线文件。
- 内容：
  - `superpowers` 的 `Gemini CLI` 不只是 README 文案，它还有根目录 `GEMINI.md` 与 `gemini-extension.json`，说明 Gemini parity 至少包含 repo-side companion files，而不只是安装命令文案。
  - `sandtable` 当前不存在 `GEMINI.md` 或 `gemini-extension.json`，因此若要向 `superpowers` 对齐，Gemini 不能只靠 README 加一句命令。
  - `superpowers` 的 `OpenCode` 还包含 `package.json`、`.opencode/INSTALL.md`、`.opencode/plugins/superpowers.js`；而 `sandtable` 当前没有 `package.json`、也没有 `.opencode/` 目录。
- 依据/来源：`../superpowers/GEMINI.md:1-2`、`../superpowers/gemini-extension.json:1-6`、`../superpowers/package.json:1-6`、`../superpowers/.opencode/INSTALL.md:1-18`、`../superpowers/.opencode/plugins/superpowers.js:1-135`；`sandtable/` 下 `GEMINI.md`、`gemini-extension.json`、`package.json`、`.opencode/**` glob 结果为空。

## 2026-06-06 12:53 · [决策] PRD / tests / plan 已落地
- 背景：`Q1/Q2/Q3` 已获开发者答复，阻塞解除，可以正式完成 `/sandtable-start` 的前五步文档产物。
- 内容：
  - 已写出 `prd.md`：把本轮目标固定为“README 改成 harness-first，主矩阵镜像 superpowers 当前 8 个对象，并额外保留 Kiro / 通用 agent；本轮只做 repo-side 与文档对齐，发布状态诚实表述”。
  - 已写出 `tests.md`：重点守住 README 主入口切换、OpenCode/Gemini 必须有真实 repo-side companion files、现有 Claude/Cursor/Codex/Kiro/通用 agent 不回退、以及“发布后可用”措辞不说谎。
  - 已写出 `plan.md`：拆成 5 个任务，分别覆盖 README 改造、OpenCode companion files、Gemini companion files、INSTALL 次级路径整理、以及一致性总复核。
  - `state.md` 已推进到 `MENTAL_REHEARSAL`，准备进入下一阶段的头脑预演。
- 本轮完成标准只包含 repo-side 资产与文档对齐；凡依赖官方 marketplace / 上架状态的能力，必须诚实写成“发布后可用”。

## 2026-06-06 13:10 · [推演] 头脑预演 #1 — LOGIC_CLOSED
- 背景：子 agent 多次被中断，改由主 agent 亲自完成只读逻辑推演。
- 内容：
  - 发现 1 处 ANOMALY：`plan.md` T1 未禁止 README 照抄 `superpowers` 的 `obra/superpowers-marketplace` Copilot 命令，而 `sandtable` 只有仓内 `.claude-plugin/marketplace.json`（`andoop/sandtable`）。
  - 已修正：`plan.md` 新增 T1 步骤 4b；`tests.md` TC7 增补禁止 superpowers 专有 marketplace 标识。
  - 修正后四条链路（README 主叙事、INSTALL 次级、OpenCode bootstrap、Gemini bootstrap）均闭环；残余风险仅为 OpenCode/Gemini 默认中文 bootstrap、Cursor/Copilot/Droid 平台侧上架状态未实测。
- 依据/来源：`rehearsals/mental-1.md`；核读 `superpowers/README.md:145-151`、`.claude-plugin/marketplace.json`、`hooks/session-start`、`skills/using-sandtable/SKILL.md`。

## 2026-06-06 13:18 · [推演] 头脑预演 #2 — LOGIC_CLOSED
- 背景：开发者再次触发 `/sandtable-mental`；对 mental-1 修正后的 plan/tests 做交叉验证。
- 内容：
  - 发现 1 处 verification gap：T5 步骤 2 未包含对 `obra/superpowers-marketplace` 的负向 rg，与 TC7/T1 步骤 4b 不对齐。
  - 已修正：`plan.md` T5 步骤 2 增补负向检查。
  - 复验四条主链路与 TC1–TC9 均闭环；OpenCode 导出命名与 superpowers 同模式（`SandtablePlugin`）。
- 依据/来源：`rehearsals/mental-2.md`；核读 `superpowers/.opencode/plugins/superpowers.js:55`、`plan.md` T5。

## 2026-06-06 14:05 · [推演] 红蓝对抗 #1 — BREACH_FOUND → 已修正
- 背景：3 路 OPFOR 子 agent 并行攻击 `plan.md`；主 agent 亲自核实全部杀招成立。
- 内容：
  - ANOMALY-1/2：OpenCode/Gemini 缺 `Task tool` 映射，三类推演会断链；已要求 T2 注入 mapping、T3 创建 `gemini-tools.md`。
  - ANOMALY-3：T1 未强制移除 `README.md:10-20,45,61-78` AI-first 块；已点名必改。
  - ANOMALY-4：Cursor `/add-plugin` 无 Q3 guard；T1 步骤 3 已补。
  - ANOMALY-5：INSTALL §5.2 与 README 互斥；T4 步骤 3b 已补交叉引用。
  - ANOMALY-6：T5/TC7 扫描范围过窄；已扩至 companion files。
  - 纠正：`mental-1.md:45-50`「无需工具映射」断言作废。
- 依据/来源：`rehearsals/redteam-1.md`；OPFOR 子 agent 战报 + 主 agent 核读 `sandtable/skills/*/*-prompt.md`、`superpowers/.opencode/plugins/superpowers.js:76-83`、`superpowers/GEMINI.md`。

## 2026-06-06 15:00 · [决策] 范围扩展 — 完整 superpowers 对齐 + marketplace 发布
- 背景：开发者要求「完整方案、完整一样跟 Superpowers，还有插件发布到市场等」；原 Q3=A 作废。
- 内容：
  - 更新 `prd.md`：新增 FR8–FR14（版本 bump、Codex sync、独立 marketplace 仓、Claude/Cursor 官方上架、PUBLISHING runbook）；验收分两档（工程 DONE / 平台 live DONE）。
  - 更新 `plan.md`：T6–T12 分 Phase 2–4（发布基础设施、marketplace 仓与上架、总验收）；T1 步骤 4b 指向 `andoop/sandtable-marketplace`。
  - 更新 `tests.md`：TC7 修订为 pending/live 一致；新增 TC10–TC14。
  - 新增 Q5（Codex fork 目标）、Q6（Anthropic official 账号）待答。
- 侦察依据：superpowers 有 `sync-to-codex-plugin.sh`、`.version-bump.json`、`obra/superpowers-marketplace` 独立仓、官方 Claude/Codex/Cursor listing；sandtable 均缺。
- 历史约束保留：不重新引入 Cursor `.cursor-plugin/marketplace.json`（source:"." drop）；Codex 保持 nested `plugins/sandtable/` 布局。

## 2026-06-06 · [澄清] 开发者无任何平台账号 — 账号与路径指南
- 开发者问：现在都没有账号，怎么弄？
- 结论：
  - **只需 GitHub** 即可覆盖 5/8 harness 分发（Claude 自建 marketplace、Copex repo marketplace、Copilot marketplace 仓、Gemini、OpenCode、Droid）。
  - **Claude official**（`@claude-plugins-official`）第三方不可申请；submission 表单 → community，非 official。
  - **Codex official** 需 OpenAI Platform + Apps SDK 审核；自助 plugin 发布 coming soon。
  - **Cursor official** 需 Cursor 账号 + cursor.com/marketplace/publish 人工审核。
  - 建议顺序：GitHub → 工程 T1–T9 → Claude.ai 免费账号提 community → Cursor 提交 → 日后 OpenAI Platform。
- 详见本次对话「账号清单与操作顺序」。

## 2026-06-06 · [终止] 开发者取消本 feature
- 背景：开发者要求终止 `2026-06-06-superpowers-harness-parity`。
- 结果：`state.md` → `CANCELLED`；T1–T12 全部 `cancelled`；Q5/Q6 作废。
- 事实：**无 sandtable 主仓代码改动**；仅保留本目录文档与推演记录供日后参考。
- 当前 sandtable 安装体验不变：仍为 AI-first README + `INSTALL.md` + 现有 Claude/Cursor/Codex 插件资产（easy-install 已交付部分）。
