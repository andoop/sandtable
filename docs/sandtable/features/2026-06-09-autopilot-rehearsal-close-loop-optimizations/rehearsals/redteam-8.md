# Redteam 8 Report

**Status:** `BREACH_FOUND`

## Scope

mental-14 闭环后复攻 `plan.md`，重点检查：

- T1/T2/T5/T6: R7-B37 修正后的四路径二次校验、PRD-AC 基准、覆盖矩阵/live TODO/evaluating/rehearse/debrief 一致性。
- T3/T4/T7/T8: R7-B38 修正后的 `/sandtable-start` 同回合 AskQuestion 续跑、refine/resume 确认续跑、using-sandtable 注入层、镜像同步。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

2 个红军子 agent 均返回 `BREACH_FOUND`。主 agent 核实后确认两条均为真实计划破口，已修正 `plan.md`。

## Breaches

### R8-B39: MUST/MUST NOT 未进入机械校验链

**复现路径:**

1. implementation 候选报告按 T5 覆盖矩阵列出 FR、PRD-AC、TC、PLAN，但不单列 `prd.md` §7 MUST 与 §8 MUST NOT。
2. 候选漏掉一条独立 MUST 或违反一条 MUST NOT，但 FR/PRD-AC/TC/PLAN 行表面完整。
3. 闸门核对基准一致，R7 修正后的二次校验只检查 FR/PRD-AC/TC/PLAN 键集合，未检查 MUST/MUST NOT。
4. 候选可进入 `EVALUATE`/复盘/评分。

**打穿:** TC9、TC10、FR6、PRD MUST/MUST NOT。

**修正:**

- T5 结构化核对基准将 MUST/MUST NOT 定义为稳定键 `MUST-1...MUST-n`、`MNOT-1...MNOT-n` 并记录正文 hash。
- T5 覆盖矩阵新增 `PRD 红线覆盖: MUST-1 ... MUST-n / MNOT-1 ... MNOT-n`，不得由 FR、PRD-AC 或 TC 间接替代。
- live TODO 表与 `not-applicable` 规则明确 MUST/MUST NOT 属于本需求 scope 时不得洗白。
- T1/T2/T5/T6 四路径二次校验键集合补入 MUST/MUST NOT。
- T5/T6 验证新增基准一致但缺 `MUST-2` 或 `MNOT-1` 的拦截场景。

### R8-B40: `/sandtable-resume` 在 `phase=OBJECTIVES` 时 PRD 确认续跑语义不完备

**复现路径:**

1. `/sandtable-start` 写完 `prd.md` 后停在 PRD 确认点，`state.phase=OBJECTIVES`。
2. 新会话用户发 `/sandtable-resume` 并确认“PRD 已确认，请继续写 tests.md”。
3. T7 步骤6.6 原先只写“按 `state.phase` 直接加载对应 skill”，`phase=OBJECTIVES` 容易被实现为重新加载 `writing-prd`，而不是写 `tests.md`。
4. 与 refine 步骤6.5 的显式“PRD 已确认 → writing-tests”不对称，打穿 TC13。

**打穿:** TC13、FR7、FR8。

**修正:**

- T7 步骤6.6 明确：`phase=OBJECTIVES` 且 `prd.md` 已存在，用户确认 PRD 并要求继续时，续跑目标视为 TESTCASES，直接加载 `writing-tests`。
- 示例改为 `phase=OBJECTIVES` + “PRD 已确认，请继续写 tests.md”，并明确不得重新进入 `writing-prd`。
- T7 验证要求 `/sandtable-resume` 复原 `phase=OBJECTIVES` 后自然语言确认时直接写 `tests.md`，不输出复制命令、不重进 PRD。

## Held

- R7-B37: 四路径二次校验对 PRD-AC 已闭环；本轮扩展到 MUST/MUST NOT。
- R7-B38: `/sandtable-start` 同回合 AskQuestion 续跑已闭环。
- R6-B34: T3 `using-sandtable` 注入层已纳入任务级清单和 T8 搜索。
- T4 真实攻破口径、refine 确认续跑、镜像同步未发现新的计划层破口。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
