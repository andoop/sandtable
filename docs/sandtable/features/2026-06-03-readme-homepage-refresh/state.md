---
feature: 2026-06-03-readme-homepage-refresh
phase: MENTAL_REHEARSAL
blocked: false
updated: 2026-06-04T08:50:00+08:00
tasks:
  - { id: T1, title: 重构 README 首屏叙事, status: doing }
  - { id: T2, title: 加入明确流程图与差异化对比, status: todo }
  - { id: T3, title: 保留试用路径并补上自举证明, status: todo }
  - { id: T4, title: 文案终审与 GitHub 呈现检查, status: todo }
rehearsals:
  mental:  { runs: 4, last: closed }
  redteam: { runs: 0, last: none }
  impl:    { runs: 0, last: none }
autonomy:
  mode: autopilot
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 2, redteam: 0, impl: 0 }
  last_decision: 第 3 轮 mental 已发现“白话可懂性”和“主句/Quickstart 软口号/双选题”残余口子，并已补入 prd/tests/plan；等待本轮剩余结果后统一判定
selected_impl: none
---

## 当前进展
已为“README GitHub 首页重塑”建立新 feature，并完成侦察、PRD、测试用例和改动计划。当前已完成 2 轮有效 mental；下一步继续补满最后 1 轮 mental，再进入 redteam。

## 关键决策（最近）
- 采用“重构 README 首页信息架构”而不是只追加几段卖点。
- `superpowers` 对比只允许写重心差异与 Sandtable 的前置记忆点，不允许失实贬低。
- 前两屏只优先服务“为什么值得试”“如何闭环防失控”两个判断题，流程图必须紧接首屏。
- `superpowers` 对比只允许“已核实事实 + 重心差异 + 读者先感知到什么”，禁止无证优越性判断词。
- `superpowers` 对比中的每个对比点都必须带事实锚点，不能只做整块语气约束。
- 本次实现范围限定在 `README.md` 与本 feature 文档。
