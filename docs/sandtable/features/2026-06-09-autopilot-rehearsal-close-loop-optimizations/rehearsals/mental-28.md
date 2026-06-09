# Mental 28 Report

**Status:** `ANOMALY_FOUND`

## Scope

复核 redteam-19 / RT19-B65 修正后的 `prd.md`、`tests.md`、`plan.md`、`journal.md`，重点检查 PRD 确认证据落盘是否绑定到 start / close-loop / refine / resume / `writing-tests` 等续跑入口。

## Result

2 个只读 mental 子 agent 返回分歧：一路 `LOGIC_CLOSED`，一路 `ANOMALY_FOUND`。主 agent 核实后确认 anomaly 成立。

## Anomaly

### M28-A1: TC12 未同步 RT19-B65 的 AskQuestion 证据落盘要求

**问题:**

TC12 原先要求 AskQuestion 续跑时记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间，但未明确写入 `state.md` 或 `journal.md`，也未要求在执行 TESTCASES 前或同时落盘。T7 已要求 start/close-loop 等路径先落盘再续跑，tests 理解闸门与 plan 不一致。

**影响:**

实现者若只按 TC12 验收，可能把 answer id 放在回复里而不持久化；下一回合 resume/autopilot 会缺可核实 PRD 确认证据，复现 RT19-B65。

**修正:**

TC12 Then 改为：agent 在执行 TESTCASES 前或同时，先把 PRD 确认证据写入 `state.md` 或 `journal.md`，记录 AskQuestion answer id 或 `source: askquestion:<id>` + 选项原文/确认时间，然后直接执行 TESTCASES。

## Held

- T7 步骤1/6/6.5/6.6/6.7 已把证据落盘绑定到主要续跑入口。
- TC13 自然语言证据落盘与 TC14 负向门禁保持一致。
- RT16 完整性闸门、T7/T8 镜像、文档链入口、自动模式最低覆盖未发现新 anomaly。

## Next

已修正 `tests.md`。重新运行 mental；闭环后再运行 redteam。
