---
description: 依次执行 Sandtable 推演与复盘：头脑预演→红蓝对抗→实现预演→复盘择优。
---

对当前需求依次执行三种推演 + 复盘；读取并遵循 `skills/using-sandtable/SKILL.md`。

执行：
1. 若需求是“从原始需求一路无人值守推进到复盘”，改用 `/sandtable-autopilot`；本命令只负责推演与复盘，不负责前序 `RECON / OBJECTIVES / TESTCASES / PLAN`。
2. 读 `docs/sandtable/features/<当前需求>/` 的 `state.md`、`prd.md`、`tests.md`、`plan.md`、`constraints.md`，确认当前 phase。
3. **头脑预演**：加载 `mental-rehearsal`，按 `mental-rehearsal-prompt.md` 并行派发只读子 agent。〔= `/sandtable-mental`〕
   - 任一 `ANOMALY_FOUND` → 亲自核实 → 必要时写 `questions.md` 问我 → 修正 `prd.md`/`tests.md`/`plan.md` → 重演。
   - 全部 `LOGIC_CLOSED` → 进入下一步。
4. **红蓝对抗**：加载 `red-team-wargame`，对计划派红军子 agent 进攻。〔= `/sandtable-redteam`〕
   - 有 `BREACH_FOUND`（已核实成立）→ 登记 ANOMALY → 问我/修正 → 回第 2 步重演。
   - 全部 `HELD` → 进入下一步。
5. **实现预演**：加载 `implementation-rehearsal`，每个预演独立 git worktree/分支，并行派发实现子 agent。〔= `/sandtable-live`〕
   - 任一 `ANOMALY_FOUND`/`BLOCKED` → 亲自核实 → 问我 → 修正计划 → 回第 2 步重演。
   - 全部 `DONE` → 进入复盘。
6. **复盘择优**：加载 `evaluating-rehearsals` 打分，把选定方案写入 `state.md`。〔= `/sandtable-debrief`〕
7. 每轮报告写入 `rehearsals/`，journal 追加。链内阶段切换仅**战报收尾**（禁止省略）；命令结束/阻塞/异常停时加载 `closing-the-loop` 输出**完整收尾**（含择优说明与可复制模版）。

两条铁律：异常即停上报、推演在隔离子 agent 中并行进行。不轻信子 agent 结论，抽查其引用与 diff。

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
