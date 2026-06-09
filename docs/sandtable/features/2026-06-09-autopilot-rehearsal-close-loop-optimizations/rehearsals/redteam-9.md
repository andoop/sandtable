# Redteam 9 Report

**Status:** `BREACH_FOUND`

## Scope

mental-15 闭环后复攻 `plan.md`，重点检查：

- T1/T2/T5/T6: MUST/MUST NOT、PRD-AC、四路径二次校验、覆盖矩阵/live TODO/evaluating/rehearse/debrief 一致性。
- T3/T4/T7/T8: resume OBJECTIVES→TESTCASES、start 同回合 AskQuestion、refine/resume 确认续跑、using-sandtable 注入层、真实问题/攻破口径、镜像同步。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

1 个红军子 agent 返回 `BREACH_FOUND`，1 个返回 `HELD`。主 agent 核实后确认一条真实计划破口，已修正 `plan.md`。

## Breach

### R9-B41: live TODO `项` 仍允许聚合 `MUST/MUST NOT`

**复现路径:**

1. R8-B39 后，覆盖矩阵已要求逐条 `MUST-1...MUST-n` / `MNOT-1...MNOT-n`。
2. 但 T5 步骤5 的 live TODO `项` 字段仍允许填写聚合 `MUST/MUST NOT`。
3. 子 agent 可在覆盖矩阵中逐条声称满足，在 live TODO 表里只写一行 `MUST/MUST NOT | done`，无法逐项追踪单条 MUST/MNOT 的缺失或违反。
4. 矩阵/TODO 同步规则此前只强调 PLAN 步骤粒度，未要求 FR/PRD-AC/MUST/MNOT/TC 键集合逐项对应。

**打穿:** TC9、TC10、TC11、FR6。

**修正:**

- T5 步骤5 的 `项` 字段改为 `PRD FRx`、`PRD-ACx`、`MUST-x`、`MNOT-x`、`TCx` 或 `PLAN Tx/步骤x`。
- 明确禁止使用聚合 `MUST/MUST NOT`、`全部红线` 等摘要键替代逐条红线。
- 新增覆盖矩阵与 live TODO 表在 PRD FR、PRD-AC、MUST/MNOT、TESTS TC 键集合上一一对应；任一表缺键或聚合替代逐条键，按 `missing` 处理。

## Held

- R8-B39 主链路：MUST/MUST NOT 已进入结构化基准、覆盖矩阵、四路径二次校验和验证场景；本轮只修正 live TODO 粒度残留。
- R8-B40 resume `phase=OBJECTIVES` + PRD 已确认：T7 步骤6.6 已明确直接进入 `writing-tests`，不重进 `writing-prd`。
- R7-B38 `/sandtable-start` 同回合 AskQuestion 续跑、R6-B34 `using-sandtable` 注入层、T4 真实攻破口径、T8 镜像同步均未发现新的计划层破口。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
