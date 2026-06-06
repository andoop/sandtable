---
description: 依次执行 Sandtable 推演与复盘：头脑预演→红蓝对抗→实现预演→复盘择优。
---

对当前需求依次执行三种推演 + 复盘；读取并遵循 `skills/using-sandtable/SKILL.md`。

执行：
1. 若需求是“从原始需求一路无人值守推进到复盘”，改用 `/sandtable-autopilot`；本命令只负责推演与复盘，不负责前序 `RECON / OBJECTIVES / TESTCASES / PLAN`。
2. 读 `docs/sandtable/features/<当前需求>/` 的 `state.md`、`prd.md`、`tests.md`、`plan.md`、`constraints.md`，确认当前 phase。
3. **头脑预演**：加载 `mental-rehearsal`，按 `mental-rehearsal-prompt.md` 并行派发只读子 agent。〔= `/sandtable-mental`〕
   - 任一 `ANOMALY_FOUND` → 亲自核实 → 必要时写 `questions.md` 问我 → 修正 `prd.md`/`tests.md`/`plan.md` → 重演。
   - 全部 `LOGIC_CLOSED` → 进入下一步。
4. **红蓝对抗**：加载 `red-team-wargame`，对计划派红军子 agent 进攻。〔= `/sandtable-redteam`〕
   - 有 `BREACH_FOUND`（已核实成立）→ 登记 ANOMALY → 问我/修正 → 回第 2 步重演。
   - 全部 `HELD` → 进入下一步。
5. **实现预演**：加载 `implementation-rehearsal`，每个预演独立 git worktree/分支，并行派发实现子 agent。〔= `/sandtable-live`〕
   - 任一 `ANOMALY_FOUND`/`BLOCKED` → 亲自核实 → 问我 → 修正计划 → 回第 2 步重演。
   - 全部 `DONE` → 进入复盘。
6. **复盘择优**：加载 `evaluating-rehearsals` 打分，把选定方案写入 `state.md`。〔= `/sandtable-debrief`〕
7. 每轮报告写入 `rehearsals/`，journal 追加。择优后告诉我选了哪个、为什么，等我确认再 INTEGRATE 落地。

两条铁律：异常即停上报、推演在隔离子 agent 中并行进行。不轻信子 agent 结论，抽查其引用与 diff。
