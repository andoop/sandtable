# Redteam 16 Report

**Status:** `BREACH_FOUND`

## Scope

mental-24 闭环后复攻完整性闸门、PRD-AC/MUST/MNOT/TC/PLAN 键集合与 hash 校验、真实 diff 核对、PRD 确认门禁和镜像同步。

只接受真实可复现破口；重复文件列表、措辞风格和可选整理不计入 breach。

## Result

2 个红军子 agent 返回分歧：一路 `HELD`，一路 `BREACH_FOUND`。主 agent 核实后确认 `BREACH_FOUND` 中两条完整性闸门问题成立，均影响 live 100% 验收。

## Breaches

### RT16-B57: `PRD-AC` / `MUST` / `MNOT` 稳定键缺少 canonical 派生规则

**复现路径:**

1. impl 报告少报 `PRD-AC`、`MUST` 或 `MNOT` 条目，但让报告内“闸门核对基准”、覆盖矩阵、live TODO 表彼此自洽。
2. 主 agent 若只比对报告内键集合和 hash，无法发现少报。
3. 候选实现可在漏验 PRD 独立验收标准或红线的情况下进入 `EVALUATE` / debrief。

**修正:**

- PRD FR6、验收标准、MUST 明确主 agent 必须独立重算结构化核对基准。
- TC10/TC11 增加少报键但报告内自洽的负向场景。
- T5 步骤1 增加 canonical 键派生规则：`PRD-AC` 来自 PRD 独立验收标准顶层 bullet；`MUST` / `MNOT` 来自对应章节顶层 bullet；按文档顺序编号，多行和嵌套内容归属顶层 bullet。
- T5 步骤1 增加 hash 规范：规范化 UTF-8、LF、去除行尾空白、保留条目内部顺序和缩进语义后 SHA-256。
- T1/T2/T5/T6 进入 EVALUATE/复盘前均要求主 agent 独立重算基准；impl 报告内嵌基准不能作为唯一事实来源。

### RT16-B58: 首次完整性闸门未强制对照真实 diff / worktree 改动清单

**复现路径:**

1. impl 候选只实现一小部分，但覆盖矩阵和 live TODO 表全部自报 `done`。
2. 若主 agent 不检查候选 worktree 的真实 diff / 改动文件清单，矩阵全绿即可通过闸门。
3. 缺 T6/T7/T8 镜像文件或空 diff 的候选可进入 `EVALUATE` / debrief。

**修正:**

- PRD FR6、验收标准、MUST 明确主 agent 必须核对真实 diff / 改动文件清单。
- TC10/TC11 增加矩阵全绿但 diff 缺文件或空 diff 的负向场景。
- T5 步骤1 要求闸门通过前核对候选 worktree 真实 diff / 改动文件清单，并把候选 worktree/分支、diff/文件清单摘要写入闸门结论。
- T5 live TODO 证据要求必须能被真实 diff / 改动文件清单复核。
- T6 live/rehearse/debrief 首次闸门和补审都要求独立基准 + diff 核对；缺独立基准或 diff 核对结论不得评分。
- T1/T2 autopilot/resume 进入 EVALUATE 前必须确认存在真实 diff / 改动文件清单核对结论。

## Held

- RT15-B56 已守住：T7 文件清单和顶部 close-loop 文件地图已包含 `/sandtable-plan`、`writing-tests`、`writing-plan` 全部镜像。
- PRD 未确认门禁和确认证据防伪未发现新破口。
- 冷启动 autopilot 文档链仍属设计选择，不计入 breach。

## Next

已修正 `prd.md`、`tests.md`、`plan.md`。重新运行 mental；若闭环，再运行 redteam 复攻。
