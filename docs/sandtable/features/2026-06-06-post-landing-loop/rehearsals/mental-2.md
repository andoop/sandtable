# 头脑预演报告 · mental-2（修正后复验，主 agent）

> 方式：主 agent 只读复验 mental-1 三处异常的修正是否闭环（子 agent 上轮被用户中断，故主 agent 自验）。
> 结论：**LOGIC_CLOSED**（M1/M2/M3 修正成立，无新异常；保留 1 条已记录的残余风险）。

## M1 复验（FEEDBACK vs autopilot）→ 闭合
- FR-LIFECYCLE 现明确：FEEDBACK 人在环；autopilot 不驱动（范围止于 EVALUATE/DONE，对齐 `autonomous-orchestration:13`）；"等待用户确认收敛"=合法停点；恢复按 phase。`[prd.md FR-LIFECYCLE]`
- 与 autonomous-orchestration「自动模式默认自己继续，除非真阻塞」无冲突：FEEDBACK 根本不在 autopilot 驱动面内。逻辑闭环。

## M2 复验（恢复分支缺 FEEDBACK）→ 闭合（计划层）
- plan T4 现要求在 `state-and-memory` 恢复流程自动分支追加："phase 处于 DONE/FEEDBACK 时配额闭包不适用，按 phase 恢复，不得误路由回 EVALUATE"。`[plan.md T4]`
- 该补丁直接堵住"DONE 后 FEEDBACK 被 autopilot resume 误判"的路径。实施时落到 state-and-memory 恢复流程节即可。

## M3 复验（无日志死锁）→ 闭合
- FR-BUGFIX-COLLECT 增"无日志出路"：不能自动采、用户给不出、又非纯静态可判定 → 不擅自降级，置 blocked + questions.md 问开发者；FR-BUGFIX-GATE 1 引用之。`[prd.md FR-BUGFIX-COLLECT/GATE]`
- 生命周期停在 INVESTIGATING + blocked，出口明确（开发者补手段或裁决），不死锁。守住"100%"字面。

## 新异常扫描 → 无
- 无日志→blocked 与 closing-the-loop blocked 分支、autopilot 外部阻塞处理一致；FEEDBACK 按 phase 恢复与 state-and-memory「manual 按 phase 恢复」一致。未引入新矛盾。

## 残余风险（已记录，不阻断）
- "日志100%锁因果链" 与 "红军证伪候选根因" 的先后/权重，须在 bugfix skill 正文写清（建议：先日志贯通因果链，再红军证伪，互补非冗余）。已在 plan T2 skill 正文体现顺序，redteam 阶段可再压测。
