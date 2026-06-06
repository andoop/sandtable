# 头脑预演报告 · mental-1（主 agent 自跑，子 agent 被用户中断后）

> 方式：主 agent 只读推演 4 条逻辑链（状态机一致性 / bugfix 闭环 / 生命周期+教训 / 镜像红线），基于真实仓库文件。
> 结论：**ANOMALY_FOUND ×3**（M1、M2 = 状态机与计划缺口；M3 = 方法论张力）。链路暂停，待核实/开发者裁决后修正计划重演。

## 已确认事实（grounding）
- 4 个 skill 镜像根均存在（closing-the-loop 在 4 根齐全）。`[已确认: Glob]`
- autopilot 强制覆盖范围仅 `INTAKE → … → EVALUATE`；FEEDBACK **不在** autopilot 配额/范围内。`[已确认: skills/autonomous-orchestration/SKILL.md:13]`
- autopilot 恢复/续跑"先看 completed_rounds 配额闭包，再看 phase；三类配额达标→EVALUATE"。`[已确认: autonomous-orchestration:42-47; state-and-memory/SKILL.md:117-124]`

## ANOMALY M1 · 用户确认关闭闸门 vs autopilot 非阻塞纪律未定义交互
- 偏差：FR-LIFECYCLE 要求"未经用户确认收敛不得 CLOSED"；但 autonomous-orchestration 纪律是"自动模式默认自己继续，除非真阻塞"`[autonomous-orchestration:76]`。两者交互**未在任何文档定义**：FEEDBACK 是否可被 autopilot 驱动？"等待用户确认收敛"该映射成什么状态（blocked=true？新生命周期态？closing-the-loop 的 blocked 分支？）。
- 为什么是问题：歧义会导致 agent 要么（a）在 autopilot 下**擅自关闭**未经用户确认的反馈（违反 FR-LIFECYCLE 核心闸门），要么（b）卡死无所适从。
- 影响范围：FR-LIFECYCLE、autonomous-orchestration、closing-the-loop（blocked 分支）、plan T1/T4。
- 需澄清：FEEDBACK 是否定性为"人在环、永远 manual 风格"（autopilot 不驱动 FEEDBACK；等待用户确认=合法停点）？

## ANOMALY M2 · state-and-memory 恢复/配额逻辑缺 FEEDBACK 分支（计划 T4 缺口）
- 偏差：autopilot 恢复分支据 completed_rounds 配额推下一步，三类配额达标→EVALUATE`[state-and-memory:117-124]`。一个已 DONE 后进入 FEEDBACK 的 feature，其三类配额本就全部达标——若此时 `/sandtable-resume` 且 `autonomy.mode=autopilot`，恢复逻辑会把它**误路由回 EVALUATE**，丢失 FEEDBACK 语境。
- 计划 T4 只改了 phase 枚举/状态机图/阶段表，**没有**给 state-and-memory 的"恢复流程/配额闭包分支"补 FEEDBACK 情形。
- 为什么是问题：FEEDBACK 在 DONE 之后、不属任何配额，现有恢复分支对它无定义 → 续跑误判。
- 影响范围：plan T4（需补 state-and-memory 恢复分支：phase 处于 DONE/FEEDBACK 时配额闭包不适用，按 phase 恢复）。
- 处置：M2 是明确计划缺口，主 agent 可直接修正 plan T4（待 M1 定性后一并改）。

## ANOMALY M3 · 根因必靠日志100% 在"日志确实拿不到"时无出路（死锁）
- 偏差：HARD-GATE 1 要求根因必有日志/运行时证据，例外仅"纯静态可判定"。FR-BUGFIX-COLLECT 覆盖"只有用户能给→请用户给"。但当**既不能自动采、用户也给不出、又非纯静态可判定**时，闭环无定义出口 → 既锁不了根因、也关不了反馈，可能死锁。
- 为什么是问题："最最根本的要求"若无兜底出路，遇到无日志场景会卡死整条 FEEDBACK 闭环。
- 影响范围：FR-BUGFIX-GATE、FR-BUGFIX-COLLECT、plan T2。
- 需澄清：无日志时的出路——升级为 blocked 写 questions.md 问开发者？还是允许"最佳可得证据 + 显式标注残余不确定 + 开发者签字"降级关闭（会削弱"100%"字面）？

## 残余风险（不足以判 anomaly，记录备查）
- "红军证伪候选根因"与"日志100%确认"两关并存，顺序与权重在 skill 正文需写清，否则实施时可能各做各的（建议：先日志锁因果链，再红军证伪，互补非冗余）。
