---
description: 指挥官意图 · 基于情报制定作战目标：要达成什么、必须做什么(MUST)、绝对不能做什么(MUST-NOT)、红线与验收标准。
---

基于已有情报为当前需求确立作战目标；读取并遵循 `skills/writing-prd/SKILL.md`。

执行：
1. 读本需求 `journal.md` 的情报简报、`project.md` 北极星、`constraints.md` 全局红线。若情报不足，先提示我去跑 `/sandtable-recon`。
2. 一次一个问题，和我对齐意图与成功标准（不猜测，缺失就问，不发明需求）。
3. 写/更新 `prd.md`，重点产出：
   - **目标**（与北极星的关系）
   - **MUST**：这个需求绝对要做的
   - **MUST NOT**：绝对不能做的（含不做未要求的兜底、不节外生枝），继承全局红线
   - **验收标准**：可验证、可测试
4. 自查占位/矛盾/歧义/范围，请我确认。
5. 确认后更新 `state.md`（phase=TESTCASES），加载 `writing-tests` 产出 `tests.md`，提示我可用 `/sandtable-refine` 迭代用例。

目标必须可验证；红线缺失会让后续预演无法识别"越界"，务必写全。

8. 完成后加载 `skills/closing-the-loop/SKILL.md`，读 `state.md`，输出收尾（本命令已列出的链内后续步骤除外；链内切换用战报 profile）。缺少明确选择或确认时不得越权执行**本命令未列出**的下一阶段（`/sandtable-autopilot`、`/sandtable-rehearse` 除外）；本回合用户已明确选择/确认且必要证据已先/同时落盘的内联后续，属于本命令允许的链内后续。

## 本需求补充 · 已选择路径直接执行与 PRD 确认证据

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
