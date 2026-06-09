---
feature: 2026-06-09-autopilot-rehearsal-close-loop-optimizations
phase: DONE
blocked: false
updated: 2026-06-09T12:09:00+08:00
tasks:
  - id: T1
    title: 自动模式改为最低覆盖 + 自主追加
    status: done
  - id: T2
    title: 状态模板与恢复语义同步最低覆盖
    status: done
  - id: T3
    title: 调整头脑推演真实问题口径
    status: done
  - id: T4
    title: 调整红蓝对抗真实攻破口径
    status: done
  - id: T5
    title: 实现预演 DONE 覆盖矩阵与完整性审查
    status: done
  - id: T6
    title: live / rehearse / debrief 命令接入完整性闸门
    status: done
  - id: T7
    title: close loop 已选择路径直接执行
    status: done
  - id: T8
    title: 镜像一致性与范围验证
    status: done
  - id: T9
    title: 集成候选实现并最终验证
    status: done
rehearsals:
  mental:  { runs: 34, last: closed }
  redteam: { runs: 21, last: held }
  impl:    { runs: 2, last: done }
autonomy:
  mode: manual
  min_rounds: { mental: 1, redteam: 1, impl: 1 }
  min_agents_per_round: { mental: 1, redteam: 1, impl: 1 }
  completed_rounds: { mental: 0, redteam: 0, impl: 1 }
  last_decision: implementation rehearsal 2 passed completeness gate; selected, applied to main workspace, and final verification passed
selected_impl: docs/sandtable/features/2026-06-09-autopilot-rehearsal-close-loop-optimizations/rehearsals/impl-2-d8cd05cf.md
---

## 当前进展
RECON、OBJECTIVES、TESTCASES、PLAN、MENTAL_REHEARSAL、REDTEAM、IMPL_REHEARSAL、EVALUATE、INTEGRATE 与 VERIFY 已完成；本需求进入 DONE。

## 关键决策（最近）
- 2026-06-09：本需求不修改全局 `project.md` / `constraints.md`，在 feature 内沉淀 PRD 后等待开发者确认。
- 2026-06-09：无阻塞问题；本需求需覆盖中文根源、插件镜像、Cursor 命令镜像与英文 locale。
- 2026-06-09：PRD 推荐采用“最低覆盖 + 自主追加”，不做完整风险分级框架。
- 2026-06-09：开发者通过 AskQuestion 确认 PRD，状态推进到 TESTCASES；本 `/sandtable-start` 回合不继续写 tests/plan。
- 2026-06-09：开发者确认修正后的 TESTCASES；live 完整性检查语义为“必须检查，可亲自或按需派只读子 agent 辅助”。
- 2026-06-09：`plan.md` 已写入 8 个任务，覆盖 TC1-TC20；状态推进到 MENTAL_REHEARSAL。
- 2026-06-09：根据 refine 反馈，`plan.md` 已补 live 执行 TODO 表要求；该表仅存在于实现候选报告内，不新增独立文件。
- 2026-06-09：mental-1 发现计划异常并已修正；需重新运行 mental 预演确认闭环。
- 2026-06-09：mental-2 重演已闭环；下一步进入 REDTEAM。
- 2026-06-09：redteam-1 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-3 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-2 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-4 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-3 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-5 发现计划异常并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-6 发现计划异常并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-7 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-4 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-8 发现计划异常并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-9 发现计划异常并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-10 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-5 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-11 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-6 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-12 发现 redteam-6 修正未落到 T3 任务级文件清单，已修正；需重新运行 mental。
- 2026-06-09：mental-13 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-7 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-14 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-8 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-15 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-9 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-16 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-10 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-17 发现 autopilot “不等待/同命令继续”旧条款未为 PRD 未确认门禁加例外，已修正；需重新运行 mental。
- 2026-06-09：mental-18 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-11 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-19 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-12 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-20 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-13 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-21 发现 PRD/tests 未承接 PRD 确认证据防伪，已修正；需重新运行 mental。
- 2026-06-09：mental-22 重演已闭环；下一步重新运行 redteam。
- 2026-06-09：redteam-14 攻破计划并已修正；需重新运行 mental/redteam，确认修正闭环后才能进入 live。
- 2026-06-09：mental-23 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-15 攻破 T7 文件清单并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-24 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-16 攻破完整性闸门并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-25 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-17 攻破 PRD 确认证据格式并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-26 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-18 攻破 TC13 自然语言证据落盘缺口并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-27 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-19 攻破 PRD 确认证据落盘入口绑定并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-28 发现 TC12 未同步 AskQuestion 证据持久化要求并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-29 发现 TC13/PRD 未同步自然语言证据前置持久化要求并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-30 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-20 攻破 T1/T2 本回合确认未绑定落盘并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-31 发现 T1 步骤3 仍有本回合确认弱表述并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-32 发现手动推演/live 入口未绑定同条 PRD 确认落盘并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-33 发现 `/sandtable-plan` / `writing-plan` 未绑定同条 PRD 确认落盘并已修正；需重新运行 mental/redteam。
- 2026-06-09：mental-34 已闭环；下一步重新运行 redteam 复攻。
- 2026-06-09：redteam-21 已守住；下一步进入 implementation rehearsal。
- 2026-06-09：implementation rehearsal 1 因隔离 worktree 缺当前未提交 feature 文档而停止；需带主工作区文档重新运行。
- 2026-06-09：implementation rehearsal 2 通过完整性闸门；主 agent 在闸门中发现并修复两个真实实现 anomaly（autopilot 续接逻辑、DONE 直达评分表述），随后选中并集成到主工作区。
- 2026-06-09：最终验证通过；`ReadLints` 无错误，关键搜索未发现会导致需求失败的残留旧口径。
