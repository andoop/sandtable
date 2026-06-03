---
feature: 2026-06-03-autonomous-orchestrator
phase: MENTAL_REHEARSAL
blocked: false
updated: 2026-06-03T08:52:00+08:00
tasks:
  - { id: T1, title: 新增自主总指挥 skill `skills/autonomous-orchestration/SKILL.md`, status: todo }
  - { id: T2, title: 新增 `/sandtable-autopilot` 双命令入口, status: todo }
  - { id: T3, title: 扩展 `state.md` 承载自动模式并接入 status/resume, status: todo }
  - { id: T4, title: 把 autopilot 接入现有流程说明与入口边界, status: todo }
  - { id: T5, title: 同步 README / AGENTS / Cursor rule / project 索引, status: todo }
  - { id: T6, title: 全仓对账与 tests.md 验收回归, status: todo }
rehearsals:
  mental:  { runs: 0, last: none }
  redteam: { runs: 0, last: none }
  impl:    { runs: 0, last: none }
selected_impl: none
---

## 当前进展
已完成本需求的侦察、目标、测试用例与改动计划编写。头脑预演第 3 轮又发现恢复语义层面的计划级 anomaly，现已补充 `phase` 同步、`BLOCKED` 分流与“最早尚未重新验证阶段”规则；当前仍在 `MENTAL_REHEARSAL`，待继续重演。

## 关键决策（最近）
- 采用“新增 `/sandtable-autopilot` + `skills/autonomous-orchestration/SKILL.md`”方案，而不是硬塞进现有 `/sandtable-rehearse`。
- 自动模式的最低配额固定为 `mental 3x3 / redteam 3x3 / impl 2x2`，作为硬门槛写入 PRD / tests / plan。
- 自动模式状态将复用 `state.md` 承载，不额外新增仓外配置文件。
- 已核实并修正三处计划缺口：`/sandtable-start` 必须真正收束为前五步入口；`autonomy.mode` 作为唯一权威开关且每次自动推进/回退都写 `last_decision`；README 除命令表外还要同步目录结构中的新 skill。
- 已补齐恢复语义：`phase` 是当前阶段权威字段；`BLOCKED` 先由主 agent 分类为“内部可修正”或“真正阻塞”；回退目标按“最早尚未重新验证的阶段”判定。
