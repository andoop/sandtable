# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/预演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-06 19:50 · [决策] INTAKE 受领需求
- 背景：在回答"已安装用户怎么更新"时发现 Sandtable 无更新机制；开发者要求"做吧"。
- 内容：为 Sandtable 增加"已安装用户的更新机制"——能把已装项目里的方法论资产升级到最新，同时**绝不触碰**用户运行时 `docs/sandtable/`。
- 依据/来源：开发者本回合指令；上一轮关于更新方法的对话。

## 2026-06-06 19:55 · [侦察] RECON 情报简报
- 已确认事实（带来源）：
  - `INSTALL.md` 是 **AI 驱动**安装：读 INSTALL.md 按指令复制；**铁律"目标已存在即跳过、绝不覆盖"**，并有 locale-pack 整包预检（任一已存在即报冲突）。`[已确认: INSTALL.md:43-47, 101-123]`
  - 因此**重跑安装提示词无法更新**：已安装路径全被跳过/报"语言包冲突·安装不完整"。`[已确认: INSTALL.md:119-123]`
  - 安装区分 **zh / en 两个 locale pack**（zh 源在仓库根，en 源在 `locales/en/`），由两条官方提示词正文精确匹配决定语言。`[已确认: INSTALL.md:25-39, 60-92]`
  - 方法论资产 vs 运行时记忆：**资产**=`skills/ commands/ .cursor/commands .cursor/rules/sandtable.mdc AGENTS.md templates/ plugins/sandtable/{skills,commands} scripts/sandtable-init.sh hooks/* plugins/sandtable/.codex-plugin/plugin.json .agents/plugins/marketplace.json`；**运行时**=`docs/sandtable/`（project/constraints/lessons/features…）。`[已确认: INSTALL.md §3]`
  - 仓库**无** `UPDATE.md`、无版本号/VERSION 标记、无 `sandtable-update` 脚本/命令。`[已确认: 仓库枚举]`
  - 安装把 `AGENTS.md` 列为"受保护·绝不覆盖"；但更新语义相反——AGENTS.md 内容会变（如本轮加了 FEEDBACK），更新必须能覆盖它。`[已确认: INSTALL.md:45]`
- 分析（核心张力）：更新 = **覆盖方法论资产到最新** + **硬保护 `docs/sandtable/`**，与安装"绝不覆盖"语义相反；需独立流程而非复用 INSTALL。用户可能改过资产（AGENTS.md 等），覆盖有丢改风险，且目标项目不一定是 git 仓。
- 待澄清（产品决策）：D1 交付形态、D2 是否版本标记、D3 用户改过资产怎么办、D4 是否官方更新提示词、D5 语言如何确定。记入 questions.md。
- 依据/来源：见上 `[已确认]`。

## 2026-06-06 20:05 · [决策] D1-D5 全 A + 前五步完成
- 内容：D1=A UPDATE.md(AI 驱动)；D2=A 不做版本号；D3=A 覆盖前备份到 .sandtable-backup/<ts>/；D4=A 中英官方更新提示词；D5=A 语言由官方提示词精确匹配。
- 产出：prd.md(FR1-8)、tests.md(TC1-8)、plan.md(T1 UPDATE.md 全文 + T2 README + T3 INSTALL)。
- 核心语义：与安装相反——覆盖方法论资产、补齐新增、AGENTS.md 可覆盖；最高红线绝不碰 docs/sandtable；覆盖前备份。
- 依据/来源：开发者 AskQuestion；INSTALL.md §3/§5。

## 2026-06-06 20:25 · [推演+集成] 推演加固 + 单一实现完成
- 推演：mental-1=LOGIC_CLOSED，但发现 **A1 跨需求缺陷**——`templates/en/` 缺 `feedback.md`/`lessons.md`（post-landing-loop 误判 en 模板根所致），已补建英文版修复；redteam-1=HELD，纳入 3 项加固（语言一致提醒、stale 不清理声明、备份目录提示）写入 UPDATE.md。
- 实现（main 工作树，未提交）：UPDATE.md（T1）+ README 更新节（T2）+ INSTALL 指引（T3）+ templates/en 修复。
- 校验：官方提示词 UPDATE.md/README 逐字一致；UPDATE.md bash 块 bash -n 通过；全文无 docs/sandtable 写入；零依赖。报告 rehearsals/impl-1-plugin-update.md。
- 注意：A1 修复属 post-landing-loop 的遗漏，在本需求 rehearsal 中发现并顺带修复（恰是 FEEDBACK/吸取教训机制的真实演练）。
- 依据/来源：rehearsals/mental-1.md、redteam-1.md、impl-1-plugin-update.md；grep/bash -n 校验。
- 状态：DONE。未提交，待开发者决定提交/合并。
