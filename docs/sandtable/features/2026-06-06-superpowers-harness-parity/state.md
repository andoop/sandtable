---
feature: 2026-06-06-superpowers-harness-parity
phase: CANCELLED
blocked: false
updated: 2026-06-06T16:00:00+08:00
cancelled_at: 2026-06-06T16:00:00+08:00
cancel_reason: 开发者主动终止；未进入 INTEGRATE，sandtable 主仓无代码改动
tasks:
  - id: T1
    title: Rewrite README as harness-first install matrix
    status: cancelled
  - id: T2
    title: Add OpenCode repo-side companion files
    status: cancelled
  - id: T3
    title: Add Gemini CLI repo-side companion files
    status: cancelled
  - id: T4
    title: Reposition INSTALL as secondary generic path
    status: cancelled
  - id: T5
    title: Repo-side consistency verification
    status: cancelled
  - id: T6
    title: Version bump toolchain (.version-bump.json + script)
    status: cancelled
  - id: T7
    title: Codex official sync script (nested layout)
    status: cancelled
  - id: T8
    title: docs/PUBLISHING.md runbook
    status: cancelled
  - id: T9
    title: sandtable-marketplace repo scaffold + publish
    status: cancelled
  - id: T10
    title: Claude official + Cursor marketplace submission
    status: cancelled
  - id: T11
    title: Codex official PR + harness smoke tests
    status: cancelled
  - id: T12
    title: Full parity verification (TC1–TC14)
    status: cancelled
rehearsals:
  mental:  { runs: 2, last: closed }
  redteam: { runs: 1, last: breach-fixed }
  impl:    { runs: 0, last: none }
autonomy:
  mode: manual
  last_decision: developer-terminated
selected_impl: none
---

## 当前进展
**已终止（CANCELLED）。** 开发者决定不再推进 superpowers harness/marketplace 对齐。本 feature 仅产出 `docs/sandtable/features/2026-06-06-superpowers-harness-parity/` 下文档与推演记录；**sandtable 主仓 README/INSTALL/插件文件均未改动**。

## 终止前已完成
- PRD / tests / plan（含扩 scope 后的 T1–T12）
- 头脑预演 ×2（LOGIC_CLOSED）
- 红蓝对抗 ×1（6 处 ANOMALY 已写入 plan/tests，未落地代码）
- Q1–Q4 决策记录；Q5/Q6 账号澄清

## 保留资产（供日后参考，非生效需求）
- `prd.md`、`plan.md`、`tests.md`、`rehearsals/`、`journal.md`、`questions.md`
