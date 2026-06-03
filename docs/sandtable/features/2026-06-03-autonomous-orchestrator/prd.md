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
- **FR1（新 skill：自主总指挥）**：新增 `skills/autonomous-orchestration/SKILL.md`，定义“从原始需求到复盘择优”的无人值守 Sandtable 全流程：`INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN → MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE`。正常情况下主 agent 自主决定下一步，不向开发者逐步请示。`INTAKE` 阶段由 `state-and-memory` 负责建档/恢复；`RECON → PLAN` 四个前序阶段必须显式沿用 `gathering-intel → writing-prd → writing-tests → writing-plan` 这条 skill 链，不允许执行者即兴省略。开发者显式触发 `/sandtable-autopilot` 本身就视为对“从 INTAKE 建档到 PLAN 完成”的前序连续推进预授权；自动模式必须在新 skill 中用显式 `<AUTOPILOT-OVERRIDE>` 段覆盖手动命令（至少 `/sandtable-start`、`/sandtable-recon`、`/sandtable-objectives`、`/sandtable-plan`、`/sandtable-resume`）与 `gathering-intel` / `writing-prd` / `writing-tests` / `writing-plan` 这些相关 skill 里“请我确认后继续”“PRD/用例已确认”之类的旧门槛，只在 FR5 定义的真正阻塞场景停下。该 override 只在**当前回合明确由 `/sandtable-autopilot` 触发**，或由 `/sandtable-resume` 在 `autonomy.mode=autopilot && blocked=false` 的自动续跑分支里生效；若开发者显式触发 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 等手动命令，则这些命令仍按手动语义执行，不能因 `autonomy.mode=autopilot` 而被静默降级。
- **FR2（新命令入口）**：新增 `commands/sandtable-autopilot.md` 与 `.cursor/commands/sandtable-autopilot.md`，入口语义明确为“一键全自动推进”。它读取 `skills/autonomous-orchestration/SKILL.md`，并要求所有进展写回 `state.md` / `journal.md` / `rehearsals/`。对全新需求，它从 `INTAKE/RECON` 开始完整推进；对已存在的 feature，它先读取当前 `state.md.phase` 与 `autonomy.*`，从当前阶段或最早尚未完成的前序阶段续接，不能无条件把进行中的需求打回 `RECON`。
- **FR3（自动作战配额）**：自动模式必须硬性执行以下最低配额，少一轮都不算完成：
  - 头脑预演至少 **3 轮**，每轮至少 **3 个只读子 agent**；
  - 红蓝对抗至少 **3 轮**，每轮至少 **3 个红军子 agent**；
  - 实现预演至少 **2 轮**，每轮至少 **2 个独立 worktree 子 agent**。
  若某轮发现异常/攻破/阻塞，先走修正循环；若异常发生在前序流程，则补足该前序阶段后的后续流程；若异常发生在推演链，则按 FR4 回到 `MENTAL_REHEARSAL` 后重新补足整条推演链的最低配额。`phase` 不是“下一步跑哪一类推演”的唯一依据：只要 `autonomy.completed_rounds` 中存在未达最低配额的阶段，autopilot 就必须优先回到**最早一个未满足配额的推演阶段**继续补轮，不能因为 `phase` 停在 `REDTEAM` 或 `IMPL_REHEARSAL` 就跳过 mental/redteam 缺口。只有当某一轮满足“达到该轮最低子 agent 数 + 该轮所有子 agent 都返回成功信号 + 本轮报告已写入 `rehearsals/`”时，才允许把对应 `completed_rounds` 加一；手动命令单独运行留下的 `rehearsals.*.runs` / `rehearsals.*.last` / `rehearsals/*.md` 都不算 autopilot 达标依据。即使 autopilot 之后接手，也必须由 autopilot **重新派满该轮最低子 agent 数并重写本轮报告**，才允许把该轮记入自动模式进度。
- **FR4（自动修正闭环）**：任一轮出现 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED` 时，主 agent 必须先亲自核实，再把结论写回 `prd.md` / `tests.md` / `plan.md` / `journal.md` / `state.md`。回退规则必须写成可执行的两段式，而不是留给执行者猜：  
  - 若异常/内部可修正阻塞发生在前序流程（`INTAKE / RECON / OBJECTIVES / TESTCASES / PLAN`）内部，则回退目标按**被修正的最早产物映射**判定，而不是口头说“最早尚未重新验证”就结束：`project.md` / `constraints.md` / 侦察结论变化 → `RECON`；`prd.md` 变化 → `OBJECTIVES`；`tests.md` 变化 → `TESTCASES`；仅 `plan.md` 变化 → `PLAN`；若只改了 `state.md` / `journal.md` / `questions.md` 这类记账文件而未改前序产物，则保留当前前序 `phase` 不变。随后从映射到的阶段继续补跑直到 `PLAN`。此时 `autonomy.completed_rounds` 仍应保持 `0/0/0`。  
  - 一旦已经进入推演链（`MENTAL_REHEARSAL / REDTEAM / IMPL_REHEARSAL`），任一 `ANOMALY_FOUND` / `BREACH_FOUND` / 内部可修正 `BLOCKED` 只要需要写回文档后重演，就统一把 `phase` 设回 `MENTAL_REHEARSAL`，重新走 mental → redteam → impl 的完整链条；不再区分“是否只改了前序产物”这个条件。此时 `autonomy.completed_rounds.mental/redteam/impl` 必须全部清零，确保后续 resume 会按新计划重新补足配额。  
  不能把“异常已发现”当成“本轮算通过”。每次自动推进或回退都要同步更新 `state.md.phase` 与 `autonomy.last_decision`。`rehearsals.*.runs` 只表示历史尝试次数，不作为 autopilot 续跑权威。
- **FR5（真正的阻塞才问人）**：子 agent 返回 `BLOCKED` 后，主 agent 必须先分类：若通过补充文档、修正计划、重排步骤即可继续，则按 FR4 作为内部可修正阻塞处理，不设置 `state.md.blocked=true`；只有读代码/读文档都无法确认的产品意图、必须人工登录/授权/批准、或任何工具权限限制导致无法继续时，才允许把该 `BLOCKED` 升级为真正阻塞，写入 `questions.md`、`state.md.blocked=true` 后向开发者提问。不能因为“流程上通常会问一句”就停。
- **FR6（状态持久化可续）**：扩展 `state.md` / `templates/state.md` / `state-and-memory`，持久化自动模式信息：`autonomy.mode`（`manual|autopilot`，作为是否处于自动模式的唯一权威开关）、最低轮次、每轮最少子 agent 数、已完成轮次、最近自动决策摘要 `autonomy.last_decision`。进入 autopilot、每次自动推进、每次回退重演时都必须写回这些字段。`autonomy.completed_rounds` 表示**当前仍然有效**的 autopilot 进度；`rehearsals.*.runs` / `rehearsals.*.last` / 既有 `rehearsals/*.md` 仅保留历史统计与最近结果，不作为续跑权威。`/sandtable-resume` 与 `/sandtable-status` 必须能读懂这些字段，并在 `mode=autopilot` 时优先按它们续跑；无论是 `/sandtable-resume` 还是重新执行 `/sandtable-autopilot` 续接已有 feature，只要 `phase` 与 `completed_rounds` 表示的“最早未完成推演阶段”不一致，都必须先按配额闭包纠偏，再决定下一步，并写 `autonomy.last_decision` 说明原因。`phase` 在 autopilot 下只是当前记录位置，不得压过配额闭包。`autonomy.min_rounds` 只是把硬门槛写回 `state.md` 供恢复和展示，不得被执行者当成可调旋钮；若与 skill 中固定的 `mental 3 / redteam 3 / impl 2` 不一致，必须登记为 anomaly 并纠正，不能按被篡改值续跑。
- **FR7（手动战术动作继续保留）**：现有 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 不被删除；但 `README.md`、`skills/using-sandtable/SKILL.md`、`skills/autonomous-orchestration/SKILL.md`、`commands/sandtable-autopilot.md`、`.cursor/commands/sandtable-autopilot.md`、`AGENTS.md`、`.cursor/rules/sandtable.mdc`、相关命令说明要把 `/sandtable-autopilot` 作为新的“全自动入口”纳入索引，并与手动入口职责划清边界。不能只“新增 autopilot 一行”而保留旧的“start 编排全流程”“rehearse 总入口/总演习”“串起三类推演与复盘”表述不改；包括 `sandtable-rehearse` 的 frontmatter `description` 与 `using-sandtable` 中的阶段总览句在内，都要同步收束语义，避免新旧规则并存。README 命令表、AGENTS slash 列表、Cursor rule slash 列表这些**主索引位**必须原位替换为新边界；同时 autopilot skill 与 autopilot 命令正文也不得复述旧总入口心智，不允许靠追加脚注/补充说明来掩盖旧主体表述。
- **FR8（文档与数量自洽）**：新增 skill/command 后，`docs/sandtable/project.md` 中的数量统计、README 的命令表/目录结构、AGENTS 与 Cursor rule 的技能索引/命令索引都要同步，不得出现“仓里已有文件但索引没写”或“文档声称有 autopilot 但实际不存在”。`state-and-memory` 的 autopilot 回退语义由 `FR6 / TC6 / T3` 专门约束，不再把它混入 `TC8` 的索引对账里；其要求是**替换**旧的未分支回退简写，而不是额外补一段 autopilot 说明后与旧规则并存。

## 6. 验收标准（成功定义 · 抽象层；具体场景见 tests.md TC1-TC8）
- [ ] 存在一个明确的“无人值守总指挥”入口，能覆盖从需求输入到复盘择优的全流程，而不是只覆盖计划后半段。〔见 TC1 / TC2〕
- [ ] 自动模式对三类推演的最低轮次与每轮最少子 agent 数有硬约束，且异常后会自动回修正循环再补足轮次。〔见 TC3 / TC4 / TC5〕
- [ ] 自动模式与 `state.md` / `journal.md` / `rehearsals/` 持久化打通，中断后可续，不靠对话上下文记忆；续接时不会把进行中的需求错误打回 `RECON`，回退后也不会错把旧轮次当成仍然有效。〔见 TC6〕
- [ ] 真正需要开发者介入时会如实阻塞并写问题；非阻塞场景不会平白停下来等人。〔见 TC7〕
- [ ] 新命令/skill/文档索引全仓自洽，现有手动命令仍保留且边界清晰；README / AGENTS / Cursor rule 与 `commands/.cursor/commands` 中原有 start/rehearse 表述不会再与 autopilot 冲突。〔见 TC8〕

## 7. MUST（绝对要做）
- 自动模式的最低配额必须按你的原话落地：mental `3x3`、redteam `3x3`、impl `2x2`。
- 自动流程必须覆盖 `INTAKE / RECON / OBJECTIVES / TESTCASES / PLAN`，不能只自动化推演半段。
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
