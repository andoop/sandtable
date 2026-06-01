---
feature: <YYYY-MM-DD>-<slug>
phase: INTAKE            # INTAKE|RECON|OBJECTIVES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|EVALUATE|INTEGRATE|VERIFY|DONE
blocked: false
updated: <ISO8601>
tasks: []                # - { id: T1, title: ..., status: todo }  status: todo|doing|rehearsed|integrated|verified|done
rehearsals:
  mental:  { runs: 0, last: none }  # none|closed|anomaly
  redteam: { runs: 0, last: none }  # none|held|breach
  impl:    { runs: 0, last: none }  # none|done|anomaly|blocked
selected_impl: none      # 择优后填入选定的 impl 预演报告文件名
---

## 当前进展
（现在在哪一步，下一步做什么。）

## 关键决策（最近）
（指向 journal.md 近期要点。）
