# MENTAL_REHEARSAL 轮 5 · README 首页重塑（第 3 轮压力测试补判）

## 结论
`ANOMALY_FOUND`

本轮在 `/sandtable-resume` 的 autopilot 续跑语义下，重新并行派出 3 个只读子 agent 补齐第 3 轮 mental 的剩余判定。3 个子 agent 全部指向同一处文档级异常，且主 agent 已核实成立，因此本轮不计入 autopilot 的有效 `mental` 轮次。

## 已核实异常

1. **`FR6` 对 Cursor 默认试用路径残留互斥版本**
   - 表现：`prd.md` 同时保留了“Cursor 默认走让 AI 阅读 `INSTALL.md` 并自助安装”和“Cursor 默认走手工拷 `.cursor/`，AI 自助安装降为备选”两版互斥口径。
   - 风险：实现者无法唯一确定 `Quickstart` 的 Cursor 子块该写哪条默认路径，`tests.md` 也只能验证“不能双选题”，却无法验证“默认到底是哪条”。
   - 处置：已按 `journal.md` 与 `plan.md` 既有决策收口为唯一口径：Cursor 默认仍是“让 AI 读 `INSTALL.md` 并自助安装”，手工拷 `.cursor/` 只作备选可靠路径；并同步修订 `prd.md` / `tests.md`。

2. **同一冲突会反向破坏 `Quickstart` 单一落点护栏**
   - 表现：虽然 `plan.md` 已要求前两屏单跳到同一个 `Quickstart`，但只要上游默认路径定义不唯一，`Quickstart` 的 Cursor 子块内容就仍有漂移空间。
   - 风险：README 实现时可能再次滑回“同一落点但默认路径不唯一”的伪闭环。
   - 处置：已在 `prd.md` 中保留“前两屏单跳到同一个 `Quickstart`”的唯一表述，并在 `tests.md` 中把 Cursor 默认路径写死为 AI 自助安装首选。

## 主 agent 裁决
- 本轮 anomaly 为文档护栏内部冲突，不是 README 尚未实现导致的假异常。
- 已完成核实与回写，`state.md` 已更新为 `mental.runs=5`、`last=anomaly`、`completed_rounds.mental=2`。
- 下一步：按修正后的文档立即重跑第 3 轮 mental；若 3 个只读子 agent 全部 `LOGIC_CLOSED`，则补满 autopilot 的 mental 配额并进入 `REDTEAM`。
