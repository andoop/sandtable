---
feature: 2026-06-06-plugin-update
phase: DONE             # INTAKE|RECON|OBJECTIVES|TESTCASES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|EVALUATE|INTEGRATE|VERIFY|DONE|FEEDBACK
blocked: false          # 实现完成于 main 工作树（未提交）；UPDATE.md + README + INSTALL + 修 templates/en；TC1-8 通过
updated: 2026-06-06T20:25:00+08:00
tasks:
  - { id: T1, title: 新建 UPDATE.md（AI 驱动更新指南）, status: todo }
  - { id: T2, title: README 如何更新节, status: todo }
  - { id: T3, title: INSTALL.md 更新指引, status: todo }
rehearsals:
  mental:  { runs: 1, last: closed }
  redteam: { runs: 1, last: held }
  impl:    { runs: 1, last: done }
autonomy:
  mode: manual
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none
selected_impl: rehearsals/impl-1-plugin-update.md
---

## 当前进展
INTAKE + RECON 完成：为 Sandtable 增加"已安装用户的更新机制"。当前 OBJECTIVES，待 D1-D5 拍板后写 PRD。

## 关键决策（最近）
见 journal.md 2026-06-06 RECON 简报；待答见 questions.md。
