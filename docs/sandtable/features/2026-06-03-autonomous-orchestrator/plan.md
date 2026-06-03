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
- 修改 `commands/sandtable-start.md`、`.cursor/commands/sandtable-start.md` — 改写并收束为“前五步入口”，把“从需求到复盘的全自动推进”明确让给 `/sandtable-autopilot`。
- 修改 `commands/sandtable-rehearse.md`、`.cursor/commands/sandtable-rehearse.md` — 改写并收束为“只串推演与复盘”，不再让它看起来像总入口；保留其“只串推演阶段”的定位。
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
3. 任一 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED`：主 agent 亲自核实；若属内部可修正问题，则写回 `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md` 后重演；若属外部依赖，才写 `questions.md` 并停下。不能跳过补轮。
4. 只有真正需要开发者提供的产品意图、登录、授权、批准、权限时，才允许写 `questions.md` 并停下；不能把内部可修正 `BLOCKED` 当成默认人工确认节点。
</HARD-GATE>
```
- [ ] 步骤3: 写自动流程与状态落盘要求，要求每轮产出 `rehearsals/*.md` 并更新 `state.md` 的自动模式字段。
```md
## 自动流程

1. 若目标 feature 不存在：按 `/sandtable-start` 的目录规范创建 `docs/sandtable/features/<date-slug>/`，写入原始需求，`phase=INTAKE`。
2. 一进入 autopilot，先区分是“全新需求”还是“续接已有 feature”：
   - 全新需求：把 `state.md` 写成 `autonomy.mode=autopilot`、`phase=RECON`，并把 `autonomy.last_decision` 记为“进入 autopilot，开始 RECON”。
   - 已有 feature：保留当前 `state.md.phase`，只把 `autonomy.mode=autopilot` 与 `autonomy.last_decision` 切到自动模式；若当前阶段早于 `PLAN`，则从最早尚未完成的前序阶段补跑；若当前已在 `MENTAL_REHEARSAL` 及之后，则必须先执行下面第 8 条的配额闭包纠偏，再从纠偏后的最早未完成推演阶段续跑，不能无条件打回 `RECON`，也不能仅因当前 `phase` 超前就跳过缺失轮次。
3. `INTAKE` 由 `state-and-memory` 负责建档/恢复；`RECON → PLAN` 四个前序阶段必须显式沿用既有 skill 链，而不是留给执行者即兴发挥：`gathering-intel` → `writing-prd` → `writing-tests` → `writing-plan`。在 autopilot 模式下，开发者显式触发 `/sandtable-autopilot` 视为对“从 INTAKE 建档到 PLAN 完成”的前序连续推进预授权；手动命令以及 `gathering-intel` / `writing-prd` / `writing-tests` / `writing-plan` 这些相关 skill 中“请我确认后继续”“PRD/用例已确认”之类的旧语义只在真正阻塞时恢复生效。`<AUTOPILOT-OVERRIDE>` 只在本回合明确执行 `/sandtable-autopilot`，或由 `/sandtable-resume` 在 `autonomy.mode=autopilot && blocked=false` 的自动续跑分支里生效；若开发者显式改打 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 等手动命令，则这些命令仍按手动语义执行，不能被 `autonomy.mode=autopilot` 静默覆盖。这里的“前序流程”固定指 `INTAKE + RECON + OBJECTIVES + TESTCASES + PLAN`，不再用“前五步/这四步”混称。
4. 先完成 RECON / OBJECTIVES / TESTCASES / PLAN，过程中不逐步等开发者确认；每次进入下一阶段时，都同步更新 `state.md.phase`；只有真正阻塞才停。
5. 每次自动推进到下一阶段或因 anomaly/breach/block 回退重演时，都刷新 `autonomy.last_decision`，写明“为什么进入下一步/为什么回退到哪个阶段”；回退规则必须显式区分两段：
   - 前序流程内部（`INTAKE / RECON / OBJECTIVES / TESTCASES / PLAN`）发现异常或内部可修正阻塞：按“被修正的最早产物映射”判定回退目标，而不是抽象写“最早尚未重新验证”就结束。映射规则固定为：`project.md` / `constraints.md` / 侦察结论变化 → `RECON`；`prd.md` 变化 → `OBJECTIVES`；`tests.md` 变化 → `TESTCASES`；仅 `plan.md` 变化 → `PLAN`；若只改了 `state.md` / `journal.md` / `questions.md` 这类记账文件而未改前序产物，则保留当前前序 `phase` 不变。随后从映射到的阶段继续补跑直到 `PLAN`。
   - 已进入推演链（`MENTAL_REHEARSAL / REDTEAM / IMPL_REHEARSAL`）后，只要发生任何需要写回文档再重演的 `ANOMALY_FOUND` / `BREACH_FOUND` / 内部可修正 `BLOCKED`：统一把 `phase` 设回 `MENTAL_REHEARSAL`，重新走 mental → redteam → impl。
6. `autonomy.completed_rounds` 只承载三类推演的当前有效进度；前序流程回退时它保持 `0/0/0`。一旦已进入推演链且需要回退到 `MENTAL_REHEARSAL`，必须把 `mental/redteam/impl` 的 `completed_rounds` 全部清零。只有当该轮达到最低子 agent 数、该轮所有子 agent 都返回成功信号、且该轮报告已写入 `rehearsals/` 时，才允许把对应 `completed_rounds` 加一。`rehearsals.*.runs` 与 `rehearsals.*.last` 只保留历史尝试次数和最近结果，不参与 resume 的“是否已达最低配额”判定。
7. 进入多轮推演：
   - mental 第 1-3 轮：每轮至少派 3 个只读子 agent，全部 `LOGIC_CLOSED` 才能记一轮完成。
   - redteam 第 1-3 轮：每轮至少派 3 个红军子 agent，全部 `HELD` 才能记一轮完成。
   - impl 第 1-2 轮：每轮至少派 2 个独立 worktree 子 agent，全部 `DONE` 才能记一轮完成。
8. 每次进入推演链与每次 `/sandtable-resume` 自动续跑前，都先按 `autonomy.completed_rounds` 与 `autonomy.min_rounds` 计算“最早尚未达标的推演阶段”：只要 mental 未满 3，就必须回到 `MENTAL_REHEARSAL`；mental 满但 redteam 未满 3，就必须停在 `REDTEAM`；mental/redteam 满但 impl 未满 2，才能进入 `IMPL_REHEARSAL`。`phase` 只是当前记录位置，不能压过这个配额闭包判定；若两者冲突，先纠偏 `phase` 并写 `autonomy.last_decision`。
9. 全部最低配额完成后，加载 `evaluating-rehearsals` 复盘择优，并把选定实现写入 `state.md:selected_impl`。

每完成一步都要：
- 更新 `state.md.updated`、`phase`、自动模式轮次字段与 `autonomy.last_decision`；
- 在 `journal.md` 追加“为什么自动进入下一步/为什么回退重演”；
- 为每轮写独立的 `rehearsals/mental-<n>.md` / `redteam-<n>.md` / `impl-<n>-<branch>.md`。
```
- [ ] 步骤4: 写“阻塞 vs 异常”的裁决表与回退判定，防止伪自动化。至少包含以下规则：
```md
| 信号 | 主 agent 裁决 | `state.md` 动作 |
|------|---------------|-----------------|
| `ANOMALY_FOUND`（前序流程内部） | 亲自核实后修正文档/计划，并按被修正的最早产物映射补跑前序流程 | `blocked=false`；`project.md` / `constraints.md` / 侦察结论变化 → `phase=RECON`；`prd.md` 变化 → `phase=OBJECTIVES`；`tests.md` 变化 → `phase=TESTCASES`；仅 `plan.md` 变化 → `phase=PLAN`；`autonomy.completed_rounds` 保持 `0/0/0` |
| `ANOMALY_FOUND`（已进入推演链） | 亲自核实后写回文档并从 mental 重演 | `blocked=false`；`phase=MENTAL_REHEARSAL`，并清零 `mental/redteam/impl` 的 `autonomy.completed_rounds` |
| `BREACH_FOUND` | 亲自核实后修正文档/计划并从 mental 重演 | `blocked=false`；`phase=MENTAL_REHEARSAL`，并清零 `mental/redteam/impl` 的 `autonomy.completed_rounds` |
| `BLOCKED`（内部可修正，前序流程内部） | 作为可修正阻塞处理，修正后按被修正的最早产物映射补跑前序流程 | `blocked=false`；`project.md` / `constraints.md` / 侦察结论变化 → `phase=RECON`；`prd.md` 变化 → `phase=OBJECTIVES`；`tests.md` 变化 → `phase=TESTCASES`；仅 `plan.md` 变化 → `phase=PLAN`；`autonomy.completed_rounds` 保持 `0/0/0` |
| `BLOCKED`（内部可修正，已进入推演链） | 作为可修正阻塞处理，写回文档后从 mental 重演 | `blocked=false`；`phase=MENTAL_REHEARSAL`，并清零 `mental/redteam/impl` 的 `autonomy.completed_rounds` |
| `BLOCKED`（外部依赖） | 升级为真正阻塞，写 `questions.md` 问开发者 | `blocked=true`；保留当前 `phase` 并写明阻塞原因，不改动已有有效轮次 |
```
```md
| 念头 | 现实 |
|------|------|
| "照老习惯问用户一句要不要继续下一步" | 自动模式默认自己继续；除非是真阻塞。 |
| "这轮打出 anomaly 了，先算完成，后面再补" | 不行。异常轮不计入最低配额，修正后重跑。 |
```
- [ ] 步骤5: 验证（TC1 / TC3 / TC4 / TC5）  
运行: `rg -n "autonomous-orchestration|state-and-memory|gathering-intel|writing-prd|writing-tests|writing-plan|autopilot|3 轮|3 个|2 轮|2 个|攻击向量|questions.md|journal.md|state.md|completed_rounds|last_decision|RECON|OBJECTIVES|TESTCASES|PLAN|MENTAL_REHEARSAL" skills/autonomous-orchestration/SKILL.md`  
预期: 命中 frontmatter、INTAKE/前序 skill 链、最低配额、redteam 攻击向量、续接规则、前序流程回退映射、推演链回退与 `completed_rounds` 回卷规则。
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
2. 若是全新需求，从 INTAKE/RECON 起自动完成 `gathering-intel` → `writing-prd` → `writing-tests` → `writing-plan`；若是已有 feature，则读取当前 `state.md.phase` 与 `autonomy.*`，从当前阶段或最早尚未完成阶段续接，不把进行中的需求无条件打回 `RECON`。
3. 按自动模式最低配额执行：
   - 头脑预演至少 3 轮，每轮至少 3 个只读子 agent；
   - 红蓝对抗至少 3 轮，每轮至少 3 个红军子 agent；
   - 实现预演至少 2 轮，每轮至少 2 个独立 worktree 子 agent。
4. `/sandtable-autopilot` 的显式触发即表示开发者授权自动穿过前序流程的常规“请我确认”检查点；任一异常/攻破/阻塞：亲自核实，写回文档并自动重演；只在真正阻塞时向我提问。
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
- `phase` 是当前记录位置字段；自动推进与回退时必须同步更新。`autonomy.last_decision` 只负责解释“为什么进入这里”。在 autopilot 的推演链续跑中，真正决定下一步的是配额闭包，不是超前的 `phase`。
- `autonomy.completed_rounds` 只承载三类推演的当前有效进度：前序流程回退时保持 `0/0/0`；一旦已进入推演链且需要回退到 `MENTAL_REHEARSAL`，`mental/redteam/impl` 必须全部清零。只有满足“该轮最低子 agent 数 + 全部成功信号 + 本轮报告已写入”时，才允许对应字段加一。
- `rehearsals.*.runs` 与 `rehearsals.*.last` 只表示历史尝试次数和最近结果；resume/status 在 autopilot 下不得把它们当作“已满足最低配额”的依据。
- `phase` 若与 `autonomy.completed_rounds` 所对应的最早未完成推演阶段冲突，必须先按配额闭包纠偏；不能只因 `phase=IMPL_REHEARSAL` 就跳过缺失的 mental/redteam 轮次。
- 旧的“状态回退改回 OBJECTIVES/TESTCASES/PLAN”规则必须补充 autopilot 分支，并同步删改现有 `using-sandtable` 的 `FIX -> OBJ` 与 `state-and-memory` 旧回退简写：`autonomy.mode=autopilot` 时，以自主总指挥 skill 的回退裁决表、配额闭包与 `phase` 为准。
- 这一组规则由 `TC6 / T3` 专门终验；不要把 `state-and-memory` 的语义回退规则混进 `TC8` 的索引对账链。
```
- [ ] 步骤3: 更新 `commands/sandtable-status.md` / `.cursor/commands/sandtable-status.md`，在读取 `state.md` 时显式要求汇报 `autonomy.mode`、轮次目标、已完成轮次、最近自动决策。
```md
执行：
1. 读取目标 feature 的 `state.md`、`questions.md`、`journal.md` 最近条目。
2. 除现有 phase / tasks / rehearsals 外，额外汇报 `autonomy.mode`、`autonomy.min_rounds`、`autonomy.min_agents_per_round`、`autonomy.completed_rounds`、`autonomy.last_decision`。
```
- [ ] 步骤4: 更新 `commands/sandtable-resume.md` / `.cursor/commands/sandtable-resume.md`，要求在恢复时先读 `autonomy.*`，并**显式改写**现有“等我确认后继续”的旧语义：只有手动模式或阻塞状态才等开发者确认；`mode=autopilot` 且 `blocked=false` 时直接按未完成轮次续跑。
```md
执行：
1. 读 `state.md`，优先恢复 `autonomy.*` 与 `phase`；若本次是重新执行 `/sandtable-autopilot` 续接已有 feature，也沿用同一条恢复规则。
2. 若 `autonomy.mode=autopilot` 且 `blocked=false`，先按 `autonomy.completed_rounds` 与 `autonomy.min_rounds` 判定最早未完成阶段，再结合 `phase` 继续自动推进；不要停在“等开发者决定下一步”，也不要把 `rehearsals.*.runs` / `rehearsals.*.last` 误当成有效完成轮次。若 `phase` 超前于配额闭包，必须先纠偏到最早未完成阶段并写 `autonomy.last_decision`。
3. 仅当 `autonomy.mode=manual` 或 `blocked=true` 时，才用 3–5 行向我复述并等我确认后继续。
```
- [ ] 步骤5: 验证（TC6 / TC7）  
运行: `rg -n "autonomy.mode|last_decision|min_rounds|min_agents_per_round|completed_rounds|rehearsals\\..*runs|rehearsals\\..*last|phase|等我确认后继续|blocked=true|最早未完成阶段|重新执行 /sandtable-autopilot" templates/state.md skills/state-and-memory/SKILL.md commands/sandtable-status.md .cursor/commands/sandtable-status.md commands/sandtable-resume.md .cursor/commands/sandtable-resume.md`  
预期: 六个文件都命中自动模式字段、`phase` 记录位规则、`completed_rounds` 回卷规则、`rehearsals.runs/last` 非权威语义，及“重新执行 `/sandtable-autopilot` 续接已有 feature 也要先做配额闭包纠偏”；`resume` 中旧的“等我确认后继续”只保留在 manual/blocked 分支。
- [ ] 步骤5.5: 在 `skills/autonomous-orchestration/SKILL.md` 写显式 `<AUTOPILOT-OVERRIDE>` 段，逐条覆盖 `gathering-intel` / `writing-prd` / `writing-tests` / `writing-plan` 中“请我确认后继续”“PRD/用例已确认”类门槛，以及 `/sandtable-start`、`/sandtable-recon`、`/sandtable-objectives`、`/sandtable-plan`、`/sandtable-resume` 这些手动命令里的确认节点；并明确“无 `project.md` / `constraints.md` 时，在 autopilot 下允许按模板自主初始化，除非触发 FR5 的真正阻塞”。同时写明两条边界：① 该 override 只在本回合显式执行 `/sandtable-autopilot` 或由 `/sandtable-resume` 自动续跑时生效；② `mental-rehearsal` / `red-team-wargame` / `implementation-rehearsal` 这些推演 skill 只提供“单轮怎么打”的过程模板，其内部状态图、可选/单轮描述、以及手动 `/sandtable-rehearse` / `/sandtable-mental` / `/sandtable-redteam` / `/sandtable-live` 的语义都不能取代 `autonomous-orchestration` 对 `completed_rounds`、最早未完成阶段与 phase 推进的唯一裁决权；同时把 TC2/TC6 的验证词扩展到这些旧语义。
- [ ] 步骤5.6: 追加验证（TC2）  
运行: `rg -n "AUTOPILOT-OVERRIDE|sandtable-start|sandtable-recon|sandtable-objectives|sandtable-plan|sandtable-resume|project.md|constraints.md|请我确认后继续|PRD/用例已确认|真正阻塞" skills/autonomous-orchestration/SKILL.md`  
预期: 命中显式 override 段、5 个手动命令、全局初始化例外、旧确认门槛与真正阻塞分流。
- [ ] 步骤6: 提交  `git commit -m "feat: persist autopilot state"`

### 任务 T4: 把 autopilot 接入现有流程说明

**文件:**
- 修改: `skills/using-sandtable/SKILL.md`
- 修改: `commands/sandtable-start.md`
- 修改: `.cursor/commands/sandtable-start.md`
- 修改: `commands/sandtable-rehearse.md`
- 修改: `.cursor/commands/sandtable-rehearse.md`

- [ ] 步骤1: 在 `skills/using-sandtable/SKILL.md` 的阶段表后补一段，明确 `/sandtable-autopilot` 是“全自动入口”，而 `/sandtable-start` 与 `/sandtable-rehearse` 仍分别负责“前五步”与“只串推演与复盘”；同时显式改写阶段表后的现有总览句，把旧的“`/sandtable-rehearse` 串起三类推演 + 复盘”替换成“`/sandtable-rehearse` 只串推演与复盘，不是总入口”；并补一条 autopilot 例外说明：`autonomy.mode=autopilot` 时，以自主总指挥 skill 写回的 `phase`、配额闭包与回退裁决表为准，不沿用 `FIX -> OBJ` 的通用简写。
```md
补充说明：若开发者明确要求“无需人工逐步接力、由 AI 自主决定下一步”，加载 `autonomous-orchestration`，使用 `/sandtable-autopilot`。它不是把 `/sandtable-start` 或 `/sandtable-rehearse` 静默升级，而是新增的全自动入口；其中 `/sandtable-start` 只负责前序流程，`/sandtable-rehearse` 只负责推演与复盘。`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的手动运行结果不会自动计入 `autonomy.completed_rounds`；即使 autopilot 之后接手，也必须按 FR3 重新派满该轮最低子 agent 数、拿到完整成功信号并重写本轮 `rehearsals/` 报告后，才允许把该轮记入自动模式进度。
```
- [ ] 步骤2: 在 `commands/sandtable-start.md` 与 Cursor 副本里**同时改写** frontmatter `description`、第 7 行“这是编排全流程的命令”与结尾引导，不只是在第 7 步后补一句；把它收束为“前五步入口”，并显式把“从需求到复盘的全自动推进”让给 `/sandtable-autopilot`。
```md
description: 启动 Sandtable 前五步流程：从一句需求开始，受领→侦察→目标→用例→计划。

执行（这是前五步编排命令；推演与复盘使用单独命令或 `/sandtable-autopilot`）：
...
完成后提示我：可用 `/sandtable-refine` 反复完善；若只继续推演，用 `/sandtable-mental`→`/sandtable-redteam`→`/sandtable-live`→`/sandtable-debrief`；若要求从需求到复盘全自动推进，改用 `/sandtable-autopilot`。
```
- [ ] 步骤3: 在 `commands/sandtable-rehearse.md` 与 Cursor 副本里同时改写 frontmatter `description` 与标题/步骤前导，强调它仍只管推演与复盘：
```md
description: 串起推演与复盘：头脑预演→红蓝对抗→实现预演→复盘择优，不负责前序 RECON→PLAN。

若需求是“从原始需求一路全自动推进到复盘”，改用 `/sandtable-autopilot`；本命令只串推演与复盘，不负责前序 RECON / OBJECTIVES / TESTCASES / PLAN。
```
- [ ] 步骤4: 验证（TC1 / TC8 局部预检）  
运行: `rg -n "^description: 启动 Sandtable 前五步流程|^description: 串起推演与复盘|autopilot|全自动|无人值守|前五步|前序编排|只串推演|autonomy.mode=autopilot|completed_rounds" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "前五步编排命令|只串推演与复盘|不会自动计入 `autonomy.completed_rounds`|重新派满该轮最低子 agent 数" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && ! rg -n "编排全流程|一键串起全部推演|一键编排|可一键串起|一键串起 图上|仅串起 图上|仅串起|只串起|澄清→PRD→用例→计划→预演|串起三类推演与复盘|串起三类推演\\+复盘|串起三类推演 \\+ 复盘|FIX -> OBJ" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md`  
预期: 前两条命中新文案、命令正文收束与“手动运行不自动计入 `completed_rounds`，后续也必须重新派满最低子 agent 数后才能计入”边界；第三条 0 命中，证明 `using-sandtable` 与这 4 个命令文件无误导性旧文案残留，且不会漏掉 `一键编排`、`可一键串起`、`仅串起`、`只串起` 与 `FIX -> OBJ` 等变体。本步骤只做命令与总入口 skill 的局部预检，完整的 TC8 终验以 T5/T6 为准。
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
- [ ] 步骤1.5: 不只追加 autopilot；同步改写 README 里已有的 `/sandtable-start` 与 `/sandtable-rehearse` 描述，分别收束为“前五步/前序编排”与“只串推演与复盘”，避免和 autopilot 冲突。
- [ ] 步骤1.6: 为 README 命令表给出精确替换文案，避免执行者只加一行 autopilot 却漏改旧行：
```md
| `/sandtable-start` | 受领任务 | 前序编排：受领→侦察→目标→用例→计划（从一句话或产品文档开始）|
| `/sandtable-rehearse` | 推演编排 | 只串推演与复盘：图上→红蓝→实兵→复盘（不含 RECON→PLAN） |
```
- [ ] 步骤2: `README.md` 的目录结构段在 `skills/` 清单里显式补入 `autonomous-orchestration/`，避免命令表更新了但仓库结构索引仍停留在旧 11 个 skill。
```md
    autonomous-orchestration/       # 全自动总指挥：从需求到复盘无人值守推进
```
- [ ] 步骤3: `AGENTS.md` 与 `.cursor/rules/sandtable.mdc` 的 slash 命令列表加入 `/sandtable-autopilot`；技能索引加入 `autonomous-orchestration`；同时把原有 `/sandtable-start`、`/sandtable-rehearse` 的全局索引描述同步收束，避免继续写成“编排全流程”“总入口”“总演习”或“串起三类推演与复盘”，并给出与 README 同口径的替换稿。
```md
`/sandtable-start`（受领任务·前序编排：受领→侦察→目标→用例→计划）
`/sandtable-rehearse`（推演编排·只串推演与复盘）
`/sandtable-autopilot`（全自动总指挥·从需求到复盘无人值守推进）
```
```md
需要时读取对应 `skills/<name>/SKILL.md` 的完整内容：`using-sandtable`、`being-truthful`、`state-and-memory`、`gathering-intel`、`writing-prd`、`writing-tests`、`writing-plan`、`autonomous-orchestration`、`mental-rehearsal`、`red-team-wargame`、`implementation-rehearsal`、`evaluating-rehearsals`。
```
- [ ] 步骤4: `docs/sandtable/project.md` 把 skill 数从 `11` 改为 `12`、slash 命令数从 `12` 改为 `13`，并在结构说明里补一句“含全自动 autopilot 入口”。
- [ ] 步骤5: 验证（TC8）  
运行: `rg -n "sandtable-autopilot|autonomous-orchestration|前五步|前序编排|只串推演|12 个 skill|13 个 slash 命令|sandtable-start|sandtable-rehearse|sandtable-mental|sandtable-redteam|sandtable-live" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md skills/autonomous-orchestration/SKILL.md commands .cursor/commands docs/sandtable/project.md && rg -n "autonomous-orchestration/" README.md && rg -n "/sandtable-start.*前五步|/sandtable-start.*前序编排" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "/sandtable-rehearse.*只串推演与复盘" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "/sandtable-autopilot|sandtable-mental|sandtable-redteam|sandtable-live" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "^description: 启动 Sandtable 前五步流程|^description: 串起推演与复盘" commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "前五步编排命令|只串推演与复盘|不会自动计入 `autonomy.completed_rounds`|重新派满该轮最低子 agent 数" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "`/sandtable-start`（受领任务·前序编排：受领→侦察→目标→用例→计划）|`/sandtable-rehearse`（推演编排·只串推演与复盘）|`/sandtable-autopilot`（全自动总指挥·从需求到复盘无人值守推进）" AGENTS.md .cursor/rules/sandtable.mdc && ! rg -n "编排全流程|一键串起全部推演|一键编排|可一键串起|一键串起 图上|仅串起 图上|仅串起|只串起|总演习|总入口|澄清→PRD→用例→计划→预演|串起三类推演与复盘|串起三类推演\\+复盘|串起三类推演 \\+ 复盘" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md skills/autonomous-orchestration/SKILL.md commands/sandtable-autopilot.md .cursor/commands/sandtable-autopilot.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && test -f skills/autonomous-orchestration/SKILL.md && test -f commands/sandtable-autopilot.md && test -f .cursor/commands/sandtable-autopilot.md && test -f commands/sandtable-start.md && test -f commands/sandtable-rehearse.md && test -f commands/sandtable-mental.md && test -f commands/sandtable-redteam.md && test -f commands/sandtable-live.md && test -f .cursor/commands/sandtable-start.md && test -f .cursor/commands/sandtable-rehearse.md && test -f .cursor/commands/sandtable-mental.md && test -f .cursor/commands/sandtable-redteam.md && test -f .cursor/commands/sandtable-live.md`  
预期: 前八条检查分别命中新入口、目录结构、`/sandtable-start` 的前五步/前序编排边界、`/sandtable-rehearse` 的只串推演与复盘边界、保留的手动命令、frontmatter、命令正文与“手动运行不自动计入 `completed_rounds`，后续也必须重新派满最低子 agent 数”边界，以及 `AGENTS` / Cursor rule 主 slash 列表的精确替换稿；负向检查 0 命中，证明全局索引、autopilot skill/命令与 start/rehearse 命令文件中无旧冲突表述残留；最后的 `test -f` 证明新 skill、新 autopilot 命令与保留的手动命令文件及其 Cursor 副本仍存在。随后必须人工审读 `README.md` 的命令表与用法段、`AGENTS.md` / `.cursor/rules/sandtable.mdc` 的主 slash 列表及其附近说明、`skills/using-sandtable/SKILL.md` 的阶段总览句与补充说明、`skills/autonomous-orchestration/SKILL.md` 的边界说明、`commands/sandtable-autopilot.md` 与其 Cursor 副本正文，拒绝 `核心入口`、`主入口`、`推演总控`、`综合演习`、`串联三类推演`、`一次串完`、`统筹全流程` 等同义复述旧心智。`state-and-memory` 的 autopilot 回退语义改由 T3 / TC6 终验，不再混入 T5 的索引对账链。
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

- [ ] 步骤1: 先复跑 TC8/T5 的完整索引终验，再补跑全仓 smoke。  
运行: `rg -n "sandtable-autopilot|autonomous-orchestration|前五步|前序编排|只串推演|12 个 skill|13 个 slash 命令|sandtable-start|sandtable-rehearse|sandtable-mental|sandtable-redteam|sandtable-live" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md skills/autonomous-orchestration/SKILL.md commands .cursor/commands docs/sandtable/project.md && rg -n "autonomous-orchestration/" README.md && rg -n "/sandtable-start.*前五步|/sandtable-start.*前序编排" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "/sandtable-rehearse.*只串推演与复盘" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "/sandtable-autopilot|sandtable-mental|sandtable-redteam|sandtable-live" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "^description: 启动 Sandtable 前五步流程|^description: 串起推演与复盘" commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "前五步编排命令|只串推演与复盘|不会自动计入 `autonomy.completed_rounds`|重新派满该轮最低子 agent 数" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "`/sandtable-start`（受领任务·前序编排：受领→侦察→目标→用例→计划）|`/sandtable-rehearse`（推演编排·只串推演与复盘）|`/sandtable-autopilot`（全自动总指挥·从需求到复盘无人值守推进）" AGENTS.md .cursor/rules/sandtable.mdc && ! rg -n "编排全流程|一键串起全部推演|一键编排|可一键串起|一键串起 图上|仅串起 图上|仅串起|只串起|总演习|总入口|澄清→PRD→用例→计划→预演|串起三类推演与复盘|串起三类推演\\+复盘|串起三类推演 \\+ 复盘" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md skills/autonomous-orchestration/SKILL.md commands/sandtable-autopilot.md .cursor/commands/sandtable-autopilot.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && test -f skills/autonomous-orchestration/SKILL.md && test -f commands/sandtable-autopilot.md && test -f .cursor/commands/sandtable-autopilot.md && test -f commands/sandtable-start.md && test -f commands/sandtable-rehearse.md && test -f commands/sandtable-mental.md && test -f commands/sandtable-redteam.md && test -f commands/sandtable-live.md && test -f .cursor/commands/sandtable-start.md && test -f .cursor/commands/sandtable-rehearse.md && test -f .cursor/commands/sandtable-mental.md && test -f .cursor/commands/sandtable-redteam.md && test -f .cursor/commands/sandtable-live.md && rg -n "autopilot|sandtable-autopilot|autonomous-orchestration|无人值守|前五步|前序编排|只串推演|3x3|2x2|攻击向量|autonomy:|autonomy.mode|last_decision|completed_rounds|12 个 skill|13 个 slash 命令|sandtable-start|sandtable-rehearse|sandtable-mental|sandtable-redteam|sandtable-live" skills commands .cursor/commands templates README.md AGENTS.md .cursor/rules docs/sandtable/project.md`  
预期: 前十条检查与 TC8/T5 完全同口径，分别命中新入口、目录结构、`/sandtable-start` 的前五步/前序编排边界、`/sandtable-rehearse` 的只串推演与复盘边界、保留的手动命令、frontmatter、命令正文与“手动运行不自动计入 `completed_rounds`，后续也必须重新派满最低子 agent 数”边界、以及 `AGENTS` / Cursor rule 主 slash 列表的精确替换稿，并在负向检查中取得 0 命中；随后补跑全仓 smoke，确认命名、状态字段、配额词与保留命令在仓内全覆盖；无 `autopliot` / `autonomous-orch` 之类拼写漂移。最后必须按 `tests.md` TC8 做人工语义审读，审读范围包含 autopilot skill 与 autopilot 命令正文，拒绝任何“同义改写 + 脚注式合规 + 非主段落复述旧心智”的通过路径。`state-and-memory` 的 autopilot 回退语义改由 T3 / TC6 终验，不再混入 T6 的索引对账链。
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
- tests.md 覆盖：TC1 由 T1/T2/T4/T5 验证；TC2 由 T3.5/T3.6 验证（含 autopilot override、生效边界与全局初始化例外）；TC3/TC4/TC5 由 T1/T3 验证（含 `completed_rounds` 计数条件、最早未完成阶段补轮与 redteam 攻击向量）；TC6/TC7 由 T3 验证（含 `phase` 记录位语义、`BLOCKED` 分流、`rehearsals.runs/last/*.md` 非权威语义、`state-and-memory` autopilot 回退分支与配额闭包纠偏）；TC8 由 T2/T5/T6 终验，T4 只做命令与总入口 skill 的局部预检。
- 占位符扫描：无 TBD / 稍后实现 / “妥善处理”。
- 类型一致：统一使用 `autonomous-orchestration`（skill）、`/sandtable-autopilot`（命令）、`autonomy.mode` / `autonomy.last_decision`（state 权威字段）。
- 顺序：先建 skill/command，再扩状态，再接入索引，最后做全仓验证。
- MUST NOT：未引入新依赖、未删除手动入口、未把编排搬到仓外脚本。
