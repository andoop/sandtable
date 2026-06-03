---
description: 换人/换 AI/异常退出后，按持久化状态与当前模式恢复并续接。
---

读取并遵循 `skills/state-and-memory/SKILL.md` 的"恢复流程"。

执行：
1. 读全局 `docs/sandtable/project.md` 与 `constraints.md`，建立项目目标与红线认知。
2. 列出 `features/`，确认要恢复的需求（多个时问我）。
3. 读该需求 `state.md`，优先恢复 `autonomy.*`、`phase` 与 `tasks`；若 `blocked: true`，先读 `questions.md` 处理阻塞问题。
4. 读 `journal.md` 近期条目重建上下文——**已记录的决策按记录执行，不要重新发明**。
5. 读 `prd.md`、`tests.md`、`plan.md`、`rehearsals/` 已有报告。
6. 若 `autonomy.mode=autopilot` 且 `blocked=false`，把这次 `/sandtable-resume` 视为显式 autopilot 续跑：只在本回合启用 `<AUTOPILOT-OVERRIDE>`，并按未完成的最低配额继续推进；优先级是 `mental → redteam → impl → EVALUATE`，不要用手动 `rehearsals.*` 抵扣 `autonomy.completed_rounds`。
7. 仅当 `autonomy.mode=manual` 或 `blocked=true` 时，用 3–5 行向我复述："我们在做什么、进行到哪、上次为什么停、下一步要做什么"，等我确认后继续。

只在发现矛盾或缺失时才回到 `being-truthful` 去澄清；不要把 autopilot 的恢复语义静默覆盖到我之后显式触发的手动 slash。
