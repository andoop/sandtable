# Redteam 18 Report

**Status:** `BREACH_FOUND`

## Scope

mental-26 闭环后复攻 PRD 确认证据链、文档链入口、T7/T8 镜像同步、RT16 完整性闸门、已确认续跑和自动模式最低覆盖。

只接受真实可复现并影响最终实现或验收的破口。

## Result

2 个红军子 agent 返回分歧：一路 `HELD`，一路 `BREACH_FOUND`。主 agent 核实后确认 `BREACH_FOUND` 成立，问题落在 TC13 对自然语言确认的验收缺口。

## Breach

### RT18-B64: TC13 自然语言确认未要求落盘可核实证据

**复现路径:**

1. 用户自然语言发送“PRD 已确认，请继续写 tests.md”。
2. agent 直接写 `tests.md`，但不在 `state.md` 或 `journal.md` 记录用户原话摘录、确认时间和用户消息来源。
3. 按 TC13 原文验收仍可通过，因为 TC13 只要求直接进入 TESTCASES 并报告状态。
4. 后续 resume/autopilot 缺可核实 PRD 确认证据，打穿 FR7/MUST 的防伪闭环，或导致合法续接被误杀。

**修正:**

- TC13 Then 增加：自然语言确认后直接进入 TESTCASES 的同时，必须在 `state.md` 或 `journal.md` 记录用户原话摘录、确认时间和用户消息来源。
- T7 验证场景增加：`/sandtable-refine` 与 `/sandtable-resume` 自然语言确认后，不仅要直接写 `tests.md`，还必须落盘自然语言确认三元组。

## Held

- RT17-B63 AskQuestion 无 id / 只有确认时间路径守住。
- RT16-B57/B58 完整性闸门守住。
- RT15-B56 T7 文件清单和 T8 镜像核对守住。
- `/sandtable-plan` / refine / `writing-tests` / `writing-plan` 文档链门禁守住。

## Next

已修正 `tests.md` 与 `plan.md`。重新运行 mental；闭环后再运行 redteam。
