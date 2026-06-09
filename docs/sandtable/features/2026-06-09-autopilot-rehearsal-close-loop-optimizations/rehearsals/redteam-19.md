# Redteam 19 Report

**Status:** `BREACH_FOUND`

## Scope

implementation rehearsal 前整体最终复攻，重点：

- 自动模式最低覆盖与续接。
- PRD 确认门禁、防伪、证据落盘。
- 文档链入口与 T7/T8 镜像。
- RT16 live 完整性闸门。
- close-loop 已选择即续跑。

只接受真实可复现、会影响最终实现或验收的破口。

## Result

2 个红军子 agent 返回分歧：一路 `HELD`，一路 `BREACH_FOUND`。主 agent 核实后确认 `BREACH_FOUND` 成立，问题是 PRD 确认证据落盘责任没有绑定到实际续跑入口。

## Breach

### RT19-B65: PRD 确认证据落盘只在规则层，未绑定到 start/close-loop/refine/resume/writing-tests 续跑路径

**复现路径:**

1. `/sandtable-start` 写完 PRD，用户通过 AskQuestion 选择“认可 PRD，下一步进入 TESTCASES”。
2. T7 步骤1/6 要求直接写 `tests.md`，但原步骤没有要求在写之前或同时落盘 AskQuestion answer id / source。
3. 同回合成功写 `tests.md`，下一回合 resume/autopilot 因缺可核实确认记录被挡回 PRD 确认点，或 agent 诱发弱摘要伪造确认。
4. TC12/TC13/TC14 与 FR7/MUST 的证据防伪链被打穿。

**修正:**

- T7 步骤1：若选择本身构成 PRD 确认，执行后续动作前或同时必须把可核实证据写入 `state.md` 或 `journal.md`。
- T7 步骤6：`/sandtable-start` / `/sandtable-objectives` 同回合或下一条消息确认后，先落盘证据，再进入 TESTCASES。
- T7 步骤6.5：refine 收到自然语言 PRD 确认并要求继续时，先记录自然语言确认三元组，再加载 `writing-tests`。
- T7 步骤6.6：resume 在 `phase=OBJECTIVES` 收到自然语言 PRD 确认时，先记录三元组，再进入 TESTCASES。
- T7 步骤6.7：`writing-tests` 若由本回合 PRD 确认触发，必须在写 `tests.md` 前或同时先落盘证据。
- T7 验证：`/sandtable-start` 同回合 AskQuestion 场景必须检查证据落盘，而不只检查直接写 `tests.md`。

## Held

- RT18-B64 TC13 自然语言证据落盘守住。
- RT17-B63 AskQuestion 无 id / 只有确认时间路径守住。
- RT16-B57/B58 完整性闸门守住。
- RT15-B56 T7 文件清单与 T8 镜像核对守住。
- 文档链 `/sandtable-plan`、refine、`writing-tests`、`writing-plan` 门禁守住。

## Next

已修正 `plan.md`。重新运行 mental；闭环后再运行 redteam。
