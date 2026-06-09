# Mental 29 Report

**Status:** `ANOMALY_FOUND`

## Scope

复核 mental-28 / M28-A1 修正后的 `prd.md`、`tests.md`、`plan.md`、`journal.md`，重点检查 TC12/TC13/TC14 与 T7 证据落盘责任是否一致。

## Result

2 个只读 mental 子 agent 返回分歧：一路 `LOGIC_CLOSED`，一路 `ANOMALY_FOUND`。主 agent 核实后确认 anomaly 成立。

## Anomaly

### M29-A1: TC13 未同步“执行 TESTCASES 前或同时落盘”的时序约束

**问题:**

TC12 已改为 AskQuestion 证据在执行 TESTCASES 前或同时写入 `state.md` / `journal.md`，但 TC13 仍写作“直接进入 TESTCASES 写 `tests.md`，并在 state/journal 记录三元组”，没有明确自然语言确认也必须前置或同时落盘。PRD 也未明确落盘目标和时序。

**影响:**

实现者可能先写 `tests.md`，把证据落盘延后；若同回合中断，下一回合 resume/autopilot 缺可核实 PRD 确认证据，复现 RT19-B65 的自然语言变体。

**修正:**

- TC13 Then 改为：agent 在执行 TESTCASES 前或同时，先把用户原话摘录、确认时间和用户消息来源写入 `state.md` 或 `journal.md`，然后直接进入 TESTCASES。
- PRD FR7、验收标准、MUST 明确：PRD 确认记录必须在继续前或同时持久化到 `state.md` 或 `journal.md`。

## Held

- TC12 已与 T7 AskQuestion 证据落盘责任对齐。
- T7 步骤1/6/6.5/6.6/6.7 已绑定证据落盘与续跑入口。
- RT16 完整性闸门、T7/T8、文档链入口、自动模式最低覆盖未发现新 anomaly。

## Next

已修正 `prd.md` 与 `tests.md`。重新运行 mental；闭环后再运行 redteam。
