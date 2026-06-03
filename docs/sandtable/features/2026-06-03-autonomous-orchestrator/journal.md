# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/推演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-03 08:19 · [受领任务 INTAKE]
- 背景：开发者要求执行 `/sandtable-plan`，为“做一个自动完成目标、不需要人干预、完全由 AI 自主决定的自动化流程”制定完整计划；并明确最低推演配额：至少三轮头脑预演（每轮至少三个子 agent）、至少三次红蓝对抗（每轮至少三个子 agent）、至少两轮真实推演（每轮两个子 agent）。
- 内容：建立 feature 工作区 `2026-06-03-autonomous-orchestrator`，把需求定位为“Sandtable 的全自动编排入口”。
- 依据/来源：开发者 2026-06-03 `/sandtable-plan` 指令原文。

## 2026-06-03 08:24 · [情报侦察 RECON]
- 背景：先核实现有命令/skill/状态结构能做到什么，缺口在哪。
- 内容（已确认事实）：
  - `/sandtable-start` 只编排到 `PLAN` 后提示用户继续（`commands/sandtable-start.md:7-14`）。
  - `/sandtable-rehearse` 只串一轮 mental/redteam/impl/debrief，没有最低轮次或每轮最少子 agent 数（`commands/sandtable-rehearse.md:7-19`）。
  - `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 都默认把下一步交回用户决定（`commands/sandtable-mental.md:7-11`、`commands/sandtable-redteam.md:7-13`、`commands/sandtable-live.md:7-11`）。
  - 三类推演 skill 支持并行多个子 agent，但没有 `3x3 / 3x3 / 2x2` 的最低配额（`skills/mental-rehearsal/SKILL.md:20-21`、`skills/red-team-wargame/SKILL.md:20-32`、`skills/implementation-rehearsal/SKILL.md:12-17`）。
  - `state.md` 模板只存汇总 runs/last，不足以恢复自动模式轮次与自动决策（`templates/state.md:1-18`、`skills/state-and-memory/SKILL.md:32-66`）。
  - plugin manifest 按目录装载 skills/commands，新增文件无需改 manifest（`.claude-plugin/plugin.json:21-23`、`.cursor-plugin/plugin.json:15-17`）。
- 依据/来源：见上各 file:line。

## 2026-06-03 08:29 · [决策 OBJECTIVES]
- 背景：基于侦察结果选择实现路线。
- 内容：
  - 方案对比：A=扩 `/sandtable-rehearse`；B=新增 `/sandtable-autopilot` + `autonomous-orchestration`；C=外部脚本。判定 B 最符合现有 “commands + skills + state” 架构。
  - 明确范围：新增全自动入口、状态字段与全局索引；保留现有手动命令，不新增仓外运行器。
  - 明确红线：最低配额必须硬落地为 `mental 3x3 / redteam 3x3 / impl 2x2`；只有真正阻塞才问开发者。
- 依据/来源：侦察结论 + 开发者原始要求。

## 2026-06-03 08:33 · [测试用例 TESTCASES]
- 背景：把“全自主自动编排”具体化为黑盒场景，作为理解闸门。
- 内容：写出 TC1-TC8，覆盖全流程入口、默认不逐步等人、三类推演最低配额、状态可恢复、阻塞与异常分流、全仓索引自洽。
- 依据/来源：`tests.md` 当前版本。

## 2026-06-03 08:38 · [计划 PLAN]
- 背景：在 PRD 与 tests 基础上拆改动计划。
- 内容：产出 T1-T6 六个任务，文件地图覆盖新 skill、新命令、state 扩展、status/resume、using-sandtable/start/rehearse、README/AGENTS/rules/project 与最终回归验证；所有验证步骤均引用 TC1-TC8。
- 依据/来源：`plan.md` 当前版本。

## 2026-06-03 08:45 · [预演+异常 MENTAL_REHEARSAL 轮1]
- 背景：按 `sandtable-mental` 并行派出 3 个只读子 agent，分别审查“自动入口与阶段闭环”“状态持久化与恢复”“全仓索引与手动入口边界”。
- 内容：
  - anomaly-1（已核实成立）：`/sandtable-autopilot` 的计划文案未把 frontmatter `description` 收束到核心语义；同时 `/sandtable-start` 只准备在末尾补一句提示，但未消除其现有“编排全流程/到预演”为止的描述，职责边界不清。
  - anomaly-2（已核实成立）：T3 只设计了 `autonomy.*` 字段与读取方，没有闭合“进入 autopilot / 自动推进 / 回退重演时谁来写 `last_decision`”；`commands/sandtable-resume.md` 现有“等我确认后继续”语义也必须显式改写，不能只追加 autopilot 分支意图。
  - anomaly-3（已核实成立）：T5 只覆盖 README 命令表，没有覆盖 README 目录结构里逐项枚举的 `skills/` 清单；若新增 `autonomous-orchestration` 但不更新目录结构，会违反 FR8 / TC8。
- 处置：已直接修订 `prd.md/tests.md/plan.md/state.md`：① `FR6` 与 `TC6` 改为以 `autonomy.mode` 为唯一权威开关，并要求每次自动推进/回退写 `last_decision`；② T1/T3 明确写回责任与 `/sandtable-resume` 的 manual/autopilot 分支；③ T4 把 `/sandtable-start` 改为真正收束到“前五步入口”；④ T5 补 README 目录结构同步；⑤ state 保持 `MENTAL_REHEARSAL`，准备重演。
- 依据/来源：`commands/sandtable-start.md:2-14`、`commands/sandtable-resume.md:7-13`、`README.md:81-105`、3 个 mental 子 agent 报告。

## 2026-06-03 08:52 · [预演+异常 MENTAL_REHEARSAL 轮3]
- 背景：继续做第 3 轮头脑预演，改用更窄的检查面审查“配额硬门槛 / phase 与恢复语义 / 越界风险”。其中一名子 agent 成功返回并指出恢复语义缺口，其余两个子 agent 因网络中断未返回。
- 内容（已核实成立）：
  - anomaly-4：PRD 写“回到受影响的最早阶段重演”，但未具体定义判定规则；同时 journal 上轮处置写“state 保持 `MENTAL_REHEARSAL`”，与字面上的“回到 PLAN”可能冲突。
  - anomaly-5：`BLOCKED` 同时出现在 FR4 的“修正后重演”和 FR5 的“真正阻塞停下问人”两条路径中，缺少主 agent 分类规则。
  - anomaly-6：自动流程要求持续更新 `autonomy.last_decision`，但没有显式要求每次自动推进/回退同步更新 `state.md.phase`，会让 resume/status 的恢复语义出现错位。
- 处置：已直接修订 `prd.md/tests.md/plan.md/state.md`：① 把 FR4 改为“回到最早尚未重新验证的阶段”，并写出 mental/redteam/impl 三类回退规则；② 把 FR5 改为“`BLOCKED` 先分类，只有外部依赖才升级为 `blocked=true`”；③ T1/T3 增加 `phase` 同步写回、`BLOCKED` 裁决表与 `phase`/`last_decision` 权威关系；④ TC6/TC7 同步覆盖 `phase` 同步与 `BLOCKED` 分流。
- 依据/来源：`prd.md:44-46`、`plan.md:61-74,150-159`、`journal.md:39-45`、成功返回的第 3 轮 mental 子 agent 报告。

## 2026-06-03 19:23 · [预演+异常 MENTAL_REHEARSAL 轮4]
- 背景：恢复当前需求后重新执行 `/sandtable-mental`，并行派出 3 个只读子 agent，分别复核“自动入口与配额闭环”“状态持久化与恢复”“全局索引与入口边界”；随后围绕修补后的文档又做了多轮窄口径重演。
- 内容（已核实成立）：
  - anomaly-7：`autopilot` 的“全新需求 vs 已有 feature 续接”语义不够明确，早期计划会把进行中的需求无条件打回 `RECON`。
  - anomaly-8：`autonomy.completed_rounds` 的回卷规则、与 `rehearsals.*.runs` 的分工、以及 resume/status 的权威关系一度不够可执行。
  - anomaly-9：autopilot 想覆盖“不要逐步等人确认”，但与 `writing-prd` / `writing-tests` 等 skill 及手动命令中的旧确认门槛缺少显式 override。
  - anomaly-10：README / AGENTS / Cursor rule / `commands` 对 start/rehearse 的旧表述若只追加 autopilot 而不收束，仍会与新入口冲突；TC8/T4/T5/T6 的验证口径也一度偏松。
- 处置：已直接修订 `prd.md` / `tests.md` / `plan.md`：① 明确 `INTAKE` 由 `state-and-memory` 建档/恢复，`RECON→PLAN` 显式沿用 `gathering-intel → writing-prd → writing-tests → writing-plan`；② 明确 `/sandtable-autopilot` 的显式触发是对前序流程的预授权，并要求在新 skill 中用 `<AUTOPILOT-OVERRIDE>` 覆盖手动命令与相关 skill 的旧确认门槛；③ 把前序流程回退改成“按被修正的最早产物映射到 `RECON/OBJECTIVES/TESTCASES/PLAN`”，把推演链回退改成“修正前序产物后统一回 `MENTAL_REHEARSAL` 并清零 `mental/redteam/impl` 的 `completed_rounds`”；④ 收紧 T4/T5/T6/TC8 的边界与验证口径，补入 README 命令表精确替换稿、`sandtable-rehearse` frontmatter 收束、`using-sandtable` 的 autopilot 例外说明，以及 `project.md` 计数对账要求。
- 结论：本轮 anomaly 已核实并完成文档修补，但最后一批修补后尚未再做新一轮 mental 复核，因此当前仍保持 `MENTAL_REHEARSAL`，待下轮只读重演确认这些修补已真正闭环。
- 依据/来源：本轮 3 组 mental 子 agent 报告；`skills/writing-prd/SKILL.md`、`skills/state-and-memory/SKILL.md`、`commands/sandtable-start.md`、`commands/sandtable-rehearse.md`、`README.md`、`AGENTS.md`、`.cursor/rules/sandtable.mdc` 的主 agent 抽查结论。

## 2026-06-03 19:38 · [预演+异常 MENTAL_REHEARSAL 轮5]
- 背景：在第 4 轮修补后继续执行 `/sandtable-mental`，再次并行派出只读子 agent，专门复核“前序预授权”“推演链回退”“TC8/T4/T5/T6 验证口径”。
- 内容（已核实成立）：
  - anomaly-11：`plan.md` 的局部条目仍残留旧口径，例如 T3 曾把 `completed_rounds` 清零条件写成“因修正前序产物回退到 `MENTAL_REHEARSAL`”，与 `prd.md` / `tests.md` / T1 已收紧的“凡进入推演链且需写回文档再重演即统一回 `MENTAL_REHEARSAL` 并清零”冲突。
  - anomaly-12：`FR3` 的“补足该阶段最低配额”与 `FR4` 的“推演链统一回 `MENTAL_REHEARSAL`”存在字面歧义，容易让执行者误读为 redteam/impl 只补本阶段。
  - anomaly-13：`<AUTOPILOT-OVERRIDE>` 的覆盖范围与验证顺序仍不够硬，需显式覆盖 `/sandtable-recon`、`/sandtable-plan`、`/sandtable-resume` 与全局初始化确认节点，并把 TC2 的验证后移到 override 段写入之后。
  - anomaly-14：TC8 / T5 / T6 仍存在“只因出现 autopilot 关键词就误判通过”的风险，且 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的保留未被纳入明确的文件存在性检查。
- 处置：已继续修订 `prd.md` / `tests.md` / `plan.md`：① 统一 FR3/FR4 关于推演链异常后的处理口径，并把 MUST 补成含 `INTAKE` 的完整前序流程；② TC2 补入全局 `project.md` / `constraints.md` 初始化例外，TC4 改成“回 `MENTAL_REHEARSAL` 后补足整条推演链”，TC8 升级为“正向 + 负向 + 文件存在性”三段式检查；③ T1/T3/T5/T6 同步修正：把 TC2 验证移到 `<AUTOPILOT-OVERRIDE>` 写入之后，统一 `completed_rounds` 清零条件，扩展负向 `rg` 模式，并加入 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的 `test -f` 存在性检查。
- 结论：本轮 anomaly 已核实并继续完成计划级修补，但最后一批修补后仍未重新派发新一轮只读子 agent 做确认，因此仍保持 `MENTAL_REHEARSAL`，等待下一轮 mental 复核。
- 依据/来源：本轮 5 组 mental 子 agent 报告；`prd.md`、`tests.md`、`plan.md` 的主 agent 抽查结论。

## 2026-06-03 19:51 · [预演+异常 MENTAL_REHEARSAL 轮6]
- 背景：继续执行 `/sandtable-mental`，缩小到两个窄口径方向复核：① `autopilot` 前序预授权与 `<AUTOPILOT-OVERRIDE>`；② `TC8 / T5 / T6` 的验证口径。
- 内容（已核实成立）：
  - anomaly-15：`TC8.When`、`T5`、`T6` 虽然都已具备正向/负向/存在性检查，但三者尚未完全对齐；执行者若只跑较弱的一套，仍可能出现“关键词命中即通过”的假阳性。
  - anomaly-16：start/rehearse 的边界命中条件与 `sandtable-mental` / `sandtable-redteam` / `sandtable-live` 的保留检查一度混在同一条 OR 模式里，导致边界收束可能被无关命中绕过。
  - anomaly-17：`只串` / `仅串起` / `可一键串起` 等表述尚未完全被同一套正向/负向规则收束，仍可能在 README / AGENTS / rule / command 文案里漏网。
- 处置：已继续修订 `tests.md` / `plan.md`：① 把 TC8 升级为更强的正向、负向、存在性组合检查，补入 `autonomous-orchestration/` 目录、`start/rehearse/autopilot` 与手动推演命令的存在性要求；② 让 `T6` 向 `TC8` / `T5` 的最强版本靠拢，补入更宽的负向词表；③ 统一把“前序入口 / 仅串推演+复盘 / 手动命令保留 / 计数对账”视为同一套验收面。
- 结论：本轮后，前序预授权与推演链回退规则已基本闭环；剩余 anomaly 已收敛为单一的“TC8 / T5 / T6 验收口径尚未完全对齐”问题。当前仍保持 `MENTAL_REHEARSAL`，待下一轮只读复核确认该验收口径彻底闭环。
- 依据/来源：本轮 3 组 mental 子 agent 报告；`prd.md`、`tests.md`、`plan.md` 的主 agent 抽查结论。

## 2026-06-03 20:00 · [预演通过 MENTAL_REHEARSAL 轮7]
- 背景：继续执行 `/sandtable-mental`，只针对第 6 轮遗留的 `TC8 / T4 / T5 / T6` 验收口径做最小范围修补与终检。
- 内容（已核实成立）：
  - 已把负向检查统一改成 `! rg`，并在 `tests.md` / `plan.md` 中明确“0 命中才通过”。
  - 已把 `/sandtable-rehearse` 的索引边界从弱匹配收紧为完整短语 `只串推演与复盘`，并补入命令正文的独立 `rg` 断言。
  - 已明确 `T4` 只是局部预检，完整 `TC8` 终验以 `T5/T6` 为准；`T6` 先复跑与 `TC8/T5` 同口径的完整索引终验，再追加全仓 smoke。
  - 已补齐 `串起三类推演与复盘` 等旧表述的负向词表，关闭最后的关键词漏网窗口。
- 结论：本轮并行只读子 agent 复核返回 `LOGIC_CLOSED`；主 agent 抽查确认 `prd.md` / `tests.md` / `plan.md` 在本需求剩余的计划级问题上已闭环。当前头脑预演阶段完成，可进入 `REDTEAM` 或 `IMPL_REHEARSAL`。
- 依据/来源：本轮 3 组 mental 子 agent 报告；`tests.md`、`plan.md`、`prd.md` 的主 agent 抽查结论。

## 2026-06-03 21:05 · [对抗+异常 REDTEAM 轮1]
- 背景：执行 `/sandtable-redteam`，按“打计划”并行派出多组 OPFOR，只攻击四类面：① autopilot override 与手动 slash 边界；② `completed_rounds` / `phase` / resume 的配额闭包；③ `using-sandtable` / README / AGENTS / rule / `state-and-memory` 的旧总入口与旧回退语义；④ `TC8 / T5 / T6` 的机械验收强度。
- 内容（已核实成立）：
  - breach-1：`<AUTOPILOT-OVERRIDE>` 若只写“autopilot 模式下覆盖旧确认门槛”，会静默削弱开发者显式触发的手动命令；已修订 `prd.md` / `tests.md` / `plan.md`，限定 override 只在本回合显式 `/sandtable-autopilot` 或 autopilot 版 `/sandtable-resume` 生效。
  - breach-2：`phase` 与 `completed_rounds` 的关系若只写“按当前阶段继续”，会让 autopilot 在已有 feature 上跳过 mental/redteam 缺口；已修订为“续接时先做配额闭包纠偏，再从最早未完成阶段继续”，并把 `phase` 明确降为记录位。
  - breach-3：manual `/sandtable-rehearse` / `/sandtable-mental` / `/sandtable-redteam` / `/sandtable-live` 留下的 `rehearsals/*.md`、`runs`、`last` 若不显式排除，可能被误算为 autopilot 已补轮；已把“不自动计入 `completed_rounds`，且后续也必须重新派满最低子 agent 数并重写报告”写入 `prd.md` / `tests.md` / `plan.md`。
  - breach-4：`TC8 / T5 / T6` 曾只对 `state-and-memory` 做弱负向扫雷；已补成“正向锚定 autopilot 回退分支 + 负向禁止旧回退简写与 `FIX -> OBJ` 变体”。
  - breach-5（仍成立，未完全收口）：尽管 `TC8 / T5 / T6` 已大幅增强，但整体仍主要依赖 `rg`；对“同义改写 + 脚注式合规 + 局部贴纸化正向命中”的语义绕过还不够硬，仍可能在不触发 denylist 的情况下保留旧总入口/旧回退心智。
- 处置：已直接修订 `prd.md` / `tests.md` / `plan.md`，并对“override 静默覆盖”“配额闭包优先于 `phase`”“手动报告偷算进 `completed_rounds`”三条杀招完成重打，结果 `HELD`。当前剩余问题只剩 `TC8/T5/T6` 仍偏 regex 驱动，需要下一轮继续决定是否引入更强的结构化断言或接受残余语义风险。
- 结论：redteam 第 1 轮确认存在真实 breach，但绝大多数已在轮内修补并复打通过；当前仍保留 1 条计划级 anomaly，`REDTEAM` 暂不闭环。
- 依据/来源：本轮 13 组 redteam 子 agent 报告；`prd.md`、`tests.md`、`plan.md`、`skills/using-sandtable/SKILL.md`、`skills/state-and-memory/SKILL.md`、`README.md`、`AGENTS.md`、`.cursor/rules/sandtable.mdc` 的主 agent 抽查结论。

## 2026-06-03 21:20 · [对抗通过 REDTEAM 轮2]
- 背景：继续执行 `/sandtable-redteam`，只攻击 redteam 第 1 轮遗留的 `breach-5`，即 `TC8 / T5 / T6` 对“同义改写 + 脚注式合规 + 非主段落复述旧心智”的防护是否仍可被打穿。
- 内容（已核实成立并完成修补）：
  - breach-5a：即使把 `state-and-memory` 从 `TC8` 挪回 `TC6 / T3`，`TC8 / T5 / T6` 若仍把 regex 当成主要终验，依然可能让 `核心入口` / `推演总控` / `一次串完` 这类同义句在非主索引段落漏网。已把 `TC8 / T5 / T6` 收紧为“正向断言 + `! rg` 负向 0 命中 + 文件存在性 + 人工语义审读”，并明确人工审读必须否决“同义改写 + 脚注式合规 + 非主段落复述旧心智”。
  - breach-5b：初版人工审读范围未覆盖 `skills/autonomous-orchestration/SKILL.md` 与 `/sandtable-autopilot` 命令正文，仍可在 autopilot 自身载体里把 `/sandtable-rehearse` 讲回旧总入口。已把 `skills/autonomous-orchestration/SKILL.md`、`commands/sandtable-autopilot.md`、`.cursor/commands/sandtable-autopilot.md` 一并纳入 `TC8 / T5 / T6` 的负向扫描与人工审读范围。
- 处置：已直接修订 `prd.md` / `tests.md` / `plan.md`，随后复打 OPFOR；复打结果 `HELD`，未再找到可在“按最新书面流程完整执行”前提下稳定通过的同类杀招。
- 结论：redteam 第 2 轮拿到 `HELD`；当前计划级红军攻击面已闭环，可转入 `IMPL_REHEARSAL`。
- 依据/来源：本轮 7 组 redteam 子 agent 报告；`prd.md`、`tests.md`、`plan.md`、`rehearsals/redteam-2.md` 的主 agent 抽查结论。

## 2026-06-03 21:35 · [实现预演+异常 IMPL_REHEARSAL 轮1]
- 背景：执行 `/sandtable-live`，并行派出 2 个隔离 worktree 子 agent，分别完整实现 `2026-06-03-autonomous-orchestrator`。两者都自报 `DONE`，随后主 agent 按 `evaluating-rehearsals` 要求抽查真实 diff 与关键文件。
- 内容（已核实成立）：
  - candidate-A（commit `f8ad2bb`）：`commands/.cursor/commands/sandtable-rehearse.md` 仍保留 `一键串起全部推演`，README / AGENTS / Cursor rule 仍残留 `总演习` / `总入口`，`skills/state-and-memory/SKILL.md` 仍保留过旧的回退描述，未满足 `TC6 / TC8`。
  - candidate-B（commit `aec6ed9`）：整体更接近目标，但 `skills/using-sandtable/SKILL.md` 仍写“只串起三类推演 + 复盘”，README / Cursor rule 仍残留 `总入口`，同样无法通过 `TC8`。
- 处置：未进入 `evaluating-rehearsals` 打分，因为这轮并非“全部真实 DONE”。已把两套候选分别写入 `rehearsals/impl-1-sandtable-autopilot-3f4a9c2d.md` 与 `rehearsals/impl-1-autopilot-impl-7c3a2f1b.md`，并将本轮实现预演裁定为 `ANOMALY_FOUND`。
- 结论：实现预演第 1 轮未闭环；当前问题不是计划缺口，而是实现未完全遵守 `TC6 / TC8` 的边界收束。保持 `IMPL_REHEARSAL`，等待修正后重演。
- 依据/来源：两份实现预演子 agent 报告；主 agent 对 worktree 提交 `f8ad2bb` / `aec6ed9` 的抽查结论。

## 2026-06-03 21:48 · [实现预演+异常 IMPL_REHEARSAL 轮2]
- 背景：按开发者确认，保持计划不变，直接重开第 2 轮实现预演，并在派发提示中显式纳入第 1 轮暴露的失败点（`rehearse` 旧 frontmatter、`using-sandtable` / README / rule 的旧入口语义、`state-and-memory` 的 autopilot 语义）。
- 内容（已核实成立）：
  - candidate-A2（commit `e118df5`）：大部分上一轮问题已修掉，但 `skills/using-sandtable/SKILL.md` 仍写“不是总入口”，在当前 `TC8 / T5 / T6` 的负向字面门禁下仍会触发 `总入口` 命中，不能视作真实 `DONE`。
  - candidate-B2（commit `e04b420`）：通过主 agent 的关键抽查，`rehearse` 边界、`using-sandtable`、README / rule 索引与 `state-and-memory` 的 autopilot 语义都已收束，可视为一个有效 `DONE` 候选。
- 处置：已把两套候选写入 `rehearsals/impl-2-autonomous-orchestrator-6f3a91c2.md` 与 `rehearsals/impl-2-autonomous-orchestrator-impl2-a1b2c3d4.md`。由于同轮仍存在 1 个 `ANOMALY_FOUND`，按 `evaluating-rehearsals` 的硬门禁，本轮暂不进入打分择优。
- 结论：实现预演第 2 轮仍未完全闭环，但已产出 1 个通过主 agent 抽查的有效候选。当前等待开发者决定：是接受“只有 1 个有效候选”并进入后续环节，还是继续补一个实现候选再择优。
- 依据/来源：两份第 2 轮实现预演子 agent 报告；主 agent 对 worktree 提交 `e118df5` / `e04b420` 的抽查结论。

## 2026-06-03 22:00 · [集成 INTEGRATE]
- 背景：开发者明确指令“你直接去实现了吧，基于 b2，然后你改对就行了”，覆盖了“至少 2 个有效候选再择优”的默认流程。
- 内容：主 agent 以 `rehearsals/impl-2-autonomous-orchestrator-impl2-a1b2c3d4.md` / commit `e04b420` 为基底，将其实现直接落到主工作区；同步新增 `/sandtable-autopilot` 与 `skills/autonomous-orchestration/SKILL.md`，扩展 `templates/state.md`、`state-and-memory`、`status/resume`、`start/rehearse` 与 README / AGENTS / Cursor rule / project 索引。
- 处置：已在主工作区完成关键终验：命令双副本一致、旧入口语义扫描通过、`autonomy.*` 与 `AUTOPILOT-OVERRIDE` 字段命中、相关文件无 lint 问题。
- 结论：本需求已按开发者指令直接进入 `INTEGRATE`；后续若继续严格走 Sandtable，可再做实现级 `/sandtable-redteam` 或 `/sandtable-debrief` / `VERIFY`。
- 依据/来源：开发者本轮明确选择；主 agent 对主工作区改动与本地校验结果的抽查结论。
