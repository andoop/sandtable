# 全自主自动沙盘编排 autopilot · PRD

> 我在用 writing-prd 把需求固化为 PRD。
> 对应 project.md 北极星（让 AI 把简单需求做成逻辑闭环、细节完美的功能）/ 继承 constraints.md 红线。实现细节见 plan.md，具体场景见 tests.md。

## 1. 目标
新增一个**无需人工逐步接力、由 AI 自主决定下一步**的 Sandtable 自动化流程：从侦察、目标、用例、计划，一路推进到多轮头脑预演、红蓝对抗、实现预演与复盘择优；只有遇到真正必须人工提供的外部信息或权限时才停下。

## 2. 背景与现状（已确认事实，标来源）
- 当前 `/sandtable-start` 只把流程编排到 `PLAN`，然后提示开发者自己继续触发后续推演，并不是无人值守全流程（`commands/sandtable-start.md:7-14`）。
- 当前 `/sandtable-rehearse` 只串**一轮**头脑预演、红蓝对抗、实现预演与复盘，没有最低轮次、每轮最低子 agent 数，也没有“自动回到前序阶段重演直到达标”的硬约束（`commands/sandtable-rehearse.md:7-19`）。
- 单步命令 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 都是“跑完这一步后提示我下一步”，默认设计仍依赖人工接力（`commands/sandtable-mental.md:7-11`、`commands/sandtable-redteam.md:7-13`、`commands/sandtable-live.md:7-11`）。
- 三类推演 skill 都支持并行多个子 agent，但只写了“可并行”，没有定义“至少 3 轮 mental / 3 轮 redteam / 2 轮 impl，以及每轮至少 3/3/2 个子 agent”的最低作战配额（`skills/mental-rehearsal/SKILL.md:20-21,43-49`、`skills/red-team-wargame/SKILL.md:20-32,54-59`、`skills/implementation-rehearsal/SKILL.md:12-17,23-24,52-62`）。
- 当前 `state.md` 机器可读结构只有 `phase`、`tasks`、`rehearsals.{mental,redteam,impl}` 的汇总计数，不足以表达“自动模式是否启用、最低轮次、每轮最少子 agent 数、当前已完成到哪一轮、自动决策摘要”等编排信息（`skills/state-and-memory/SKILL.md:32-66`、`templates/state.md:1-18`）。
- README 与总入口 skill 里已经把命令体系定义为“一个命令 = 一个战术动作”，其中 `/sandtable-start` 与 `/sandtable-rehearse` 分别承担“前五步编排”和“总演习”，但没有“从需求到复盘一键全自动推进”的入口（`skills/using-sandtable/SKILL.md:56-72`、`README.md:52-69`）。
- 插件清单按目录装载 `skills/` 与 `commands/`，因此新增 skill/command 文件无需修改 manifest 注册位，只需保证索引文档与命令列表自洽（`.claude-plugin/plugin.json:21-23`、`.cursor-plugin/plugin.json:15-17`）。

## 3. 方案探索
- **方案 A：扩展现有 `/sandtable-rehearse` 增加自动模式参数。**
  - 优点：入口少，复用现有“总演习”心智。
  - 缺点：它只覆盖推演与复盘，不覆盖 `RECON → OBJECTIVES → TESTCASES → PLAN`；把全流程自动化塞进同一命令会让职责混杂。
- **方案 B：新增 `/sandtable-autopilot` + `skills/autonomous-orchestration/SKILL.md`。**
  - 优点：职责单一，明确就是“无人值守总指挥”；可以从原始需求一路编排到复盘，并把自动轮次/配额/阻塞规则写清楚。
  - 缺点：多一个命令和一个 skill，需要同步更新索引与文档。
- **方案 C：新增外部 shell 脚本去驱动命令。**
  - 优点：看起来“自动化”更强。
  - 缺点：本仓方法论的核心载体是 skill + slash 命令，不是外部运行器；引入脚本会把编排逻辑拆到仓外，偏离现有架构。

**推荐：方案 B。** 它最符合当前仓库“命令编排 + skill 约束 + state/journal 持久化”的结构，也能把“全流程自动”和“已有手动战术动作”并存下来。

## 4. 用户故事 / 场景
- 作为开发者，我给出一句需求后，希望 AI 能**自己完成侦察、目标、用例、计划与多轮推演**，而不是每一步都回来问“要不要继续下一步”。
- 作为主 agent，我希望有一份明确的**自动作战规则**：至少 3 轮头脑预演、3 轮红蓝对抗、2 轮实现预演，以及每轮至少 3/3/2 个子 agent；不达标就继续，不让我临场拍脑袋。
- 作为接手的另一个人/AI，我希望 `state.md` 与 `journal.md` 能准确记录自动模式的目标配额、已完成轮次与最近一次自动决策，这样中断后可续。

## 5. 功能需求
- **FR1（新 skill：自主总指挥）**：新增 `skills/autonomous-orchestration/SKILL.md`，定义“从原始需求到复盘择优”的无人值守 Sandtable 全流程：`INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN → MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE`。正常情况下主 agent 自主决定下一步，不向开发者逐步请示。
- **FR2（新命令入口）**：新增 `commands/sandtable-autopilot.md` 与 `.cursor/commands/sandtable-autopilot.md`，入口语义明确为“一键全自动推进”。它读取 `skills/autonomous-orchestration/SKILL.md`，并要求所有进展写回 `state.md` / `journal.md` / `rehearsals/`。
- **FR3（自动作战配额）**：自动模式必须硬性执行以下最低配额，少一轮都不算完成：
  - 头脑预演至少 **3 轮**，每轮至少 **3 个只读子 agent**；
  - 红蓝对抗至少 **3 轮**，每轮至少 **3 个红军子 agent**；
  - 实现预演至少 **2 轮**，每轮至少 **2 个独立 worktree 子 agent**。
  若某轮发现异常/攻破/阻塞，先走修正循环，再重新满足该阶段最低配额。
- **FR4（自动修正闭环）**：任一轮出现 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED` 时，主 agent 必须先亲自核实，再把结论写回 `prd.md` / `tests.md` / `plan.md` / `journal.md` / `state.md`。回退规则按“**最早尚未重新验证的阶段**”执行：若只是文档产物（PRD/tests/plan）被修正且问题是在头脑预演中发现，则把 `phase` 设回 `MENTAL_REHEARSAL` 并从头重跑该阶段；若红蓝对抗攻破后修正计划，则把 `phase` 设回 `MENTAL_REHEARSAL`，重新经过 mental → redteam；若实现预演中修正了计划/产物，则把 `phase` 设回 `MENTAL_REHEARSAL`，重新走完整推演链。不能把“异常已发现”当成“本轮算通过”。每次自动推进或回退都要同步更新 `state.md.phase` 与 `autonomy.last_decision`。
- **FR5（真正的阻塞才问人）**：子 agent 返回 `BLOCKED` 后，主 agent 必须先分类：若通过补充文档、修正计划、重排步骤即可继续，则按 FR4 作为内部可修正阻塞处理，不设置 `state.md.blocked=true`；只有读代码/读文档都无法确认的产品意图、必须人工登录/授权/批准、或任何工具权限限制导致无法继续时，才允许把该 `BLOCKED` 升级为真正阻塞，写入 `questions.md`、`state.md.blocked=true` 后向开发者提问。不能因为“流程上通常会问一句”就停。
- **FR6（状态持久化可续）**：扩展 `state.md` / `templates/state.md` / `state-and-memory`，持久化自动模式信息：`autonomy.mode`（`manual|autopilot`，作为是否处于自动模式的唯一权威开关）、最低轮次、每轮最少子 agent 数、已完成轮次、最近自动决策摘要 `autonomy.last_decision`。进入 autopilot、每次自动推进、每次回退重演时都必须写回这些字段。`/sandtable-resume` 与 `/sandtable-status` 必须能读懂这些字段。
- **FR7（手动战术动作继续保留）**：现有 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 不被删除；但 `README.md`、`skills/using-sandtable/SKILL.md`、`AGENTS.md`、`.cursor/rules/sandtable.mdc`、相关命令说明要把 `/sandtable-autopilot` 作为新的“全自动入口”纳入索引，并与手动入口职责划清边界。
- **FR8（文档与数量自洽）**：新增 skill/command 后，`docs/sandtable/project.md` 中的数量统计、README 的命令表/目录结构、AGENTS 与 Cursor rule 的技能索引/命令索引都要同步，不得出现“仓里已有文件但索引没写”或“文档声称有 autopilot 但实际不存在”。

## 6. 验收标准（成功定义 · 抽象层；具体场景见 tests.md TC1-TC8）
- [ ] 存在一个明确的“无人值守总指挥”入口，能覆盖从需求输入到复盘择优的全流程，而不是只覆盖计划后半段。〔见 TC1 / TC2〕
- [ ] 自动模式对三类推演的最低轮次与每轮最少子 agent 数有硬约束，且异常后会自动回修正循环再补足轮次。〔见 TC3 / TC4 / TC5〕
- [ ] 自动模式与 `state.md` / `journal.md` / `rehearsals/` 持久化打通，中断后可续，不靠对话上下文记忆。〔见 TC6〕
- [ ] 真正需要开发者介入时会如实阻塞并写问题；非阻塞场景不会平白停下来等人。〔见 TC7〕
- [ ] 新命令/skill/文档索引全仓自洽，现有手动命令仍保留且边界清晰。〔见 TC8〕

## 7. MUST（绝对要做）
- 自动模式的最低配额必须按你的原话落地：mental `3x3`、redteam `3x3`、impl `2x2`。
- 自动流程必须覆盖 `RECON / OBJECTIVES / TESTCASES / PLAN`，不能只自动化推演半段。
- 异常必须“亲自核实 → 写回文档 → 重演”，不允许子 agent 私自改计划继续推进。
- 自动模式的编排规则必须落盘到 `state.md` / `journal.md`，保证恢复能力。
- 现有手动命令继续可用，自动入口是新增而不是替换。

## 8. MUST NOT（绝对不能做）
- 不把“需要开发者确认每一步”包装成“自动化”。
- 不把最低轮次写成“建议”或“默认值可跳过”；它们是硬门槛。
- 不把自动模式的状态只留在 chat 上下文里，不写入 `docs/sandtable/`。
- 不引入新的运行时依赖或仓外编排器来完成这个功能；沿用现有 `skills/` + `commands/` + `state` 架构。
- 不删除或弱化现有 `/sandtable-start`、`/sandtable-rehearse` 等手动入口。
- 不新增与本需求无关的“智能调度”“评分优化”“自动发 PR”等节外生枝功能。

## 9. 非目标 / 暂不做（YAGNI）
- 不做通用的子 agent 调度平台。
- 不为自动模式增加新的外部配置文件或 CLI。
- 不改写三类推演子 agent prompt 的方法论核心，只补足自动编排入口与状态承载。
- 不自动帮用户 push、发 PR、发布版本。

## 10. 未决问题
当前无阻塞未决问题；若实现中发现“自动推进是否允许在主仓直接 INTEGRATE”需要开发者另行拍板，再写入 `questions.md`。
