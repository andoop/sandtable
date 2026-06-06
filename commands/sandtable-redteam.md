---
description: 红蓝对抗（OPFOR）· 派红军子 agent 专门攻击当前计划或实现，找出会让它崩的场景、隐藏耦合、悄悄违反的红线；每个被攻破处都进修正循环。
---

对当前需求发起红蓝对抗；读取并遵循 `skills/red-team-wargame/SKILL.md`。

执行：
1. 问我（或据 state 判断）这轮打**计划**还是打**实现**。读对应材料：`plan.md` 或某个实现预演的 diff/分支，以及 `prd.md` 验收、`constraints.md` 红线。
2. 按 `opfor-prompt.md` 给每个红军子 agent 指派攻击向量（反例/边界/假设斩首/侧翼包抄/红线渗透/回归伏击/范围蔓延/需求背离），并行开打。要求每记杀招【可复现】。
3. 收集战报：
   - 有 `BREACH_FOUND` → 你**亲自核实杀招是否真成立** → 成立的登记为 ANOMALY → 问我/修正 PRD/用例/计划 → 重演。
   - 全部 `HELD` → 记录各向量为何没攻破，作为信心依据。
4. 写入 `rehearsals/redteam-<n>.md`，journal 追加，更新 `state.md`（redteam 计数）。

铁律：红军往死里打、不找补；空泛"可能有风险"不算攻破，必须给可复现杀招；主 agent 不轻信红军也不轻信蓝军。

8. 完成后加载 `skills/closing-the-loop/SKILL.md`，读 `state.md`，输出收尾（本命令已列出的链内后续步骤除外；链内切换用战报 profile）。不得越权执行**本命令未列出**的下一阶段（`/sandtable-autopilot`、`/sandtable-rehearse` 除外）。
