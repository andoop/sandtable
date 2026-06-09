# MENTAL_REHEARSAL 轮 2 · 修正后计划重演

**信号:** `LOGIC_CLOSED`

## 范围

mental-1 发现计划异常并修正后，重新并行派发 3 个只读子 agent：

- T1/T2：自动模式最低覆盖、状态模板与恢复语义。
- T3/T4/T7：头脑推演真实问题口径、红蓝对抗真实攻破口径、close loop 已选择路径直接执行。
- T5/T6/T8：实现预演覆盖矩阵、live 执行 TODO 表、完整性闸门、镜像一致性。

所有子 agent 均按“只寻找真实问题”的口径执行：无关脑洞、空泛风险、没有现实触发路径的极端场景、仅措辞不完美但不影响执行的点，不算 anomaly。

## 结论

三路均返回 `LOGIC_CLOSED`。

## 已核对闭环

- mental-1 A1/A2/A3 已修正：英文 state bundle 归入 T2，T1 不再误列 `locales/en/plugins/sandtable/skills/SKILL.md`；T2 明确修改恢复流程图与自动分支末项，不再写死 `EVALUATE`。
- mental-1 A4/A5 已修正：autopilot impl 自报 `DONE` 后必须先过完整性闸门；implementation prompt 必须提供全量 `prd.md` / `tests.md` 输入，或授权只读打开三文档以支撑覆盖矩阵。
- TC1-TC4：1/1/1 最低覆盖、自主追加/评估、resume 恢复、FEEDBACK/DONE 特殊分支在计划层面闭环。
- TC5-TC8：头脑推演和红蓝对抗的新口径保留不猜测、关键异常即停、可复现攻破与主 agent 核实。
- TC9-TC11：覆盖矩阵、live 执行 TODO 表、完整性闸门覆盖手动 live/rehearse/debrief 和 autopilot 路径。
- TC12-TC15：close loop 已选择即执行不破坏 `/sandtable-start` PRD 未确认必须停和 `blocked=true` 阻塞优先。
- TC16-TC20：镜像路径与 `INSTALL.md` 一致，含 `templates/en/`，未误用 `locales/en/templates/`；范围仍限定为方法论文档和命令提示词。

## 残余风险（不构成 anomaly）

- 实现 T3 时需确保 skill 侧和 prompt 侧都收窄“不确定即 anomaly”的旧表述，不能只改 prompt。
- 实现 T4 时需一并处理 `red-team-wargame` 中“往死里打”的进攻向量段，避免只改开头。
- 实现 T7 时建议把“已选择路径优先”放在 `blocked=true` 判定之后，保持阻塞优先的字面顺序。
- 实现 T5/T6 时优先把完整性闸门结论写入 `rehearsals/impl-*.md`，若写入 journal，debrief 前置检查也要读取 journal。

## 下一步

mental 已闭环，可进入红蓝对抗。红军口径应只接受真实、可复现、与 PRD/plan/code reality 有关的破口；空泛风险和偏题脑洞不算 `BREACH_FOUND`。
