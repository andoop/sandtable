---
feature: 2026-06-06-post-landing-loop
phase: VERIFY           # INTAKE|RECON|OBJECTIVES|TESTCASES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|EVALUATE|INTEGRATE|VERIFY|DONE|FEEDBACK
blocked: false          # 单一实现完成于分支 sandtable/post-landing-loop；TC1–TC28 结构校验通过；待开发者验收+合并
updated: 2026-06-06T17:50:00+08:00
tasks:
  - { id: T1, title: 新建 triaging-feedback skill（中文源）, status: todo }
  - { id: T2, title: 新建 bugfix-with-evidence skill（中文源，含日志100%门禁+推演武器）, status: todo }
  - { id: T3, title: 新建 templates/feedback.md, status: todo }
  - { id: T4, title: FEEDBACK 阶段写入 7 个状态机单一事实来源, status: todo }
  - { id: T5, title: 新建 /sandtable-bug 与 /sandtable-bugfix（中文 3 根）, status: todo }
  - { id: T6, title: 镜像同步 plugins/sandtable + locales/en, status: todo }
  - { id: T8, title: 全局教训闭环 lessons.md + init + 反哺交叉引用, status: todo }
  - { id: T7, title: 全局一致性核对（接 VERIFY）, status: todo }
rehearsals:
  mental:  { runs: 2, last: closed }
  redteam: { runs: 2, last: held }
  impl:    { runs: 1, last: done }
autonomy:
  mode: manual
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none
selected_impl: rehearsals/impl-1-post-landing-loop.md
---

## 当前进展
前五步完成并三轮精修。PRD 现含：FEEDBACK 阶段、两 skill、两命令、自动收集日志、调查红军分队、反馈生命周期(用户确认关闭)、关闭三件套(根因/预防/教训)、全局 lessons.md + 教训反哺 RECON/红军/PRD。第三轮：**debug→bugfix 改名**、**根因必靠日志100%确认(最根本门禁)**、**排查动用推演武器(mental/recon/红军证伪)+广深发散**。tests.md=TC1–TC24；plan.md=T1–T8。下一步进入推演。

## 关键决策（最近）
- 单 feature + 两 skill（`triaging-feedback` + `bugfix-with-evidence`）。
- 新增 `FEEDBACK` 阶段，DONE 后可重入。
- per-feature `feedback.md` 台账 + 回写 tests.md 回归用例。
- 新增 `/sandtable-bug` 与 `/sandtable-bugfix` 命令（debug 已改名 bugfix）。
- bugfix 硬门禁：根因必靠日志100%(最根本) + 自带框架/统一tag/根因后清理；禁表面/临时修复。
- 排查动用推演武器(mental/recon/红军证伪)，思维广+深+发散。
详见 journal.md（含 2026-06-06 16:25 第三轮精修）。
