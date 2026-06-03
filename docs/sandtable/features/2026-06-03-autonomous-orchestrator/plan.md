# 全自主自动沙盘编排 autopilot 改动计划

**目标:** 新增一个 `/sandtable-autopilot` 全自动入口，让 AI 无需人工逐步接力即可从需求侦察推进到多轮推演与复盘，并把自动模式配额持久化到 `state.md`。
**架构:** 采用“新 skill + 新命令 + 扩展 state 持久化 + 更新全局索引”的方案。自动编排逻辑集中在 `skills/autonomous-orchestration/SKILL.md`，命令只做入口；状态/恢复沿用现有 `state.md` 体系承载自动模式字段；README 与总入口文档补入新入口但不移除手动命令。
**对应 PRD:** `prd.md`
**预演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演；自动模式本身的最低配额必须满足 `mental 3x3 / redteam 3x3 / impl 2x2`。

---

## 文件地图
- 创建 `skills/autonomous-orchestration/SKILL.md` — 无人值守总指挥 skill，定义自动流程、最低轮次、阻塞规则、回修正循环。
- 创建 `commands/sandtable-autopilot.md` — Claude/通用命令入口，加载新 skill。
- 创建 `.cursor/commands/sandtable-autopilot.md` — Cursor 命令副本，与 `commands/` 完全同文。
- 修改 `templates/state.md` — 为自动模式增加机器可读字段。
- 修改 `skills/state-and-memory/SKILL.md` — 目录结构、`state.md` 结构与恢复流程说明补入自动模式字段。
- 修改 `commands/sandtable-status.md`、`.cursor/commands/sandtable-status.md` — 状态命令显式读取自动模式字段。
- 修改 `commands/sandtable-resume.md`、`.cursor/commands/sandtable-resume.md` — 恢复命令显式读取自动模式字段并按其续接。
- 修改 `skills/using-sandtable/SKILL.md` — 阶段表与命令索引增加 autopilot 入口，说明它与 `/start`、`/rehearse` 的边界。
- 修改 `commands/sandtable-start.md`、`.cursor/commands/sandtable-start.md` — 增加“若要全自动可改用 `/sandtable-autopilot`”。
- 修改 `commands/sandtable-rehearse.md`、`.cursor/commands/sandtable-rehearse.md` — 增加“若要从需求到复盘全自动可改用 `/sandtable-autopilot`”；保留其“只串推演阶段”的定位。
- 修改 `README.md` — 命令表、核心特性、目录结构增加 autopilot 说明。
- 修改 `AGENTS.md`、`.cursor/rules/sandtable.mdc` — 技能索引/命令索引加入 `autonomous-orchestration` 与 autopilot。
- 修改 `docs/sandtable/project.md` — 计数与结构描述同步（skills 11→12，commands 12→13）。

---

### 任务 T1: 新增无人值守总指挥 skill

**文件:**
- 创建: `skills/autonomous-orchestration/SKILL.md`

- [ ] 步骤1: 写入 frontmatter 与开场声明，保持与现有 skill 风格一致。
```md
---
name: autonomous-orchestration
description: Use when the developer wants Sandtable to run end-to-end with no manual handoff between phases. Autonomously performs recon, objectives, test cases, planning, multiple rehearsal rounds, and debrief while writing all progress to docs/sandtable.
---

# 全自主自动沙盘编排 · 无人值守总指挥

**开始时声明：** "我在用 autonomous-orchestration 执行无人值守的 Sandtable 全流程。"
```
- [ ] 步骤2: 写“自动作战配额”硬门禁，明确最低轮次与每轮最少子 agent 数。
```md
## 硬门禁

<HARD-GATE>
1. 自动模式必须完整覆盖 `INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN → MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE`。
2. 最低配额不可少：
   - mental: 至少 3 轮，每轮至少 3 个只读子 agent；
   - redteam: 至少 3 轮，每轮至少 3 个红军子 agent；
   - impl: 至少 2 轮，每轮至少 2 个独立 worktree 子 agent。
3. 任一 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED`：主 agent 亲自核实，写回 `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md` 后重演；不能跳过补轮。
4. 只有真正需要开发者提供的产品意图、登录、授权、批准、权限时，才允许写 `questions.md` 并停下。
</HARD-GATE>
```
- [ ] 步骤3: 写自动流程与状态落盘要求，要求每轮产出 `rehearsals/*.md` 并更新 `state.md` 的自动模式字段。
```md
## 自动流程

1. 若目标 feature 不存在：按 `/sandtable-start` 的目录规范创建 `docs/sandtable/features/<date-slug>/`，写入原始需求，`phase=INTAKE`。
2. 一进入 autopilot，就把 `state.md` 写成 `autonomy.mode=autopilot`、`phase=RECON`，并把 `autonomy.last_decision` 记为当前自动动作（如“进入 autopilot，开始 RECON”）。
3. 先完成 RECON / OBJECTIVES / TESTCASES / PLAN，过程中不逐步等开发者确认；每次进入下一阶段时，都同步更新 `state.md.phase`；只有真正阻塞才停。
4. 每次自动推进到下一阶段或因 anomaly/breach/block 回退重演时，都刷新 `autonomy.last_decision`，写明“为什么进入下一步/为什么回退到哪个阶段”；回退时把 `phase` 设成**最早尚未重新验证的阶段**，而不是只写自然语言摘要。
5. 进入多轮推演：
   - mental 第 1-3 轮：每轮至少派 3 个只读子 agent，全部 `LOGIC_CLOSED` 才能记一轮完成。
   - redteam 第 1-3 轮：每轮至少派 3 个红军子 agent，全部 `HELD` 才能记一轮完成。
   - impl 第 1-2 轮：每轮至少派 2 个独立 worktree 子 agent，全部 `DONE` 才能记一轮完成。
6. 全部最低配额完成后，加载 `evaluating-rehearsals` 复盘择优，并把选定实现写入 `state.md:selected_impl`。

每完成一步都要：
- 更新 `state.md.updated`、`phase`、自动模式轮次字段与 `autonomy.last_decision`；
- 在 `journal.md` 追加“为什么自动进入下一步/为什么回退重演”；
- 为每轮写独立的 `rehearsals/mental-<n>.md` / `redteam-<n>.md` / `impl-<n>-<branch>.md`。
```
- [ ] 步骤4: 写“阻塞 vs 异常”的裁决表与回退判定，防止伪自动化。至少包含以下规则：
```md
| 信号 | 主 agent 裁决 | `state.md` 动作 |
|------|---------------|-----------------|
| `ANOMALY_FOUND` | 亲自核实后修正文档/计划并重演 | `blocked=false`；`phase` 设为最早尚未重新验证的阶段 |
| `BREACH_FOUND` | 亲自核实后修正文档/计划并从 mental 重演 | `blocked=false`；`phase=MENTAL_REHEARSAL` |
| `BLOCKED`（内部可修正） | 作为可修正阻塞处理，修正后重演 | `blocked=false`；`phase` 设为最早尚未重新验证的阶段 |
| `BLOCKED`（外部依赖） | 升级为真正阻塞，写 `questions.md` 问开发者 | `blocked=true`；保留当前 `phase` 并写明阻塞原因 |
```
```md
| 念头 | 现实 |
|------|------|
| "照老习惯问用户一句要不要继续下一步" | 自动模式默认自己继续；除非是真阻塞。 |
| "这轮打出 anomaly 了，先算完成，后面再补" | 不行。异常轮不计入最低配额，修正后重跑。 |
```
- [ ] 步骤5: 验证（TC1 / TC2 / TC3 / TC4 / TC5 / TC7）  
运行: `rg -n "autonomous-orchestration|3 轮|3 个|2 轮|2 个|questions.md|journal.md|state.md" skills/autonomous-orchestration/SKILL.md`  
预期: 命中 frontmatter、最低配额、阻塞条件、写回清单。
- [ ] 步骤6: 提交  `git commit -m "feat: add autonomous orchestration skill"`

### 任务 T2: 新增 `/sandtable-autopilot` 双命令入口

**文件:**
- 创建: `commands/sandtable-autopilot.md`
- 创建: `.cursor/commands/sandtable-autopilot.md`

- [ ] 步骤1: 两个文件都写入相同 frontmatter 与入口描述。
```md
---
description: 从需求到复盘全流程无人值守推进
---

读取并遵循 `skills/autonomous-orchestration/SKILL.md`，对当前需求执行 Sandtable 全自动流程。
```
- [ ] 步骤2: 写明确执行步骤，避免把它缩成 `/sandtable-rehearse` 的别名。
```md
执行：
1. 读 `docs/sandtable/project.md`、`constraints.md` 与当前需求；必要时创建/续接 feature 目录与 `state.md`。
2. 自动完成 RECON → OBJECTIVES → TESTCASES → PLAN，并把产物写入对应文件。
3. 按自动模式最低配额执行：
   - 头脑预演至少 3 轮，每轮至少 3 个只读子 agent；
   - 红蓝对抗至少 3 轮，每轮至少 3 个红军子 agent；
   - 实现预演至少 2 轮，每轮至少 2 个独立 worktree 子 agent。
4. 任一异常/攻破/阻塞：亲自核实，写回文档并自动重演；只在真正阻塞时向我提问。
5. 全部轮次达标后自动复盘择优，并报告最终选定方案与剩余风险。
```
- [ ] 步骤3: 用 `diff -u` 保证双副本完全一致。
- [ ] 步骤4: 验证（TC1 / TC2 / TC8）  
运行: `diff -u commands/sandtable-autopilot.md .cursor/commands/sandtable-autopilot.md && rg -n "从需求到复盘全流程无人值守推进|3 轮|2 轮|真正阻塞" commands/sandtable-autopilot.md .cursor/commands/sandtable-autopilot.md`  
预期: `diff` 无输出；两文件都命中精确 description 与关键执行文案。
- [ ] 步骤5: 提交  `git commit -m "feat: add sandtable autopilot command"`

### 任务 T3: 扩展 `state.md` 承载自动模式

**文件:**
- 修改: `templates/state.md`
- 修改: `skills/state-and-memory/SKILL.md`
- 修改: `commands/sandtable-status.md`
- 修改: `.cursor/commands/sandtable-status.md`
- 修改: `commands/sandtable-resume.md`
- 修改: `.cursor/commands/sandtable-resume.md`

- [ ] 步骤1: 在 `templates/state.md` frontmatter 里插入自动模式字段，紧跟 `rehearsals` 后；用 `autonomy.mode` 作为唯一权威开关，不再并列设计 `enabled`。
```md
autonomy:
  mode: manual             # manual|autopilot；是否处于自动模式的唯一权威开关
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none      # 最近一次自动推进 / 回退重演 / 降级阻塞 的决定摘要
```
- [ ] 步骤2: 在 `skills/state-and-memory/SKILL.md` 的目录结构与 `state.md` 示例里同步加入上面这段，并补一条规则：
```md
- 自动模式运行时，`autonomy.*` 是恢复与续跑的权威；不要只看 `rehearsals.runs` 的汇总数字。
- `autonomy.mode=autopilot` 表示当前需求处于无人值守模式；进入 autopilot、每次自动推进、每次回退重演时都必须刷新 `autonomy.last_decision`。
- `phase` 是当前所在阶段的权威字段；自动推进与回退时必须同步更新。`autonomy.last_decision` 只负责解释“为什么进入这里”。
```
- [ ] 步骤3: 更新 `commands/sandtable-status.md` / `.cursor/commands/sandtable-status.md`，在读取 `state.md` 时显式要求汇报 `autonomy.mode`、轮次目标、已完成轮次、最近自动决策。
```md
执行：
1. 读取目标 feature 的 `state.md`、`questions.md`、`journal.md` 最近条目。
2. 除现有 phase / tasks / rehearsals 外，额外汇报 `autonomy.mode`、`autonomy.min_rounds`、`autonomy.completed_rounds`、`autonomy.last_decision`。
```
- [ ] 步骤4: 更新 `commands/sandtable-resume.md` / `.cursor/commands/sandtable-resume.md`，要求在恢复时先读 `autonomy.*`，并**显式改写**现有“等我确认后继续”的旧语义：只有手动模式或阻塞状态才等开发者确认；`mode=autopilot` 且 `blocked=false` 时直接按未完成轮次续跑。
```md
执行：
1. 读 `state.md`，优先恢复 `autonomy.*` 与 `phase`。
2. 若 `autonomy.mode=autopilot` 且 `blocked=false`，按未完成的最低轮次继续自动推进；不要停在“等开发者决定下一步”。
3. 仅当 `autonomy.mode=manual` 或 `blocked=true` 时，才用 3–5 行向我复述并等我确认后继续。
```
- [ ] 步骤5: 验证（TC6 / TC7）  
运行: `rg -n "autonomy.mode|last_decision|min_rounds|completed_rounds|phase|等我确认后继续" templates/state.md skills/state-and-memory/SKILL.md commands/sandtable-status.md .cursor/commands/sandtable-status.md commands/sandtable-resume.md .cursor/commands/sandtable-resume.md`  
预期: 六个文件都命中自动模式字段、`phase` 同步规则或读取规则；`resume` 中旧的“等我确认后继续”只保留在 manual/blocked 分支。
- [ ] 步骤6: 提交  `git commit -m "feat: persist autopilot state"`

### 任务 T4: 把 autopilot 接入现有流程说明

**文件:**
- 修改: `skills/using-sandtable/SKILL.md`
- 修改: `commands/sandtable-start.md`
- 修改: `.cursor/commands/sandtable-start.md`
- 修改: `commands/sandtable-rehearse.md`
- 修改: `.cursor/commands/sandtable-rehearse.md`

- [ ] 步骤1: 在 `skills/using-sandtable/SKILL.md` 的阶段表后补一段，明确 `/sandtable-autopilot` 是“全自动入口”，而 `/sandtable-start` 与 `/sandtable-rehearse` 仍分别负责“前五步”与“只串推演阶段”。
```md
补充说明：若开发者明确要求“无需人工逐步接力、由 AI 自主决定下一步”，加载 `autonomous-orchestration`，使用 `/sandtable-autopilot`。它不替代 `/sandtable-start` 或 `/sandtable-rehearse`，而是把两者串成一个无人值守入口。
```
- [ ] 步骤2: 在 `commands/sandtable-start.md` 与 Cursor 副本里**同时改写** frontmatter `description`、第 7 行“这是编排全流程的命令”与结尾引导，不只是在第 7 步后补一句；把它收束为“前五步入口”，并显式把“从需求到复盘的全自动推进”让给 `/sandtable-autopilot`。
```md
description: 启动 Sandtable 前五步流程：从一句需求开始，澄清→PRD→用例→计划。

执行（这是前五步编排命令；推演与复盘使用单独命令或 `/sandtable-autopilot`）：
...
完成后提示我：可用 `/sandtable-refine` 反复完善；若只继续推演，用 `/sandtable-mental`→`/sandtable-redteam`→`/sandtable-live`→`/sandtable-debrief`；若要求从需求到复盘全自动推进，改用 `/sandtable-autopilot`。
```
- [ ] 步骤3: 在 `commands/sandtable-rehearse.md` 与 Cursor 副本标题/步骤前加一句，强调它仍只管推演与复盘：
```md
若需求是“从原始需求一路全自动推进到复盘”，改用 `/sandtable-autopilot`；本命令只串推演与复盘，不负责前序 RECON / OBJECTIVES / TESTCASES / PLAN。
```
- [ ] 步骤4: 验证（TC1 / TC8）  
运行: `rg -n "autopilot|全自动|无人值守|前五步|只串推演" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md`  
预期: 五个文件都命中 autopilot 分工说明；`start` 被收束为前五步入口，`rehearse` 不再被描述成全流程入口。
- [ ] 步骤5: 提交  `git commit -m "docs: route autonomous users to autopilot"`

### 任务 T5: 同步全局索引与规则文本

**文件:**
- 修改: `README.md`
- 修改: `AGENTS.md`
- 修改: `.cursor/rules/sandtable.mdc`
- 修改: `docs/sandtable/project.md`

- [ ] 步骤1: `README.md` 增加一条命令表记录，并在“核心特性”或“闭环/用法”里说明 autopilot 是无人值守入口。
```md
| `/sandtable-autopilot` | 全自动总指挥 | 从需求到复盘全流程无人值守推进 |
```
- [ ] 步骤2: `README.md` 的目录结构段在 `skills/` 清单里显式补入 `autonomous-orchestration/`，避免命令表更新了但仓库结构索引仍停留在旧 11 个 skill。
```md
    autonomous-orchestration/       # 全自动总指挥：从需求到复盘无人值守推进
```
- [ ] 步骤3: `AGENTS.md` 与 `.cursor/rules/sandtable.mdc` 的 slash 命令列表加入 `/sandtable-autopilot`；技能索引加入 `autonomous-orchestration`。
```md
`/sandtable-autopilot`（全自动总指挥·从需求到复盘无人值守推进）
```
```md
需要时读取对应 `skills/<name>/SKILL.md` 的完整内容：`using-sandtable`、`being-truthful`、`state-and-memory`、`gathering-intel`、`writing-prd`、`writing-tests`、`writing-plan`、`autonomous-orchestration`、`mental-rehearsal`、`red-team-wargame`、`implementation-rehearsal`、`evaluating-rehearsals`。
```
- [ ] 步骤4: `docs/sandtable/project.md` 把 skill 数从 `11` 改为 `12`、slash 命令数从 `12` 改为 `13`，并在结构说明里补一句“含全自动 autopilot 入口”。
- [ ] 步骤5: 验证（TC8）  
运行: `rg -n "sandtable-autopilot|autonomous-orchestration|12 个 skill|13 个 slash 命令" README.md AGENTS.md .cursor/rules/sandtable.mdc docs/sandtable/project.md && rg -n "autonomous-orchestration/" README.md`  
预期: 全部命中；README 的命令表与目录结构都出现 autopilot/新 skill，计数与命令名一致。
- [ ] 步骤6: 提交  `git commit -m "docs: index autopilot across sandtable"`

### 任务 T6: 全仓对账与回归检查

**文件:**
- 验证: `skills/autonomous-orchestration/SKILL.md`
- 验证: `commands/sandtable-autopilot.md`
- 验证: `.cursor/commands/sandtable-autopilot.md`
- 验证: `templates/state.md`
- 验证: `skills/state-and-memory/SKILL.md`
- 验证: `skills/using-sandtable/SKILL.md`
- 验证: `README.md`
- 验证: `AGENTS.md`
- 验证: `.cursor/rules/sandtable.mdc`
- 验证: `docs/sandtable/project.md`

- [ ] 步骤1: 跑命名与覆盖扫描。  
运行: `rg -n "autopilot|autonomous-orchestration|无人值守|3x3|2x2|autonomy:|autonomy.mode|last_decision" skills commands .cursor/commands templates README.md AGENTS.md .cursor/rules docs/sandtable/project.md`  
预期: 新入口、状态字段、配额文案均存在；无 `autopliot` / `autonomous-orch` 之类拼写漂移。
- [ ] 步骤2: 校验命令双副本一致。  
运行: `diff -u commands/sandtable-autopilot.md .cursor/commands/sandtable-autopilot.md && diff -u commands/sandtable-start.md .cursor/commands/sandtable-start.md && diff -u commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && diff -u commands/sandtable-status.md .cursor/commands/sandtable-status.md && diff -u commands/sandtable-resume.md .cursor/commands/sandtable-resume.md`  
预期: 所有 `diff` 均无输出。
- [ ] 步骤3: 对照 tests.md 逐条验收。  
运行: `printf "TC1 TC2 TC3 TC4 TC5 TC6 TC7 TC8\n"`  
预期: 人工按 `tests.md` 对照上述命中结果，无未覆盖 TC。
- [ ] 步骤4: 提交  `git commit -m "test: verify autopilot documentation flow"`

---

## 自查
- PRD 覆盖：FR1-FR8 分别落在 T1-T6，无遗漏。
- tests.md 覆盖：TC1/TC2 由 T1/T2/T4 验证；TC3/TC4/TC5 由 T1/T3 验证；TC6/TC7 由 T1/T3 验证（含 `phase` 同步与 `BLOCKED` 分流）；TC8 由 T2/T4/T5/T6 验证。
- 占位符扫描：无 TBD / 稍后实现 / “妥善处理”。
- 类型一致：统一使用 `autonomous-orchestration`（skill）、`/sandtable-autopilot`（命令）、`autonomy.mode` / `autonomy.last_decision`（state 权威字段）。
- 顺序：先建 skill/command，再扩状态，再接入索引，最后做全仓验证。
- MUST NOT：未引入新依赖、未删除手动入口、未把编排搬到仓外脚本。
