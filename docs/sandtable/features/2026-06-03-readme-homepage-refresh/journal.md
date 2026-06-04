# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/推演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-03 23:52 · [受领任务 INTAKE]
- 背景：开发者显式执行 `/sandtable-autopilot`，要求把 GitHub 首页 README 改成一个成熟、形象、简洁、AI 友好的首页，并明确要求流程图清晰、加入 `superpowers` 对比、突出优势、体现本仓正在用这种方式迭代自己。
- 内容：建立 feature 工作区 `2026-06-03-readme-homepage-refresh`，把需求收束为“README 首页信息架构重塑”，而不是扩展方法论本体。
- 依据/来源：开发者本轮 `/sandtable-autopilot` 指令原文。

## 2026-06-03 23:54 · [情报侦察 RECON]
- 背景：核实现有 README 已经讲了什么、缺了什么，以及 `superpowers` 对比能写到什么边界。
- 内容（已确认事实）：
  - 当前 README 已写出 Sandtable 的定位、核心特性、安装与命令表，但首屏仍偏“定义说明”，尚未形成强首页叙事（`README.md:1-27`、`README.md:54-75`）。
  - 当前 README 没有显式的首页对比区块，也没有一个帮助访客快速理解闭环的流程图（`README.md:9-27`、`README.md:54-123`）。
  - 项目北极星明确说明本仓“既是方法论本体，也用自身方法论自举改进自己”，可作为 README 的自举证明（`docs/sandtable/project.md:5-11`）。
  - 当前仓库已经具备 `autonomous-orchestration`、`state-and-memory`、`/sandtable-autopilot` 等可以前置表达的差异化能力（`README.md:13-20`、`skills/autonomous-orchestration/SKILL.md:13-19`、`skills/state-and-memory/SKILL.md:6-18`）。
  - 已核读 `superpowers` README：对方明确强调 brainstorming、plans、subagent-driven-development、TDD、code review、worktrees 等能力；因此 Sandtable README 的对比必须写“重心差异”，不能靠虚构对方缺点来凸显自己（来源：`https://raw.githubusercontent.com/obra/superpowers/main/README.md`）。
- 依据/来源：见上各文件与 URL。

## 2026-06-03 23:56 · [决策 OBJECTIVES]
- 背景：基于侦察结果确定 README 改造路径。
- 内容：
  - 方案对比：A=局部追加卖点；B=重构首页信息架构；C=营销化重写。判定 B 最符合“成熟、简洁、AI 友好、能让人一下子知道”的目标。
  - 明确本次 README 的核心表达顺序应为：价值主张 → 记忆点 → 流程图 → 对比 → 自举证明 → 快速开始。
  - 明确红线：`superpowers` 对比必须真实；不写虚构数据；不新增 README 中无法兑现的新能力。
- 依据/来源：侦察结论 + 开发者原话。

## 2026-06-03 23:57 · [测试用例 TESTCASES]
- 背景：把“首页形象建设”转成可人工判断的黑盒场景，避免后续只停留在文案感觉上。
- 内容：写出 TC1-TC7，覆盖首屏理解速度、流程图闭环、`superpowers` 对比真实性、Sandtable 核心记忆点前置、自举证明、试用路径保留和 AI 友好结构。
- 依据/来源：`tests.md` 当前版本。

## 2026-06-03 23:58 · [计划 PLAN]
- 背景：在 PRD 与 tests 基础上拆分出具体改写动作。
- 内容：产出 T1-T4 四个任务，聚焦 `README.md` 的首屏叙事、流程图与对比、自举证明与试用路径、以及最后的 GitHub 呈现检查；确认本次只改 README 与本 feature 文档。
- 依据/来源：`plan.md` 当前版本。

## 2026-06-04 00:02 · [推演 MENTAL_REHEARSAL]
- 背景：首次并行发出 3 个只读子 agent 做第 1 轮头脑预演，但它们在前台运行时被开发者后续消息打断，未形成有效结果。
- 内容：判定这不是需求级异常，也不计入已完成轮次；改为后台并行运行 mental 子 agent，避免再次被前台聊天中断。
- 依据/来源：3 个前台子 agent 返回 “interrupted by the user”。

## 2026-06-04 08:20 · [异常 MENTAL_REHEARSAL]
- 背景：后台第 1 轮 mental 子 agent 中，试用路径审查方向已返回有效 anomaly。
- 内容（已核实成立）：
  - 当前 PRD 只写“保留安装/接入与命令入口”，但没有把“前两屏内必须出现立刻试用入口/锚点”写成硬约束，存在首页说服力增强但试用路径后移的风险。
  - 当前 PRD / tests / plan 也没有把“首页长度预算、首屏段落上限、新增模块必须伴随压缩旧说明”写成可判定标准，存在 README 在现有基础上继续叠加、变长变空的风险。
  - 现有验证偏向关键词存在性，尚不足以证明安装命令、接入方法和命令入口仍然低摩擦可达。
- 处置：已修订 `prd.md` / `tests.md` / `plan.md`：补入前两屏试用入口、长度预算、单跳可达、以及“新增模块必须伴随删改旧说明”的硬约束；新增 `TC8` 专门约束首页膨胀与入口后移风险；`state.md` 保持 `MENTAL_REHEARSAL`，继续等待其余 mental 子 agent 结果。
- 依据/来源：后台子 agent “试用路径预演1” 返回结果 + 主 agent 对 `prd.md/tests.md/plan.md` 的复核。

## 2026-06-04 08:22 · [异常 MENTAL_REHEARSAL]
- 背景：后台第 1 轮 remaining 2 个 mental 子 agent 已全部完成，分别返回“首页叙事优先级不足”和“`superpowers` 对比边界仍可滑向无证优越性判断”的 anomaly。
- 内容（已核实成立）：
  - 原需求虽要求“前两屏讲清价值与闭环”，但没有固定前两屏只服务“为什么值得试 / 如何闭环防失控”这两个判断题，也没有把闭环图位置压到首屏后紧接处。
  - 原需求虽禁止虚构 `superpowers` 缺失能力，但还没有一律禁止无事实锚点的 superiority claim。
  - 这 3 个 anomaly 已被收束到同一组文档修订：前两屏优先级、流程图位置、对比允许句型、人工逐句审查。
- 处置：已继续修订 `prd.md` / `tests.md` / `plan.md`，并写出 `rehearsals/mental-1.md` 记录本轮 anomaly；将 `rehearsals.mental.runs` 记为 1、`last=anomaly`，但 `autonomy.completed_rounds.mental` 仍保持 0，准备按修正后的文档重跑第 1 轮 mental。
- 依据/来源：后台子 agent “首页叙事预演1”“对比边界预演1” 返回结果 + 主 agent 对文档的复核。

## 2026-06-04 08:24 · [异常 MENTAL_REHEARSAL]
- 背景：第 1 轮 mental 重跑中，“对比边界预演1重跑”仍返回 anomaly，指出 `tests.md` 和 `plan.md` 对对比区块的边界还有两处残余松口。
- 内容（已核实成立）：
  - `TC3` 标题与 `Then` 仍残留“突出优势”“取胜”这类结果导向措辞，容易让执行者误以为允许 superiority framing。
  - `plan.md` 对事实锚点的要求仍写成“必要时”，没有强制每个对比点都能回指到已核读事实。
- 处置：已继续修订 `tests.md` 与 `plan.md`：把 `TC3` 收紧为“只允许事实差异，不允许优越性 framing”，并把 T2 的事实锚点要求改成逐点强制；当前继续等待最后一个重跑方向结果，再决定是否还需继续重跑本轮 mental。
- 依据/来源：后台子 agent “对比边界预演1重跑” 返回结果 + 主 agent 对 `tests.md` / `plan.md` 的复核。

## 2026-06-04 08:25 · [异常 MENTAL_REHEARSAL]
- 背景：第 1 轮 mental 重跑的最后一个方向返回 anomaly，指出试用入口仍可能退化为弱锚点，长度预算也仍偏主观。
- 内容（已核实成立）：
  - 现有约束虽然要求前两屏可见试用入口，但仍允许首屏没有可行动的试用摘要，存在“用户知道可以试，但不知道第一步做什么”的空档。
  - 长度预算虽已存在，但还缺总量上限与首屏模块清单，仍可能在主观上“觉得自己有压缩”，实际上让 README 继续膨胀。
- 处置：已继续修订 `prd.md` / `tests.md` / `plan.md`：把试用入口收紧为“首屏必须有可行动摘要，前两屏必须有单跳锚点”，把首屏模块和总行数上限写死为硬约束；三条重跑方向现已全部收束到同一组规则，下一步将继续重跑第 1 轮 mental。
- 依据/来源：后台子 agent “试用路径预演1重跑” 返回结果 + 主 agent 对文档的复核。

## 2026-06-04 08:27 · [异常 MENTAL_REHEARSAL]
- 背景：再次重跑的“首页叙事”方向返回 anomaly，但这次指出的是当前 `README.md` 成品尚未体现已收紧的首页约束，而不是 `prd.md/tests.md/plan.md` 本身还有新缺口。
- 内容（已核实成立）：
  - 当前 README 仍是旧结构，因此前两屏当然还没有形成“首屏试用摘要 → 紧随其后的闭环图 → 其余信息下沉”的成品形态。
  - 这说明本轮 mental 已开始撞到“实现尚未发生”的现实边界，而不再只是计划/约束缺口。
- 处置：判定这条 anomaly 属于**现状实现差距**，不再继续为同一问题追加规则；等待其余重跑方向结果后，若文档约束已闭环，则进入实际 README 改写。
- 依据/来源：后台子 agent “首页叙事预演1再重跑” 返回结果 + 主 agent 对当前 `README.md` 与已修订 `prd/tests/plan` 的复核。

## 2026-06-04 08:28 · [异常 MENTAL_REHEARSAL]
- 背景：同一批重跑中，“对比边界”方向仍返回 anomaly，指出当前约束已经做到块级收紧，但还没把“每个对比点都要挂事实锚点”写成逐点门槛。
- 内容（已核实成立）：
  - `prd.md` / `tests.md` / `plan.md` 仍以“整块对比区块受约束”为主，没有把逐点模板和逐点验收写死。
  - 这会留下“整体看起来克制，但个别句子仍失锚”的空档。
- 处置：已继续修订 `prd.md` / `tests.md` / `plan.md`：把 `FR3`、验收标准、MUST、`TC3` 与 T2 产物格式都收紧到“每个对比点 = 事实锚点 + 对应差异/先感知”；下一步将改用**只审查文档闭环、不要求当前 README 已实现**的口径重跑第 1 轮 mental。
- 依据/来源：后台子 agent “对比边界预演1再重跑” 返回结果 + 主 agent 对文档的复核。

## 2026-06-04 08:30 · [推演 MENTAL_REHEARSAL]
- 背景：改用“只审查文档闭环，不把当前 README 未实现视为异常”的口径后，重新并行派出 3 个只读子 agent 审查首页主叙事、对比边界与试用路径三条约束链。
- 内容：
  - 首页文档闭环：`LOGIC_CLOSED`
  - `superpowers` 对比文档闭环：`LOGIC_CLOSED`
  - 试用路径文档闭环：`LOGIC_CLOSED`
- 处置：已写入 `rehearsals/mental-2.md`；将该轮计为一轮有效 `mental` 通过，`autonomy.completed_rounds.mental=1`，并继续进入下一轮 `mental`。
- 依据/来源：后台子 agent “首页文档闭环预演重发”“对比文档闭环预演”“试用文档闭环预演” 返回结果。

## 2026-06-04 08:32 · [异常 MENTAL_REHEARSAL]
- 背景：第 2 轮 mental 的“README 实现风险”方向已返回 anomaly，开始聚焦真正落地 `README.md` 时最容易失手的实现层问题。
- 内容（已核实成立）：
  - 虽然文档已写首屏优先级，但还缺少一个“顶部 section 骨架”，实现者在动手时仍可能让首屏顺序漂移。
  - 虽然反复强调“不能只做加法”，但还缺一张现有 README 各 section 的明确处置清单，容易滑回“新首页 + 旧正文大体保留”。
  - 虽然有 160 行总预算，但还没有 section 级预算分配与超额时的删减顺序，落地时容易临时挤压关键入口。
- 处置：已修订 `plan.md`，加入 README 顶部骨架、旧 section 处置清单与 section 级行数预算；继续等待第 2 轮剩余两个实现层方向结果。
- 依据/来源：后台子 agent “README实现风险预演2A” 返回结果 + 主 agent 对 `plan.md` 的复核。

## 2026-06-04 08:34 · [异常 MENTAL_REHEARSAL]
- 背景：第 2 轮 mental 剩余两个实现层方向均已完成，分别指向“试用流默认路径/Cursor caveat 保护不足”和“措辞仍可能滑向营销腔/概念墙”。
- 内容（已核实成立）：
  - 现有约束虽然要求首屏有试用摘要，但还没固定每个主要 harness 的默认推荐路径，也没把 Cursor 本地插件的关键 caveat 升格为受保护事实。
  - 现有约束虽然压住了无证 superiority claim，但对 Sandtable 这一侧的表述仍可滑向“解释性优越判断”；首屏记忆点也仍有变成名词墙的风险。
  - 现有验收仍偏结构和关键词，缺少逐句文案红线与“顺读 + 一次跳转拿到安装命令/接入动作/第一条命令”的人工验收脚本。
- 处置：已继续修订 `prd.md` / `tests.md` / `plan.md`：补入默认推荐试用路径、Cursor caveat 保护、首屏记忆点“1 能力 + 1 结果”、对比区块两句制逐点事实模板，以及文案红线清单与顺读式验收脚本。第 2 轮 `mental` 现判为 anomaly 轮，不计入 `completed_rounds`；下一步按这些更硬的实现约束重跑第 2 轮 mental。
- 依据/来源：后台子 agent “README试用流预演2C”“README措辞风险预演2B重发” 返回结果 + 主 agent 对 `README.md/prd.md/tests.md/plan.md` 的复核。

## 2026-06-04 08:41 · [推演 MENTAL_REHEARSAL]
- 背景：第 2 轮 mental 的 3 个实现层方向现已全部收口，主 agent 已把所有成立异常写入新的实现护栏。
- 内容：
  - README 实现骨架 / 旧 section 拆除 / section 预算：已补入 `plan.md`
  - 默认推荐试用路径 / Cursor caveat / 顺读式验收：已补入 `prd.md` / `tests.md` / `plan.md`
  - 两句制对比模板 / 结果句锚点 / 文案红线失败条件：已补入 `prd.md` / `tests.md` / `plan.md`
- 处置：已写入 `rehearsals/mental-3.md` 作为 anomaly 轮记录；下一步继续重跑第 2 轮 mental，验证这些实现层护栏是否已经闭环。
- 依据/来源：本轮 3 个 mental 子 agent 返回结果 + 主 agent 的文档回写。

## 2026-06-04 08:44 · [异常 MENTAL_REHEARSAL]
- 背景：第 2 轮 mental 的重跑结果继续指出两处剩余实现护栏缺口：Cursor 默认路径仍像双选题，以及 `state.md` 尚未把本轮 anomaly 与 `journal.md` 对齐。
- 内容（已核实成立）：
  - `state.md` 之前仍停留在 `rehearsals.mental.last=closed`，与 `journal.md` 已记录的“第 2 轮为 anomaly 轮”不一致。
  - `plan.md` 的 README 处置清单还缺逐段映射表；Cursor 默认路径也仍未明确成唯一首选，`Quickstart` 落点未强制三项信息同落点出现。
- 处置：已更新 `state.md`，把 `mental.runs=3`、`last=anomaly` 与 `completed_rounds.mental=1` 对齐；已在 `plan.md` 中补入“现有 README 逐段映射表”、唯一 Cursor 默认路径与同一 `Quickstart` 落点要求；下一步继续重跑第 2 轮 mental，并补发网络中断的试用护栏重跑。
- 依据/来源：后台子 agent “README实现风险预演2A重跑”“README试用流预演2C再重跑” 返回结果 + 主 agent 对 `state.md/journal.md/plan.md` 的复核。

## 2026-06-04 08:46 · [推演 MENTAL_REHEARSAL]
- 背景：在补齐实现护栏、措辞护栏与试用护栏后，重新并行派出 3 个只读子 agent 验证这些护栏本身是否已闭环。
- 内容：
  - README 实现护栏预演：`LOGIC_CLOSED`
  - README 措辞护栏预演：`LOGIC_CLOSED`
  - README 试用护栏预演：`LOGIC_CLOSED`
- 处置：已写入 `rehearsals/mental-4.md`；将该轮计为一轮有效 `mental` 通过，`autonomy.completed_rounds.mental=2`，并继续进入第 3 轮 `mental`。
- 依据/来源：后台子 agent “README实现护栏预演2A重跑”“README措辞护栏预演2B重跑”“README试用护栏预演2C重发” 返回结果。

## 2026-06-04 08:50 · [异常 MENTAL_REHEARSAL]
- 背景：第 3 轮 mental 已返回两组有效 anomaly，分别针对“首次访客的瞬时可懂性”与“主句/Why 段、Quickstart 仍可能滑向软口号或双选题”。
- 内容（已核实成立）：
  - 前两屏虽然已有微对比与闭环图位置约束，但还缺“闭环图必须配白话解释”“微对比必须在前两屏就给出”的硬门槛。
  - 标题下副文、首屏主句、`Why` 段此前没有同等级句级锚点约束；`Quickstart` 也还缺“同一落点内允许两个极短子块，各自完整三件套”的明确格式。
- 处置：已继续修订 `prd.md` / `tests.md` / `plan.md`，补入微对比、闭环图白话解释、主句/Why 句级锚点、`Quickstart` 双子块同落点与 Cursor caveat 前置规则；待第 3 轮剩余结果全部返回后，再统一判定本轮是否记为 anomaly 并重跑。
- 依据/来源：后台子 agent “README最终压力预演3A”“README试用压力预演3C”“README对比压力预演3B重发” 的已返回部分 + 主 agent 对文档的复核。

## 2026-06-04 10:03 · [异常 MENTAL_REHEARSAL]
- 背景：`/sandtable-resume` 以 autopilot 续跑后，主 agent 重新并行派出 3 个只读子 agent 补齐第 3 轮 mental 的剩余判定。
- 内容（已核实成立）：
  - 3 个子 agent 全部指向同一处文档级冲突：`prd.md` 中 `FR6` 残留了两版互相矛盾的 Cursor 默认试用路径，一版要求默认走“让 AI 读 INSTALL.md 并自助安装”，另一版又把默认写成手工拷 `.cursor/`。
  - `tests.md` 当时只写“Cursor 不能变成双选题”，但没有把唯一默认路径具体写死；这会让实现者无法从 `prd.md/tests.md/plan.md` 唯一推出 `Quickstart` 的 Cursor 子块应该采用哪条默认路径。
  - 同一冲突也让“前两屏单跳到同一个 Quickstart”这条护栏存在上游口径漂移空间。
- 处置：已按既有 `journal.md` 与 `plan.md` 的记录收口为唯一决策：Cursor 默认仍是“让 AI 读 `INSTALL.md` 并自助安装”，手工拷 `.cursor/` 只作为备选可靠路径；并同步修订 `prd.md`、`tests.md` 与 `state.md`，把本轮记为 anomaly 轮后立即重跑第 3 轮 mental。
- 依据/来源：子 agent “首页理解压力预演”“文案锚点压力预演”“试用路径压力预演” 返回结果 + 主 agent 对 `prd.md/tests.md/plan.md/journal.md` 的复核。

## 2026-06-04 10:04 · [异常 MENTAL_REHEARSAL]
- 背景：修正 `FR6` 后重跑第 3 轮 mental，3 个只读子 agent 中仍有 1 个返回 anomaly；主 agent 对分歧点进行复核。
- 内容（已核实成立）：
  - `plan.md` 的 README 骨架把“微对比 + 两个短锚点”放进了“首屏只允许落入 1-7”的范围，但 `prd.md` / `tests.md` 的硬约束一直是“首屏只允许标题、1 句副文、`<=5` 条记忆点和 1 条试用入口摘要”，闭环图、微对比和短锚点应紧随其后、但不应回挤进首屏。
  - 这会让执行者在不违背 `plan.md` 字面的情况下，把本应属于前两屏后半段的元素塞进首屏，破坏前两屏优先级。
- 处置：已修订 `plan.md`：把首屏允许范围明确收紧为 `1-4`，并新增“`5-7` 必须紧接首屏出现、但不得回挤进首屏”的硬约束；同时更新 `state.md`，把本轮继续记为 anomaly 轮后再次重跑第 3 轮 mental。
- 依据/来源：子 agent “首页理解复核预演” 返回结果 + 主 agent 对 `plan.md` / `prd.md` / `tests.md` 的复核。

## 2026-06-04 10:05 · [推演 MENTAL_REHEARSAL]
- 背景：在收口 `FR6` 互斥版本与 `plan.md` 首屏边界冲突后，主 agent 再次并行派出 3 个只读子 agent，重跑第 3 轮 mental。
- 内容：
  - 首页理解终复核：`LOGIC_CLOSED`
  - 文案锚点终复核：`LOGIC_CLOSED`
  - 试用路径终复核：`LOGIC_CLOSED`
- 处置：已写入 `rehearsals/mental-7.md`；将该轮计为一轮有效 `mental` 通过，`autonomy.completed_rounds.mental=3`，autopilot 的 mental 配额现已补满，下一步进入 `REDTEAM`。
- 依据/来源：子 agent “首页理解终复核”“文案锚点终复核”“试用路径终复核” 返回结果。

## 2026-06-04 10:06 · [对抗 REDTEAM]
- 背景：autopilot 在 mental 配额补满后，按计划本身发起第 1 轮红蓝对抗，分别攻击前两屏优先级/预算、`superpowers` 事实边界、以及试用链路默认路径。
- 内容（已核实成立）：
  - `plan.md` 仍把 `Quickstart`、`命令入口` 与旧“安装 / 接入”映射成可能分裂的试用信息来源，存在“前两屏锚点跳到一处、第一条命令落在另一处”的可复现失败路径。
  - `plan.md` 的 section 预算总和先天超过 `160` 行硬上限，执行者即使逐块都压在上限内，也会天然超线。
  - `superpowers` 的两句制与作用域只强约束了正式对比区块，没有把 `Why` 等其它 section 里可能夹带的新比较句一并封死。
  - Cursor 默认路径虽然已指定为“让 AI 读 INSTALL.md 并自助安装”，但 README 级护栏还没把“重载窗口/重开工作区，使 `alwaysApply` 生效”写成 `Quickstart` 的强制接入动作，存在“README 合法过审，用户路径仍未真正接通”的风险。
- 处置：已把这些 breach 统一回写到 `prd.md` / `tests.md` / `plan.md`：把 `Quickstart` 收紧为唯一试用落点、重算 section 预算到 `<=160`、限制全文 `superpowers` 比较句只能出现在合法两处、并把 Cursor 的重载窗口动作前置进 `Quickstart`。按 autopilot 回退规则，当前从 `REDTEAM` 回退到 `MENTAL_REHEARSAL` 重新验证这些修正。
- 依据/来源：红军子 agent “红军进攻：首页优先级”“红军进攻：对比事实边界”“红军进攻：试用链路默认路径” 返回结果 + 主 agent 对 `prd.md/tests.md/plan.md/INSTALL.md` 的复核。

## 2026-06-04 10:07 · [推演 MENTAL_REHEARSAL]
- 背景：redteam 第 1 轮攻破后的修正已回写，主 agent 从 `MENTAL_REHEARSAL` 重新并行派出 3 个只读子 agent，验证本轮回退修正是否已经闭环。
- 内容：
  - 修正后 mental：首页路径：`LOGIC_CLOSED`
  - 修正后 mental：对比边界：`LOGIC_CLOSED`
  - 修正后 mental：Cursor 默认路径：`LOGIC_CLOSED`
- 处置：已写入 `rehearsals/mental-8.md`；将这轮记为 redteam 回退后的第 1 轮有效 `mental` 通过，`autonomy.completed_rounds.mental=1`。下一步继续补满剩余 2 轮 mental，再重新进入 `REDTEAM`。
- 依据/来源：子 agent “修正后 mental：首页路径”“修正后 mental：对比边界”“修正后 mental：Cursor 默认路径” 返回结果。

## 2026-06-04 10:25 · [集成 INTEGRATE]
- 背景：开发者显式执行 `/sandtable-live 直接实现吧`，要求跳过剩余 autopilot 配额与实现预演 worktree，直接在主工作区落 README 成稿。
- 内容：
  - 已按当前 `prd.md` / `tests.md` / `plan.md` 的收敛版本，直接重写 `README.md` 首页信息架构。
  - 新版 README 已落入“首屏价值主张 + 核心记忆点 + 试用入口摘要 + 闭环图 + 微对比 + Why + 正式对比 + 自举证明 + 单一 Quickstart + 命令入口 + 压缩目录/底线”结构。
  - 已把 Cursor 默认路径写成唯一首选，并在 `Quickstart` 中显式写出“重载窗口/重开工作区，使 `alwaysApply` 生效”；`superpowers` 比较句只保留在前两屏微对比与正式对比区块。
  - 主 agent 已完成初步验收：README 当前约 110 行、`ReadLints` 无报错、关键 token 与 section 已存在。
- 处置：因这是开发者显式手动覆盖，已把 `state.md` 的 `autonomy.mode` 切回 `manual`，并把阶段转到 `VERIFY`；后续若继续推进，应基于成稿做最终人工审读，或再发起一轮针对成稿的红队/实现复盘。
- 依据/来源：开发者本轮 `/sandtable-live 直接实现吧` 指令 + 主 agent 对 `README.md` 的实现与核对。

## 2026-06-04 10:29 · [对抗 REDTEAM]
- 背景：开发者显式执行 `/sandtable-redteam`，本轮按 `state.md` 直接判定为“打实现”，针对当前 `README.md` 成稿发起实现级红蓝对抗。
- 内容（已核实成立）：
  - 正式 `Sandtable vs Superpowers` 对比区块前置过深，打破“前两屏只留 1 条微对比、完整对比应下沉”的约束。
  - 首屏第一条记忆点把 `MENTAL_REHEARSAL`、`REDTEAM`、`IMPL_REHEARSAL` 三个名词并列塞进同一 bullet，退化成名词墙。
  - 正式对比区块的第二句存在一句多锚点/多解释，违反“每句一个具体名词锚点”的红线。
  - 首屏“立刻试用”摘要没有直接给出第一条命令，只承诺跳到 `Quickstart` 后再看，属于弱锚点。
- 处置：已写入 `rehearsals/redteam-2.md`，并把 `state.md` 记为实现级 `redteam` breach。当前 README 未通过这轮红队；下一步可由开发者决定是立刻修 README 后重打，还是先保留战报。
- 依据/来源：红军子 agent “红军进攻：首屏优先级”“红军进攻：对比红线”“红军进攻：试用链路回归” 返回结果 + 主 agent 对 `README.md/prd.md/tests.md` 的复核。

## 2026-06-04 10:29 · [对抗 REDTEAM]
- 背景：开发者随后明确选择“立即修 README，并在修完后再打一轮实现级 redteam”，主 agent 继续在主工作区修复 `redteam-2` 的实现级 breach，并按相同攻击向量做复打。
- 内容：
  - 已修复并复打通过的点：正式对比区块下沉、首屏记忆点拆成单能力单结果、首屏试用摘要直接给出 `/sandtable-start`、Cursor 顺序改为“安装 -> 重载窗口 -> 第一条命令”、流程图恢复 `EVALUATE -> INTEGRATE -> VERIFY -> DONE`、异常闭环补回“主 agent 核实 -> 给方案；必要时问开发者 -> 修正 -> 重演”、本地插件试用途径补上“在 Sandtable 仓库根执行”的语境。
  - 红军对 `superpowers` 位置/句型、Cursor 本地插件语境、以及异常闭环表达的最终定点复打均返回 `HELD`。
- 处置：已写入 `rehearsals/redteam-3.md`；当前 `README.md` 已扛住这轮实现级红队复打，状态可继续停留在 `VERIFY`。
- 依据/来源：开发者对“fix_now”的明确选择 + 复打红军子 agent “终局红军：对比句法”“终局红军：手工安装备选”“终局红军：异常闭环最终复核” 返回结果。

## 2026-06-04 10:50 · [验证 VERIFY]
- 背景：开发者进一步指出仓库并没有实际上线 `Claude Code marketplace`，且 README 无需继续保留 `Cursor` 分栏，建议改成一句话交给自己的 AI 自动接入。
- 内容：
  - 已复核确认：`README.md` 里的 `Claude Code marketplace` 安装说法与仓库现状不符；而 `INSTALL.md` 已具备跨 harness 可复用的 AI 安装指令。
  - 已将 README 的默认试用路径统一收敛为“把一句安装指令发给 AI，让它阅读 `INSTALL.md` 并安装到当前项目”，并把 `Quickstart` 改成统一三件套：安装指令、安装后接线动作说明、第一条命令。
  - 已同步移除 README 中的 `Claude Code` / `Cursor` 分栏展开，并把 `INSTALL.md` 末尾残留的插件市场引用改成新的 AI 快速接入提示。
  - 已同步修订本 feature 的 `prd.md` / `tests.md` / `plan.md` / `state.md`，把默认路径约束收口为统一 AI 快速接入，不再要求首页保留不存在的 marketplace 说法或 Cursor 分栏。
- 处置：当前 README 继续停留在 `VERIFY`，等待主 agent 做最终核对。
- 依据/来源：开发者本轮关于安装路径的明确反馈 + 主 agent 对 `README.md` / `INSTALL.md` 的复核与回写。

## 2026-06-04 10:54 · [验证 VERIFY]
- 背景：开发者继续指出 README 首屏 5 条记忆点里对 `/sandtable-autopilot` 的强调过重，Sandtable 的首页特点应更偏向“推演闭环 + 自我完善”。
- 内容：
  - 已把首屏记忆点中的 `/sandtable-autopilot` 条目改写为“推演会反过来改进方法论”，强调每轮异常/攻破都会回写 `docs/sandtable/`，让仓库随着演练一起收紧。
  - 已同步修订本 feature 的 `prd.md` / `tests.md` / `plan.md` / `state.md`，把前置记忆点从“autopilot”收口为“推演驱动的自我完善”，避免 README 与验收口径继续冲突。
- 处置：README 继续停留在 `VERIFY`；当前首页前置重心已从“自动推进能力”收回到“推演闭环 + 自举完善”。
- 依据/来源：开发者本轮关于首页记忆点权重的明确反馈 + 主 agent 对 `README.md` 与 feature 文档的回写。
