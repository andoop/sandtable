---
description: 启动 Sandtable 前五步流程：从一句需求开始，侦察→目标→用例→计划。
---

读取并遵循 `skills/using-sandtable/SKILL.md`，对我接下来描述的需求启动 Sandtable 流程。

执行（这是前五步入口；推演与复盘请使用单独命令或 `/sandtable-autopilot`）：
1. 加载 `state-and-memory`，在目标项目创建/确认 `docs/sandtable/` 结构；若 `project.md`/`constraints.md` 不存在，先和我确认全局目标与红线（用 `templates/` 拷贝）。
2. 为本需求建 `features/<YYYY-MM-DD>-<slug>/` 目录与 `state.md`（phase=INTAKE），记录原始需求（一句话或我给的产品文档）。
3. **RECON**：加载 `gathering-intel` 侦察情报（摸地形、列未知、攒问题问我）。〔= `/sandtable-recon`〕
4. **OBJECTIVES**：加载 `writing-prd` 定目标、MUST/MUST-NOT、红线、验收，请我确认。〔= `/sandtable-objectives`〕
5. **TESTCASES**：加载 `writing-tests` 产出 `tests.md`（标定靶标，检验理解），可用 `/sandtable-refine` 迭代。
6. **PLAN**：加载 `writing-plan` 写 `plan.md`。〔= `/sandtable-plan`〕
7. 完成后提示我：可用 `/sandtable-refine` 反复完善；若只继续推演，用 `/sandtable-mental`→`/sandtable-redteam`→`/sandtable-live`→`/sandtable-debrief` 或 `/sandtable-rehearse`；若要求从需求到复盘无人值守推进，改用 `/sandtable-autopilot`。

全程严格遵守四条底线（不猜测、先思考、外科手术式改动、目标驱动）。每步更新 `state.md` 与 `journal.md`。若任一步我提出修改，按 `/sandtable-refine` 的方式迭代。

我的需求是：
