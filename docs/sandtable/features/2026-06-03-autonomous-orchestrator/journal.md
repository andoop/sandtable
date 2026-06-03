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
