---
feature: 2026-06-02-test-cases
phase: DONE             # 实现预演 #1 落地，TC1-TC9 全绿
blocked: false
updated: 2026-06-02T08:30:00+08:00
selected_impl: rehearsals/impl-1-test-cases.md
tasks:                   # status: todo|doing|rehearsed|integrated|verified|done
  - { id: T1, title: 新增模板 templates/tests.md, status: done }
  - { id: T2, title: 新增技能 skills/writing-tests/SKILL.md, status: done }
  - { id: T3, title: 脚手架 sandtable-init.sh 拷贝 tests.md, status: done }
  - { id: T4, title: 状态机插入 phase TESTCASES（6 处副本一致）, status: done }
  - { id: T5, title: skills 衔接 PRD→tests→plan, status: done }
  - { id: T6, title: 三类推演 prompt 注入逐条用例突破点, status: done }
  - { id: T7, title: 命令编排衔接（6 命令双副本同步）, status: done }
  - { id: T8, title: 全局文档计数与目录结构, status: done }
  - { id: T9, title: 整体验证（对齐 TC1-TC9）, status: done }
  - { id: T10, title: 异常写回清单+frontmatter描述+sandtable-mental 统一, status: done }
rehearsals:
  mental:  { runs: 3, last: closed }  # 轮3子agent超时中断，主agent全仓grep审计闭合(mental-5)
  redteam: { runs: 0, last: none }  # 开发者选择直接实现预演，跳过
  impl:    { runs: 1, last: done }  # impl-1 DONE，主agent复核 TC1-TC9 全绿
---

## 当前进展
DONE。实现预演 #1（隔离 worktree）按 T1-T10 完整实现，主 agent 亲自复核 TC1-TC9 全绿、diff 外科手术式无越界。源码改动已取入主仓 master，与本需求文档一并提交。worktree/分支待清理。

## 关键决策（最近）
- 缺口已确认：现有 PRD §5 验收标准是抽象判定条件，缺"场景化、具体输入→预期输出、人可一眼看懂"的测试用例来检验 AI 理解。
- 推荐：新增一等公民产物 `tests.md` + 技能 `writing-tests`，定位在 PRD 与 plan 之间，作为"理解对账闸门"，并喂给三类推演当统一突破点、VERIFY 当验收对账。范围/形态待 Q1-Q4 确认。
