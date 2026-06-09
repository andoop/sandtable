# Mental 33 Report

**Status:** `ANOMALY_FOUND`

## Scope

复核 mental-32 修正后的 `prd.md`、`tests.md`、`plan.md`、`journal.md`、`state.md`，重点检查所有入口的同条 PRD 确认落盘责任是否闭环。

## Result

2 个只读 mental 子 agent 返回分歧：一路 `LOGIC_CLOSED`，一路 `ANOMALY_FOUND`。主 agent 核实后确认 anomaly 成立。

## Anomaly

### M33-A1: `/sandtable-plan` / `writing-plan` 未绑定同条 PRD 确认落盘责任

**问题:**

T7 步骤6.7 中 `writing-tests` 已要求本回合 PRD 确认触发时，写 `tests.md` 前或同时落盘证据；但 `/sandtable-plan` 和 `writing-plan` 只要求已有可核实记录，没有写本回合同条确认时先/同时落盘再写 `plan.md`。

**影响:**

用户发送 `/sandtable-plan PRD 已确认，请写 plan.md` 时，实现者可能直接写 `plan.md` 但不落盘证据；下一回合 resume/autopilot/推演缺 PRD 确认证据，复现 RT20 同类问题。

**修正:**

- T7 步骤6.7：`/sandtable-plan` 若由本回合 AskQuestion 或自然语言 PRD 确认触发，必须在写 `plan.md` 前或同时先落盘对应证据。
- T7 步骤6.7：`writing-tests` / `writing-plan` 对称要求写 `tests.md` / `plan.md` 前或同时落盘对应证据。
- T7 验证新增 `/sandtable-plan PRD 已确认，请写 plan.md` 正向落盘场景。
- TC14 Then 明确 manual 推演入口、`/sandtable-plan` 同条消息携带确认时，也必须在继续前或同时落盘。

## Held

- T1/T2 autopilot/resume、本轮前 T3/T4/T6 手动推演/live、T7 start/refine/resume/writing-tests 的同条确认落盘责任已闭环。
- RT16 完整性闸门、T7/T8 镜像、自动模式最低覆盖未发现新 anomaly。

## Next

已修正 `tests.md` 与 `plan.md`。重新运行 mental；闭环后再运行 redteam。
