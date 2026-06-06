---
description: 从需求到复盘全流程无人值守推进
---

对当前需求执行 Sandtable 自动模式；读取并遵循 `skills/autonomous-orchestration/SKILL.md`。

执行：
1. 本命令显式启用 `<AUTOPILOT-OVERRIDE>`，且只对这次 `/sandtable-autopilot` 生效；之后若我显式触发手动 slash，按该手动命令的边界执行，不要静默延续 override。
2. 读 `docs/sandtable/project.md`、`constraints.md` 与当前需求；必要时创建/续接 feature 目录与 `state.md`。
3. 把 `state.md` 写成 `autonomy.mode=autopilot`，并初始化/刷新 `autonomy.min_rounds`、`autonomy.min_agents_per_round`、`autonomy.completed_rounds`、`autonomy.last_decision`。
4. 自动完成 `RECON → OBJECTIVES → TESTCASES → PLAN`，过程中默认不逐步等我确认。
5. 按硬门槛继续推进：
   - 头脑预演至少 3 轮，每轮至少 3 个只读子 agent；
   - 红蓝对抗至少 3 轮，每轮至少 3 个红军子 agent；
   - 实现预演至少 2 轮，每轮至少 2 个独立 worktree 子 agent。
6. 任一 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED`：先亲自核实，写回 `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md`，然后按最早尚未重新验证的阶段重演；只有真正阻塞才写 `questions.md` 并向我提问。
7. 各阶段之间不等待用户确认；阶段切换时更新 state、输出**战报收尾** profile，并在同一命令内继续执行。全部配额达标并完成复盘择优后，加载 `closing-the-loop` 输出**完整收尾**（含可复制模版）。`blocked=true` 时输出**完整收尾**并可用 AskQuestion（FR5 优先于 autopilot 静默纪律）。
