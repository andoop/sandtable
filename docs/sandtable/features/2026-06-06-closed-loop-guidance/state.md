---
feature: 2026-06-06-closed-loop-guidance
phase: VERIFY
blocked: false
updated: 2026-06-06T18:00:00+08:00
tasks:
  - id: T1
    title: 新增 closing-the-loop skill 与 phase→下一步映射
    status: integrated
  - id: T2
    title: 接入 using-sandtable / rules / AGENTS 索引
    status: integrated
  - id: T3
    title: 更新 commands 与 autonomous-orchestration 收尾纪律
    status: integrated
  - id: T4
    title: 同步英文 locale 与 plugins/sandtable 镜像
    status: integrated
rehearsals:
  mental:  { runs: 3, last: anomaly }
  redteam: { runs: 1, last: breach }
  impl:    { runs: 1, last: done }
autonomy:
  mode: autopilot
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 0, redteam: 0, impl: 1 }
  last_decision: mental-3 anomaly 已修并落地主仓；推演硬配额未完全闭包，进入 VERIFY
selected_impl: impl-1-main.md
---

## 当前进展

前五步已完成：`INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN`。autopilot 本回合：修 mental-3 anomaly → 主仓落地 `closing-the-loop` 全接入（见 impl-1-main）。**推演硬配额未闭包**（mental/redteam autopilot 轮次不足；impl 未用双 worktree）。`selected_impl=impl-1-main.md`。待 VERIFY 勾选 tests。

## 关键决策（最近）

- 采用「独立 skill + 主入口索引」方案（见 journal 2026-06-06 方案决策）。
- 手动模式：回合末用 AskQuestion（可用时）或可复制 slash 模版；autopilot：主 agent 自行续跑，不弹选择题。
