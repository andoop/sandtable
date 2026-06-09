# Redteam 20 Report

**Status:** `BREACH_FOUND`

## Scope

implementation rehearsal 前整体最终复攻，重点：

- 自动模式最低覆盖与续接。
- PRD 确认门禁、防伪、证据落盘。
- 文档链入口、T7/T8 镜像。
- RT16 live 完整性闸门。
- close-loop 已选择即续跑。

只接受真实可复现、会影响最终实现或验收的破口。

## Result

2 个红军子 agent 返回分歧：一路 `HELD`，一路 `BREACH_FOUND`。主 agent 核实后确认 `BREACH_FOUND` 成立，问题是 T1/T2 编排层未把“本回合明确确认”绑定到持久化证据。

## Breach

### RT20-B66: autopilot/resume 将“本回合明确确认”当作独立有效来源，未绑定证据落盘责任

**复现路径:**

1. feature 已有 `prd.md`，但 `state.md` / journal 无合规 PRD 确认证据，`phase=OBJECTIVES`。
2. 用户同条消息触发 `/sandtable-autopilot` 或 `/sandtable-resume`，并附带“PRD 已确认，请继续写 tests.md”。
3. T1/T2 原文允许“本回合明确确认”直接进入 TESTCASES，但未要求先/同时写入 `state.md` 或 `journal.md`。
4. 同回合写出 `tests.md` 后，下一回合 resume/autopilot 缺可核实证据，被挡回 PRD 确认点，或诱发弱摘要伪造确认。

**修正:**

- T1 步骤2.5：本回合明确确认也必须在继续前或同时持久化到 `state.md` 或 `journal.md`，才算可核实确认。
- T1 文档补齐分支：仅当本回合确认已持久化，或历史记录已有合规证据，才允许补 `tests.md` / `plan.md`。
- T1 autopilot 命令同步语义：本回合明确确认 PRD 时，必须先/同时持久化证据，才进入 TESTCASES。
- T2 步骤3 / 步骤6：恢复路径同条确认也必须先/同时持久化证据，才可继续。
- T1/T2 验证：新增 `/sandtable-autopilot` 和 `/sandtable-resume` 同条消息带 PRD 确认时，必须在写 `tests.md` 前或同时写入用户原话摘录、确认时间和用户消息来源。
- TC14 Then 明确 resume/autopilot 同条消息携带确认时，也必须在继续前或同时落盘。

## Held

- RT19-B65 T7 入口绑定守住。
- RT18-B64 / M29 自然语言与 AskQuestion tests 闸门守住。
- RT16-B57/B58 完整性闸门守住。
- RT15-B56 T7 文件清单与 T8 镜像核对守住。
- 文档链 `/sandtable-plan`、refine、`writing-tests`、`writing-plan` 门禁守住。

## Next

已修正 `plan.md` 与 `tests.md`。重新运行 mental；闭环后再运行 redteam。
