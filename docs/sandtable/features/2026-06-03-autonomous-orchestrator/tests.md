# 全自主自动沙盘编排 autopilot · 本需求的测试用例

> 我在用 writing-tests 把需求具体化为测试用例。
> 黑盒、场景化、人可读。每条用例映射回 `prd.md` 的 FR / 验收标准 / MUST / MUST NOT。
> 审阅指引：开发者先读本文件判断“AI 是否真的懂了什么叫全自主自动编排”，再读 PRD §6 勾选是否做完。

---

## TC1 · 一个命令覆盖从需求到复盘的全流程
- **映射**：FR1 / FR2
- **Given**：仓库新增了 `/sandtable-autopilot` 命令与 `skills/autonomous-orchestration/SKILL.md`。
- **When**：开发者给出一句原始需求后触发 `/sandtable-autopilot`。
- **Then**：命令说明与 skill 明确写出流程从 `INTAKE/RECON/OBJECTIVES/TESTCASES/PLAN` 一直推进到 `MENTAL_REHEARSAL/REDTEAM/IMPL_REHEARSAL/EVALUATE`，不是“做到计划后提示用户自己继续”；并明确 `INTAKE` 由 `state-and-memory` 建档/恢复、`RECON→PLAN` 显式沿用 `gathering-intel → writing-prd → writing-tests → writing-plan`，同时区分“全新需求从前序流程起跑”与“已有 feature 从当前 `phase` / 最早尚未完成阶段续接”，不会把进行中的需求无条件打回 `RECON`。
- **状态**：待验证

## TC2 · 自动模式默认不逐步等人确认
- **映射**：FR1 / FR5 / MUST NOT“不把需要开发者确认每一步包装成自动化”
- **Given**：自动模式的 skill 与命令文案。
- **When**：人阅读自动模式的执行规则。
- **Then**：正常路径写明“主 agent 自主决定下一步，不向开发者逐步请示”；并明确 `/sandtable-autopilot` 的显式触发本身就视为对“从 INTAKE 建档到 PLAN 完成”的前序连续推进预授权，会在 `<AUTOPILOT-OVERRIDE>` 段中覆盖手动命令（至少 `/sandtable-start`、`/sandtable-recon`、`/sandtable-objectives`、`/sandtable-plan`、`/sandtable-resume`）与 `gathering-intel` / `writing-prd` / `writing-tests` / `writing-plan` 中“请我确认后继续”“PRD/用例已确认”之类的旧语义；并明确该 override 只在本回合显式执行 `/sandtable-autopilot` 或 `/sandtable-resume` 自动续跑时生效，不得因为 `autonomy.mode=autopilot` 就静默削弱开发者随后显式触发的手动 slash 命令。并明确在 autopilot 下若缺少全局 `project.md` / `constraints.md`，允许按模板自主初始化，除非触发 FR5 定义的真正阻塞。只有真正阻塞（缺产品意图、权限、登录、批准等）才写 `questions.md` 并停下。
- **状态**：待验证

## TC3 · 头脑预演至少三轮且每轮至少三个子 agent
- **映射**：FR3 / MUST“mental 3x3”
- **Given**：自动模式配置写入 skill / state 模板。
- **When**：人读自动模式的配额定义与 `state.md` 持久化字段。
- **Then**：能明确看到 mental 最低配额是 `3` 轮、每轮至少 `3` 个只读子 agent；若某轮发现 anomaly，文档要求先修正再补足轮次，不能直接把该轮算过；并写清只有当该轮达到最低子 agent 数、全部返回成功信号且已写入本轮 `rehearsals/` 报告时，才允许给 `autonomy.completed_rounds.mental` 加一。手动 `/sandtable-mental` / `/sandtable-rehearse` 先前留下的 `rehearsals/*.md` 不能直接拿来抵 autopilot 的第 1-3 轮；autopilot 接手后也必须重新派满该轮最低子 agent 数并重写本轮报告，才能计入自动模式进度。
- **状态**：待验证

## TC4 · 红蓝对抗至少三轮且每轮至少三个红军子 agent
- **映射**：FR3 / MUST“redteam 3x3”
- **Given**：自动模式配置写入 skill / state 模板。
- **When**：人读自动模式的对抗规则。
- **Then**：能明确看到 redteam 最低配额是 `3` 轮、每轮至少 `3` 个红军子 agent；每轮都要求指定攻击向量并记录 `HELD` / `BREACH_FOUND`；若被攻破，则回到 `MENTAL_REHEARSAL` 后重新补足整条推演链的最低配额；且不能因为当前 `phase` 已在 `REDTEAM` 或之后，就跳过尚未补足的 mental 轮次。手动 `/sandtable-redteam` / `/sandtable-rehearse` 先前留下的报告不算 autopilot 的 redteam 达标轮次，autopilot 接手后必须重新派满该轮最低红军子 agent 数并重写本轮报告。
- **状态**：待验证

## TC5 · 实现预演至少两轮且每轮至少两个独立 worktree 子 agent
- **映射**：FR3 / MUST“impl 2x2”
- **Given**：自动模式配置写入 skill / state 模板。
- **When**：人读实现预演编排规则。
- **Then**：能明确看到 impl 最低配额是 `2` 轮、每轮至少 `2` 个独立 worktree 子 agent；只要有 `ANOMALY_FOUND` / `BLOCKED` 就必须回修正循环，全部 `DONE` 后才进入复盘择优；并写清 autopilot 下只有 `completed_rounds.impl` 达标且前序 mental/redteam 也已补满后，才允许继续 `EVALUATE`。手动 `/sandtable-live` / `/sandtable-rehearse` 先前留下的实现预演报告不算 autopilot 的 impl 达标轮次，autopilot 接手后必须重新派满该轮最低 worktree 子 agent 数并重写本轮报告。
- **状态**：待验证

## TC6 · 自动模式状态可恢复
- **映射**：FR6 / 验收“持久化打通，中断后可续”
- **Given**：更新后的 `templates/state.md`、`skills/state-and-memory/SKILL.md`、`commands/sandtable-status.md` 与 `commands/sandtable-resume.md`（含 Cursor 副本）。
- **When**：人阅读状态模板与恢复说明。
- **Then**：`state.md` 里存在自动模式相关字段（至少包括 `autonomy.mode`、最低轮次、每轮最少子 agent 数、已完成轮次、最近自动决策）；并明确“进入 autopilot / 每次自动推进 / 每次回退重演”都会同步写回这些字段与 `phase`；`/sandtable-status` 与 `/sandtable-resume` 都明确会读取这些字段，而不是只看传统汇总计数。其中文档还要写清：`autonomy.completed_rounds` 表示当前仍然有效的自动进度，仅用于三类推演阶段；前序流程回退目标按被修正的最早产物映射到 `RECON/OBJECTIVES/TESTCASES/PLAN`，只改 `state.md` / `journal.md` / `questions.md` 不改变前序 `phase`，此时 `completed_rounds` 保持 `0/0/0`；一旦进入推演链后发生任何需要写回文档再重演的 `ANOMALY_FOUND` / `BREACH_FOUND` / 内部可修正 `BLOCKED`，都统一回退到 `MENTAL_REHEARSAL`，`mental/redteam/impl` 的 `completed_rounds` 必须全部清零；`rehearsals.*.runs`、`rehearsals.*.last` 与既有 `rehearsals/*.md` 只保留历史统计和最近结果，不作为续跑权威；无论是 `/sandtable-resume` 还是重新执行 `/sandtable-autopilot` 续接已有 feature，只要 `phase` 与 `completed_rounds` 指向的最早未完成推演阶段不一致，都必须先按配额闭包优先纠偏，再决定下一步，并写入 `autonomy.last_decision`。
- **状态**：待验证

## TC7 · 真阻塞才问人，普通异常自动修正
- **映射**：FR4 / FR5
- **Given**：自动模式的异常处理规则。
- **When**：人分别阅读“异常”“阻塞”两类处置。
- **Then**：普通 `ANOMALY_FOUND` / `BREACH_FOUND` 会进入“亲自核实 → 写回 PRD/tests/plan/state/journal → 重演”；子 agent 返回 `BLOCKED` 时会先被主 agent 分类，只有读代码与文档仍无法确认的需求、权限、登录、批准等外部依赖才会升级为 `blocked=true` 并向开发者提问，其余 `BLOCKED` 按内部可修正阻塞回修正循环。
- **状态**：待验证

## TC8 · 全仓索引与手动入口保持自洽
- **映射**：FR7 / FR8
- **Given**：新增了 autopilot skill/command 的仓库。
- **When**：先运行正向检查：`rg -n "sandtable-autopilot|autonomous-orchestration|前五步|前序编排|只串推演|12 个 skill|13 个 slash 命令|sandtable-start|sandtable-rehearse|sandtable-mental|sandtable-redteam|sandtable-live" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md skills/autonomous-orchestration/SKILL.md commands .cursor/commands docs/sandtable/project.md && rg -n "autonomous-orchestration/" README.md && rg -n "/sandtable-start.*前五步|/sandtable-start.*前序编排" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "/sandtable-rehearse.*只串推演与复盘" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "/sandtable-autopilot|sandtable-mental|sandtable-redteam|sandtable-live" README.md AGENTS.md .cursor/rules/sandtable.mdc && rg -n "^description: 启动 Sandtable 前五步流程|^description: 串起推演与复盘" commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "前五步编排命令|只串推演与复盘|不会自动计入 `autonomy.completed_rounds`|重新派满该轮最低子 agent 数" skills/using-sandtable/SKILL.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md && rg -n "`/sandtable-start`（受领任务·前序编排：受领→侦察→目标→用例→计划）|`/sandtable-rehearse`（推演编排·只串推演与复盘）|`/sandtable-autopilot`（全自动总指挥·从需求到复盘无人值守推进）" AGENTS.md .cursor/rules/sandtable.mdc`；再运行负向检查：`! rg -n "编排全流程|一键串起全部推演|一键编排|可一键串起|一键串起 图上|仅串起 图上|仅串起|只串起|总演习|总入口|澄清→PRD→用例→计划→预演|串起三类推演与复盘|串起三类推演\\+复盘|串起三类推演 \\+ 复盘" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md skills/autonomous-orchestration/SKILL.md commands/sandtable-autopilot.md .cursor/commands/sandtable-autopilot.md commands/sandtable-start.md .cursor/commands/sandtable-start.md commands/sandtable-rehearse.md .cursor/commands/sandtable-rehearse.md`；最后运行文件存在性检查：`test -f skills/autonomous-orchestration/SKILL.md && test -f commands/sandtable-autopilot.md && test -f .cursor/commands/sandtable-autopilot.md && test -f commands/sandtable-start.md && test -f commands/sandtable-rehearse.md && test -f commands/sandtable-mental.md && test -f commands/sandtable-redteam.md && test -f commands/sandtable-live.md && test -f .cursor/commands/sandtable-start.md && test -f .cursor/commands/sandtable-rehearse.md && test -f .cursor/commands/sandtable-mental.md && test -f .cursor/commands/sandtable-redteam.md && test -f .cursor/commands/sandtable-live.md`；再做人工审读：逐段检查 `README.md` 的命令表与用法段、`AGENTS.md` 与 `.cursor/rules/sandtable.mdc` 的主 slash 列表及其附近说明、`skills/using-sandtable/SKILL.md` 的阶段总览句与补充说明、`skills/autonomous-orchestration/SKILL.md` 的边界说明、`commands/sandtable-autopilot.md` 与 `.cursor/commands/sandtable-autopilot.md` 的正文，只允许“前五步/前序编排/只串推演与复盘/全自动总指挥”这组边界，不接受 `核心入口`、`主入口`、`推演总控`、`综合演习`、`串联三类推演`、`一次串完`、`统筹全流程` 等同义复述旧心智。`
- **Then**：正向检查必须分别命中 autopilot、新 skill、README 目录结构、`/sandtable-start` 的“前五步/前序编排”边界、`/sandtable-rehearse` 的“只串推演与复盘”边界、保留的手动命令和 `project.md` 计数；不能把 `sandtable-mental` / `sandtable-redteam` / `sandtable-live` 的存在命中混成对 start/rehearse 边界已收束的证明。`AGENTS.md` 与 `.cursor/rules/sandtable.mdc` 的**主 slash 列表**必须原位替换为精确的新边界条目，不能只在其它段落追加一条合规说明。负向检查在 start/rehearse 相关索引与命令文件中不得再出现旧的冲突表述；其中 `skills/using-sandtable/SKILL.md`、`skills/autonomous-orchestration/SKILL.md`、`commands/sandtable-autopilot.md`、`.cursor/commands/sandtable-autopilot.md`、`README.md`、`AGENTS.md`、`.cursor/rules/sandtable.mdc` 都不能残留 `rehearse` 的“总入口/总演习/串起三类推演与复盘”式旧语义。文件存在性检查必须证明 `skills/autonomous-orchestration/SKILL.md`、`/sandtable-autopilot`、`/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的命令文件及其 Cursor 副本仍存在。README 的命令表与目录结构、总入口 skill、AGENTS、Cursor rule、命令目录、project.md 都要能找到对应入口与描述；同时仍保留 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 等手动命令，不存在“文档有 autopilot 但命令缺失”或“新增入口后手动入口消失”的情况。README / AGENTS / Cursor rule 中原有 start/rehearse 的描述必须同步收束为“前五步/前序编排”与“只串推演与复盘”；`commands/sandtable-start.md`、`.cursor/commands/sandtable-start.md` 的 frontmatter 必须收束为“启动 Sandtable 前五步流程”，`commands/sandtable-rehearse.md`、`.cursor/commands/sandtable-rehearse.md` 的 frontmatter 必须收束为“串起推演与复盘”，autopilot skill 与 autopilot 命令正文也只能把 autopilot 表述为新的全自动入口，不能把 `/sandtable-rehearse` 重新讲成全流程或总控入口。除 `rg` 与 `test -f` 外，人工审读必须明确否决任何“同义改写 + 脚注式合规 + 非主段落复述旧心智”的通过路径。`state-and-memory` 的 autopilot 回退语义改由 `TC6 / T3` 专门验证；`TC8` 不再把恢复规则语义混入索引对账。`docs/sandtable/project.md` 还必须把 skill 数从 `11` 改为 `12`、slash 命令数从 `12` 改为 `13`，不能只有入口描述而没有数量对账。
- **状态**：待验证
