---
description: 战损复盘（AAR）· 当多个实现预演都通过后，按客观评分表打分择优，选出最强的实现准备落地。
---

对当前需求的实现预演结果复盘择优；读取并遵循 `skills/evaluating-rehearsals/SKILL.md`。

执行：
1. 门禁检查：仅当本轮所有实现预演都 `DONE` 且完整性闸门通过时才打分。闸门必须核对覆盖矩阵、live TODO 表、主 agent 独立结构化基准与真实 diff / 改动文件清单；任一 `ANOMALY`/`BLOCKED`、闸门缺失或闸门未通过 → 不打分，回修正循环（修计划→重演）。
2. 主 agent **亲自读每个预演的真实 diff**，不轻信自评。
3. 按评分表逐项打分（需求符合度×3、正确性证据×3、极简度×2、外科性×2、可读×1、契合×1；红线符合度为一票否决）。
4. 选最高分；分数接近时取更简单、改动更小者。
5. 把选定方案写入 `state.md` 的 `selected_impl`，phase=INTEGRATE，journal 记录打分与理由，未选中的 worktree/分支清理。
6. 给我一份简短对比（各方案总分、关键差异、为何选 X），等我确认再落地（用户指令可推翻选择）。

8. 完成后加载 `skills/closing-the-loop/SKILL.md`，读 `state.md`，输出收尾（本命令已列出的链内后续步骤除外；链内切换用战报 profile）。缺少明确选择或确认时不得越权执行**本命令未列出**的下一阶段（`/sandtable-autopilot`、`/sandtable-rehearse` 除外）；本回合用户已明确选择/确认且必要证据已先/同时落盘的内联后续，属于本命令允许的链内后续。

## 本需求补充 · 实现预演完整性闸门

`DONE` 只是候选自报完成，不得直接进入 `evaluating-rehearsals` / debrief / EVALUATE。全部候选自报 `DONE` 后，主 agent 必须先执行完整性闸门，简单候选可亲自检查，复杂或高风险候选可按需派只读 mental/redteam 风格子 agent 辅助。

闸门必须包含：
- 主 agent 独立读取当前 `prd.md`、`tests.md`、`plan.md`，重算结构化核对基准；候选报告内嵌基准、覆盖矩阵或 TODO 表只能作为输入，不能作为事实来源。
- 稳定键派生：`FRx` 来自 PRD 原编号；`PRD-AC1...n` 来自 PRD 独立验收标准章节顶层 bullet；`MUST-1...n` 与 `MNOT-1...n` 来自 MUST / MUST NOT 顶层 bullet；`TCx` 来自 tests 原编号；`PLAN Tx/步骤x` 来自 `plan.md` checkbox 原文编号和标题，保留小数编号。
- 正文 hash：提取条目的规范化 UTF-8 文本，LF 换行，去除行尾空白，保留条目内部顺序和缩进语义后计算 SHA-256。任一 FR/PRD-AC/MUST/MNOT/TC/PLAN checkbox 的增删、改名、正文变化或 hash 缺失都导致基准不同。
- 闸门结论记录核对时间、候选 worktree/分支、当前三文档结构化基准、真实 diff 或改动文件清单摘要。不得只用 impl 报告 mtime、粗粒度摘要或标识集合判断是否过期。
- 对照真实 diff / 改动文件清单核查覆盖矩阵和 live 执行 TODO 表；diff 为空、缺少计划要求文件族、缺少主 agent diff 核对结论、少报键、聚合键、无依据 `not-applicable`、`missing` 或 `blocked`，均不得通过。

候选 `DONE` 报告必须包含：
- 覆盖矩阵：`PRD 覆盖 FRx`、`PRD 验收标准 PRD-ACx`、`PRD 红线 MUST-x/MNOT-x`、`TESTS TCx`、`PLAN Tx/步骤x`，逐项列状态与证据，不得用任务级汇总代替步骤级 checkbox。
- live 执行 TODO 表：列 `项` / `来源` / `状态` / `证据`；`项` 使用 `PRD FRx`、`PRD-ACx`、`MUST-x`、`MNOT-x`、`TCx`、`PLAN Tx/步骤x`；`状态` 只能是 `done` / `not-applicable` / `blocked` / `missing`。该表只属于候选报告，不新增独立 TODO 文件，不替代 `plan.md` / `state.md`。
- 覆盖矩阵与 live TODO 表在 PRD FR、PRD-AC、MUST/MNOT、TC、PLAN 步骤键集合上一一对应；冲突时以更细粒度的 `missing` / `blocked` 为准。
