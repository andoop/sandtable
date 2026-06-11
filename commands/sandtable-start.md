---
description: 启动 Sandtable 前五步流程：从一句需求开始，侦察→目标→用例→计划。
---

对我接下来描述的需求启动 Sandtable 流程；读取并遵循 `skills/using-sandtable/SKILL.md`。

执行（这是前五步入口；推演与复盘请使用单独命令或 `/sandtable-autopilot`）：
1. 加载 `state-and-memory`，在目标项目创建/确认 `docs/sandtable/` 结构；若 `project.md`/`constraints.md` 不存在，先和我确认全局目标与红线（用 `templates/` 拷贝）。
2. 为本需求建 `features/<YYYY-MM-DD>-<slug>/` 目录与 `state.md`（phase=INTAKE），记录原始需求（一句话或我给的产品文档）。
3. **RECON**：加载 `gathering-intel` 侦察情报（摸地形、列未知、攒问题问我）。〔= `/sandtable-recon`〕
4. **OBJECTIVES**：加载 `writing-prd` 定目标、MUST/MUST-NOT、红线、验收。〔= `/sandtable-objectives`〕
   - 写完 `prd.md` 后加载 `skills/closing-the-loop/SKILL.md`，输出**完整收尾** + AskQuestion/确认模版。
   - **本命令在此结束**；不得在本命令内继续步骤5–6。待开发者确认 PRD 后，由确认消息或 `/sandtable-refine` 续跑。
5. **TESTCASES**（PRD 确认**之后**的续跑步骤）：加载 `writing-tests` 产出 `tests.md`。〔= `/sandtable-plan` 前置〕
6. **PLAN**（续跑步骤）：加载 `writing-plan` 写 `plan.md`。
7. PLAN 完成后加载 `skills/closing-the-loop/SKILL.md`，输出**完整收尾**（含 `/sandtable-rehearse`、`/sandtable-autopilot`、`/sandtable-refine` 模版；说明 `/sandtable-rehearse`=四步合一）。

全程严格遵守四条底线（不猜测、先思考、外科手术式改动、目标驱动）。每步更新 `state.md` 与 `journal.md`。若任一步我提出修改，按 `/sandtable-refine` 的方式迭代。

我的需求是：

## PRD 确认门禁与已选择路径直接执行

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
