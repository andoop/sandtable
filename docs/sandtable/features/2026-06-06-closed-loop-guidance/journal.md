## 2026-06-06 12:00 · [受领]
- 背景: `/sandtable-start` 受领新需求。
- 内容: 原始需求——在 sandtable 项目增加「强约束」式回合收尾：每次输出后提示下一步，并给出用户可直接复制的下一条问话模版；若可调用问题工具（AskQuestion）则调用让用户选择；自动模式下主 agent 自行选择续跑；目的是让流程更智能、更闭环，用户在连续对话中也能感知沙盘机制。
- 依据/来源: 开发者本回合消息。

## 2026-06-06 12:05 · [侦察]
- 背景: gathering-intel 扫地形。
- 内容:
  - **已确认事实**
    - 方法论入口经 `hooks/session-start` 注入 `skills/using-sandtable/SKILL.md`（`sandtable/hooks/session-start:11-25`）。
    - 状态机与 `autonomy.mode` 权威定义在 `skills/state-and-memory/SKILL.md`；`phase` 枚举覆盖 INTAKE→DONE（`sandtable/skills/state-and-memory/SKILL.md:36-39`）。
    - `/sandtable-start` 仅在步骤 7 用自然语言提示后续 slash（`sandtable/commands/sandtable-start.md:14`），无统一收尾规范。
    - `/sandtable-status` 要求给出「下一步建议动作」（`sandtable/commands/sandtable-status.md:13`），但只读、无模版格式。
    - `/sandtable-resume` 仅在 `manual` 或 `blocked` 时等待确认（`sandtable/commands/sandtable-resume.md:14`）。
    - `autonomous-orchestration` 明确 autopilot 下「不要逐步问用户要不要继续」（`sandtable/skills/autonomous-orchestration/SKILL.md:39,75`）。
    - 当前 **不存在** 统一的「回合收尾 / 下一步模版」skill 或模板文件。
    - 插件资产需同步多路径：`skills/`、`plugins/sandtable/skills/`、`locales/en/skills/`、`locales/en/plugins/sandtable/skills/`（见 `2026-06-06-cross-ai-install-english-docs` 历史决策）。
    - Cursor 环境提供 `AskQuestion` 工具（结构化多选）；非 Cursor 宿主可能无此工具。
  - **未知 / 待澄清**
    - 普通自由对话（未触发 slash）是否也要强制收尾？→ 本需求按「Sandtable 工作回合」理解，见 PRD 范围。
    - 模版语言是否随安装 locale 切换？→ 继承 cross-ai-install 规则，中英各一套。
- 依据/来源: 代码与 skill 文件精读。

## 2026-06-06 12:10 · [决策]
- 背景: writing-prd 方案探索。
- 内容: 评估三方案后推荐 **方案 B（独立 `closing-the-loop` skill + 主入口索引）**：
  - A：只改各 command 尾部文案 → 易漂移、难维护。
  - B：单一 skill 维护 phase→命令→可复制模版表，由 `using-sandtable`/rules/commands 引用 → 单一事实来源、可本地化。
  - C：写进 `state.md` 模板让 AI 读盘生成 → 增加用户项目噪音，违反「方法论在插件内」边界。
  - 手动模式：`blocked` 或存在 ≥2 条合理分支时用 AskQuestion；否则给 1 条主推模版 + 备选可复制块。
  - autopilot：读完 `state.md` 后直接执行下一合法阶段，回合末只报告「已自动续跑至 X」，不弹 AskQuestion。
- 依据/来源: PRD §方案探索 + 开发者「自动模式自己选择」表述。

## 2026-06-06 12:20 · [问答]
- 背景: PRD 确认轮 AskQuestion。
- 内容:
  - 开发者基本认可方案 B；补充：**每一步 AI 感觉要结束、想要用户确认时，都要走 closing-the-loop 流程**。
  - FR8 原问法（slash vs 普通对话）开发者表示没明白；已改写为「凡 Sandtable 工作步结束且需确认/选下一步 → 必须收尾」。
- 依据/来源: AskQuestion 答复。

## 2026-06-06 14:00 · [推演]
- 背景: mental-1 并行 3 子 agent，全部 ANOMALY_FOUND。
- 内容: 主 agent 核实后修正 plan/prd/tests：
  - 定义完整收尾 vs 战报收尾两种 profile，消解 autopilot T3 步骤1/4 矛盾；
  - OBJECTIVES·PRD待确认 子状态 + 模版，衔接 writing-prd 硬门禁；
  - sandtable-start 步骤4 暂停收尾；rehearse 链内中间不收尾；
  - FR8 正负触发；TC8b 防误读 state.md；
  - T4 扩至 39 个 en command 文件 + 放宽 rg 范围；去掉 state T2 的 session-start 误导。
- 依据/来源: rehearsals/mental-1.md + 子 agent 48861cbf / 573bef3c / ba1ceb8a 报告。

## 2026-06-06 14:30 · [推演]
- 背景: mental-2 修补后复核。
- 内容: 1 个子 agent 返回 `LOGIC_CLOSED`；主 agent 抽查 plan/prd/tests 对齐。mental-1 九项 anomaly 已收口。残余风险：TC8 对 writing-prd 门禁断言偏弱、rehearse 链内「省略」措辞、缺 autopilot 终局 TC。
- 依据/来源: rehearsals/mental-2.md

## 2026-06-06 16:00 · [对抗]
- 背景: redteam-1 打计划，3 OPFOR 并行（autopilot / start+FR8 / 镜像）。
- 内容: 全部 `BREACH_FOUND`。核实 9 条成立：rehearse省略、autopilot终局无TC、OBJECTIVES样例矛盾、start单轮矛盾、rules负触发缺失、FR8第三态、EVALUATE无slash、plugins镜像漏项、blocked纪律。已修 plan/prd/tests（TC10等）。
- 依据/来源: rehearsals/redteam-1.md

## 2026-06-06 18:00 · [自动推进]
- 背景: `/sandtable-autopilot` 本回合。
- 内容: mental-3 两路 ANOMALY（FR8 T1/T2）→ 修 plan 并**主仓实现** T1–T4。en locale 误覆盖已 git 恢复并补 en closing-the-loop。autopilot 硬配额（mental×3/redteam×3/impl×2 worktree）**未闭包**；单候选 impl-1-main 择优落地。
- 依据/来源: impl-1-main.md；autonomous-orchestration 硬门禁
