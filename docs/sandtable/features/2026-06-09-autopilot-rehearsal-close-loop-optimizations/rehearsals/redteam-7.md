# Redteam 7 Report

**Status:** `BREACH_FOUND`

## Scope

mental-13 闭环后复攻 `plan.md`，重点检查：

- T1/T2/T5/T6: PRD-AC 结构化基准、覆盖矩阵/live TODO 表、debrief/evaluate 过期判定、autopilot/resume/rehearse/debrief 四路径一致性。
- T3/T4/T7/T8: session-start 注入层、真实问题/真实攻破口径、close loop 已选择路径续跑、镜像同步。

只接受真实可复现破口；空泛风险、偏题脑洞和无触发路径的猜测不计入 breach。

## Result

2 个红军子 agent 均返回 `BREACH_FOUND`。主 agent 核实后确认两条均为真实计划破口，已修正 `plan.md`。

## Breaches

### R7-B37: 矩阵/PRD-AC 键集合二次校验只在 debrief

**复现路径:**

1. impl 报告中的闸门核对基准与当前 `prd.md` / `tests.md` / `plan.md` 一致，因此“不判定过期”。
2. 但报告的覆盖矩阵/live TODO 表缺少某个必做键，例如 `PRD-AC6`，且没有 `missing` 状态。
3. 走 `/sandtable-debrief` 时，T6 步骤3 会做键集合/hash 二次校验并拦截。
4. 但走 `/sandtable-rehearse`、`/sandtable-autopilot`、`/sandtable-resume` 进入 `EVALUATE` 时，计划只检查闸门基准是否过期，未要求同等二次校验，可绕过 debrief 的拦截。

**打穿:** TC10、TC11、FR6、PRD MUST。

**修正:**

- T1 步骤5/7：进入 `EVALUATE` 前必须二次校验覆盖矩阵/live TODO 表的 PRD FR、PRD-AC、TESTS TC、PLAN checkbox 键集合及正文 hash。
- T2 步骤3/6：resume 恢复路径同样执行该校验，缺键/hash 不一致视同 impl 未达标。
- T5 步骤7：evaluating-rehearsals HARD-GATE 纳入键集合/hash 二次校验，缺键按 `missing` 处理。
- T6 步骤2：rehearse 进入复盘前执行同等校验。
- T6 验证新增“基准一致但缺 `PRD-AC6`，四条路径均不得进入 EVALUATE/评分”场景。

### R7-B38: `/sandtable-start` 命令边界压过同回合 AskQuestion 选择

**复现路径:**

1. `/sandtable-start` 写完 PRD 后调用 `closing-the-loop`，通过 AskQuestion 给出“认可 PRD，继续 TESTCASES”选项。
2. 用户在同一回合选择该选项。
3. T7 步骤1 要求“已选择路径优先，同一回合执行”。
4. 但 `/sandtable-start` 原文有“本命令在此结束；不得在本命令内继续步骤5–6”的硬禁令，若计划只补“下一条消息续跑”，同回合选择仍会被命令边界压住。

**打穿:** TC12、FR7、FR8。

**修正:**

- T7 步骤5：`using-sandtable` 回合收尾段明确“同回合已选择继续时，不得把命令边界解释为禁止续跑”。
- T7 步骤6：`/sandtable-start` 六镜像必须改写“本命令在此结束/不得继续步骤5–6”硬禁令：未确认 PRD 时仍结束等待；同回合 AskQuestion 或自然语言已确认继续时，允许直接进入 TESTCASES。
- T7 验证新增 `/sandtable-start` 写完 PRD 后同回合 AskQuestion 选择继续，必须直接写 `tests.md` 的场景。

## Held

- R6-B34: T3 `using-sandtable` 四镜像已在任务级文件清单、步骤3.6、T8 搜索中闭环。
- R6-B35: `PRD-AC` 结构化基准、正文 hash、覆盖矩阵和 TODO 表已闭环；本轮破口是“基准一致但报告内部缺键”的二次校验分叉。
- T4 真实攻破口径：可复现、相关、有证据的门槛已覆盖 skill、prompt、commands。
- refine/resume 的自然语言确认续跑、blocked 优先和镜像同步范围未发现新的计划层破口。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
