# MENTAL_REHEARSAL 轮 6 · README 首页重塑（第 3 轮压力测试再重跑）

## 结论
`ANOMALY_FOUND`

本轮在修正 `FR6` 的 Cursor 默认路径冲突后再次重跑第 3 轮 mental。3 个只读子 agent 中仍有 1 个返回 anomaly，且主 agent 已核实成立，因此本轮不计入 autopilot 的有效 `mental` 轮次。

## 已核实异常

1. **`plan.md` 的首屏边界比 `prd.md/tests.md` 更宽**
   - 表现：`plan.md` 写成“首屏只允许落入 1-7”，其中包含“微对比”和“两个短锚点”；但 `prd.md` 与 `tests.md` 的硬约束一直是“首屏只允许标题、1 句副文、`<=5` 条记忆点和 1 条试用入口摘要”，闭环图、微对比和短锚点应紧随其后、但不应回挤进首屏。
   - 风险：实现者可能在遵循 `plan.md` 的前提下，把本应属于前两屏后半段的元素塞进首屏，导致首页优先级再次漂移。
   - 处置：已修订 `plan.md`，把首屏允许范围明确收紧为 `1-4`，并新增“`5-7` 必须紧接首屏出现、但不得回挤进首屏”的硬约束。

## 主 agent 裁决
- 本轮 anomaly 是文档护栏之间的边界冲突，不是 `README.md` 尚未实现导致的假异常。
- 已完成核实与回写，`state.md` 已更新为 `mental.runs=6`、`last=anomaly`、`completed_rounds.mental=2`。
- 下一步：按修正后的 `plan.md` 再次重跑第 3 轮 mental；若 3 个只读子 agent 全部 `LOGIC_CLOSED`，则补满 autopilot 的 mental 配额并进入 `REDTEAM`。
