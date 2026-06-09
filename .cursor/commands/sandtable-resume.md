---
description: 换人/换 AI/异常退出后，按持久化状态与当前模式恢复并续接。
---

接防续接当前需求；读取并遵循 `skills/state-and-memory/SKILL.md` 的「恢复流程」。

执行：
1. 读全局 `docs/sandtable/project.md` 与 `constraints.md`，建立项目目标与红线认知。
2. 列出 `features/`，确认要恢复的需求（多个时问我）。
3. 读该需求 `state.md`，优先恢复 `autonomy.*`、`phase` 与 `tasks`；若 `blocked: true`，先读 `questions.md` 处理阻塞问题。
4. 读 `journal.md` 近期条目重建上下文——**已记录的决策按记录执行，不要重新发明**。
5. 读 `prd.md`、`tests.md`、`plan.md`、`rehearsals/` 已有报告。
6. 若 `autonomy.mode=autopilot` 且 `blocked=false`，把这次 `/sandtable-resume` 视为显式 autopilot 续跑：只在本回合启用 `<AUTOPILOT-OVERRIDE>`，并按未完成的最低配额继续推进；优先级是 `mental → redteam → impl → EVALUATE`，不要用手动 `rehearsals.*` 抵扣 `autonomy.completed_rounds`。
7. 仅当 `autonomy.mode=manual` 或 `blocked=true` 时，用 3–5 行向我复述："我们在做什么、进行到哪、上次为什么停、下一步要做什么"，缺少可追溯确认时等我确认后继续；若本回合已有明确选择或确认并要求继续，先/同时落盘必要证据后继续。

只在发现矛盾或缺失时才回到 `being-truthful` 去澄清；不要把 autopilot 的恢复语义静默覆盖到我之后显式触发的手动 slash。

8. 完成后加载 `skills/closing-the-loop/SKILL.md`，读 `state.md`，输出收尾（本命令已列出的链内后续步骤除外；链内切换用战报 profile）。缺少明确选择或确认时不得越权执行**本命令未列出**的下一阶段（`/sandtable-autopilot`、`/sandtable-rehearse` 除外）；本回合用户已明确选择/确认且必要证据已先/同时落盘的内联后续，属于本命令允许的链内后续。

## 本需求补充 · 最低覆盖、自主裁决与续接门禁

- `autonomy.min_rounds` 和 `autonomy.min_agents_per_round` 表示最低覆盖，默认 `{ mental: 1, redteam: 1, impl: 1 }`；历史 feature 已写入 3/3/2 时不得强制迁移或覆盖。
- 冷启动才初始化 `phase=RECON` 并自动补齐 `RECON -> OBJECTIVES -> TESTCASES -> PLAN`。已有 `state.md` 或任一 feature 文档时按续接处理，保留既有 `min_rounds`、`min_agents_per_round`、`completed_rounds` 与 `phase`。
- 续接进入 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL 前必须先检查 PRD 确认门禁：确认必须可追溯到开发者输入，并在继续前或同时持久化到 `state.md` 或 `journal.md`。AskQuestion 需有 answer id 或 `source: askquestion:<id>`；自然语言确认需记录用户原话摘录、确认时间和用户消息来源。agent 自写推进日志、`autonomy.last_decision`、`phase>=TESTCASES`、仅写“AskQuestion 答复”或无来源的 `prd_confirmed` 不算确认。
- 文档未齐备时从最早缺失阶段补齐；但 `prd.md` 已存在且未确认时必须停在 PRD 确认点，不得因缺 `tests.md` 或 `plan.md` 继续。
- 推演链先补足 mental -> redteam -> impl 最低覆盖。最低覆盖达成后，主 agent 必须依据风险、改动面、历史教训、异常是否刚修复、实现候选差异、测试信心和抽查结果，自主追加或进入 `EVALUATE`，并记录 `autonomy.last_decision`；非真实阻塞不得询问用户是否继续。
- impl 自报 `DONE` 不能直接计入轮次或进入 `EVALUATE`；必须先通过完整性闸门，并在进入 `EVALUATE` 前二次校验当前 PRD/tests/plan 结构化基准、覆盖矩阵、live TODO 表、真实 diff / 改动文件清单。

## 本需求补充 · 已选择路径直接执行与 PRD 确认证据

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
