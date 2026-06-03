---
feature: 2026-06-03-autonomous-orchestrator
phase: INTEGRATE
blocked: false
updated: 2026-06-03T22:00:00+08:00
tasks:
  - { id: T1, title: 新增自主总指挥 skill `skills/autonomous-orchestration/SKILL.md`, status: integrated }
  - { id: T2, title: 新增 `/sandtable-autopilot` 双命令入口, status: integrated }
  - { id: T3, title: 扩展 `state.md` 承载自动模式并接入 status/resume, status: integrated }
  - { id: T4, title: 把 autopilot 接入现有流程说明与入口边界, status: integrated }
  - { id: T5, title: 同步 README / AGENTS / Cursor rule / project 索引, status: integrated }
  - { id: T6, title: 全仓对账与 tests.md 验收回归, status: integrated }
rehearsals:
  mental:  { runs: 7, last: closed }
  redteam: { runs: 2, last: held }
  impl:    { runs: 2, last: anomaly }
selected_impl: impl-2-autonomous-orchestrator-impl2-a1b2c3d4.md
---

## 当前进展
已完成本需求的侦察、目标、测试用例、改动计划、两轮实现预演与主工作区集成。开发者已明确接受 B2 作为基底实现，主 agent 已把 `impl-2-autonomous-orchestrator-impl2-a1b2c3d4.md` 对应方案直接落到主工作区，并完成关键一致性与字面验收检查。当前处于 `INTEGRATE`，后续可继续做实现级红蓝对抗或最终验证。

## 关键决策（最近）
- 采用“新增 `/sandtable-autopilot` + `skills/autonomous-orchestration/SKILL.md`”方案，而不是硬塞进现有 `/sandtable-rehearse`。
- 自动模式的最低配额固定为 `mental 3x3 / redteam 3x3 / impl 2x2`，作为硬门槛写入 PRD / tests / plan。
- 自动模式状态将复用 `state.md` 承载，不额外新增仓外配置文件。
- 已核实并修正三处计划缺口：`/sandtable-start` 必须真正收束为前五步入口；`autonomy.mode` 作为唯一权威开关且每次自动推进/回退都写 `last_decision`；README 除命令表外还要同步目录结构中的新 skill。
- 已补齐恢复语义：`phase` 是当前阶段权威字段；`BLOCKED` 先由主 agent 分类为“内部可修正”或“真正阻塞”；回退目标按“最早尚未重新验证的阶段”判定。
- 已在第 4 轮把前序流程与推演链的语义继续收紧：`INTAKE` 由 `state-and-memory` 建档/恢复，`RECON→PLAN` 必须显式沿用四个既有 skill；前序流程回退按“被修正的最早产物映射”决定 `phase`，推演链回退统一回 `MENTAL_REHEARSAL` 并清零 `mental/redteam/impl` 的 `completed_rounds`。
- 已在第 5 轮继续收紧：`<AUTOPILOT-OVERRIDE>` 必须覆盖 `/sandtable-start`、`/sandtable-recon`、`/sandtable-objectives`、`/sandtable-plan`、`/sandtable-resume` 与相关 writing skill 的旧确认门槛；TC8 与 T5/T6 必须同时做正向、负向和命令文件存在性检查，防止“只因出现 autopilot 关键词”而误判通过。
- 已在第 6 轮继续收敛剩余问题：`TC8`、`T5`、`T6` 的检查范围已经明显加强，但三者仍未完全逐字对齐；当前剩余的唯一计划级风险是验收 regex 与存在性检查的假阳性窗口。
- 已在第 7 轮完成最终收口：`TC8 / T4 / T5 / T6` 的验收链已统一为“正向断言 + `! rg` 负向 0 命中 + 文件存在性 + rehearse 正文断言”；`T4` 仅保留为局部预检，`T5/T6` 作为完整终验，头脑预演已拿到 `LOGIC_CLOSED`。
- 已在 redteam 第 1 轮核实并修补：`<AUTOPILOT-OVERRIDE>` 只在 `/sandtable-autopilot` 与 autopilot 版 `/sandtable-resume` 生效；手动 `/sandtable-start` / `/sandtable-rehearse` / `/sandtable-mental` 等不再被 `autonomy.mode=autopilot` 静默覆盖。`phase` 改为“记录位”，续跑先看配额闭包；manual `rehearsals/*.md` / `runs` / `last` 都不得抵 autopilot 的 `completed_rounds`。
- 已在 redteam 第 2 轮完成剩余收口：`state-and-memory` 的 autopilot 回退语义已稳定回归 `TC6 / T3`；`TC8 / T5 / T6` 明确升级为“机器检查 + 人工语义审读”双门槛，不再把 regex 当成语义闭环的唯一证明。
- 已把 `skills/autonomous-orchestration/SKILL.md`、`commands/sandtable-autopilot.md`、`.cursor/commands/sandtable-autopilot.md` 一并纳入 `TC8 / T5 / T6` 的负向扫描与人工审读范围，关闭“主索引收束了，但 autopilot 自己还在复述旧总入口心智”的空档。
- 已在 impl 第 1 轮核实：候选 A 仍保留 `rehearse` 的 `一键串起全部推演`、README / AGENTS / Cursor rule 中的 `总演习` / `总入口`，且 `state-and-memory` 仍有过旧回退描述；候选 B 更接近目标，但 `using-sandtable`、README、Cursor rule 仍残留 `只串起三类推演 + 复盘` / `总入口`。因此这轮未进入评分择优。
- 已在 impl 第 2 轮核实：候选 A2 大部分问题已修掉，但 `skills/using-sandtable/SKILL.md` 仍写“不是总入口”，在当前 `TC8` 字面负向门禁下仍会失败；候选 B2 通过了 `rehearse` 边界、索引收束与 `state-and-memory` autopilot 语义的关键抽查，可作为当前唯一有效候选。
- 开发者已明确要求“基于 B2 直接实现”，因此当前不再等待额外候选；已把 B2 方案直接集成，并将 `selected_impl` 指向 `impl-2-autonomous-orchestrator-impl2-a1b2c3d4.md`。
