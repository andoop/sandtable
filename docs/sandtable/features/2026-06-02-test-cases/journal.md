# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/预演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-02 07:14 · [受领任务 INTAKE]
- 背景：开发者希望在 Sandtable 流程里，PRD/plan 之外增加一份"真实测试用例"产物，用来检验 AI 对需求的理解是否完善（人也能看），并让后续头脑预演/实现预演有更具体的"操作指南和突破点"；测试用例像 PRD/plan 一样持续完善修正。开发者明确要求：①给出详细计划 ②客观评价是否值得做。
- 内容：原始需求记录如上。建立 feature 工作区 `2026-06-02-test-cases`。
- 依据/来源：开发者 2026-06-02 /sandtable-start 指令原文。

## 2026-06-02 07:14 · [情报侦察 RECON]
- 背景：在定目标前，把方法论现状摸清，重点判断"测试用例"与现有产物是否重复、该插在哪。
- 内容（已确认事实，标来源）：
  - PRD 模板已有"§5 验收标准（成功定义，可验证）"，但其形态是条件式 checkbox（`templates/prd.md:18-20`、`docs/.../easy-install/prd.md:24-29` 实例多为"JSON 合法""命名自洽"这类抽象判定），不是带"具体输入→预期输出/Given-When-Then"的场景化用例。
  - plan 采用 TDD 任务：先写失败测试→跑→实现→通过（`skills/writing-plan/SKILL.md:34-46`、`templates/plan.md:23-33`）。这些是代码级测试，依附于具体任务/技术栈。
  - 三类推演的 prompt 已引用"PRD 验收标准"，但没有"逐条测试用例"作为统一突破点（`skills/mental-rehearsal/mental-rehearsal-prompt.md:16-17`、`skills/implementation-rehearsal/implementation-rehearsal-prompt.md:19-20`、`skills/red-team-wargame/opfor-prompt.md:17-18`）。
  - VERIFY 阶段=跑测试/验收（`skills/using-sandtable/SKILL.md:67`），目前无显式"逐条测试用例通过"的对账物。
  - 状态机 phase 枚举、init 脚本拷贝的 5 个 feature 模板、README 目录结构、AGENTS/CLAUDE/.cursor 规则均未含"测试用例"概念（`skills/state-and-memory/SKILL.md:13-27`、`scripts/sandtable-init.sh:83`、`README.md:110-116`）。
  - 全局红线：脚本零依赖、内容单一来源于 templates、不覆盖用户文件、不擅改 skill 已调校文本（除非本需求明确要求）（`docs/sandtable/constraints.md`）。
- 缺口判断：现有"验收标准"是抽象判定条件，缺一份"具体、场景化、人可一眼看懂"的测试用例，无法很好地承担"检验 AI 理解"这一新职责。这正是开发者点出的空白。
- 依据/来源：见上各 file:line。
- 待澄清：见 questions.md（产物形态/是否新增 phase/语言/推演 prompt 改造范围）。

## 2026-06-02 07:20 · [决策 OBJECTIVES]
- 背景：就 4 个设计分叉向开发者拍板。
- 内容：
  - Q1=C：新增一等公民产物 `tests.md` + 新技能 `writing-tests` + 状态机在 OBJECTIVES 与 PLAN 之间加 phase `TESTCASES`；不新增独立 slash 命令（由 /sandtable-start 编排 + /sandtable-objectives 产出 + /sandtable-refine 迭代）。
  - Q2=A：测试用例为纯黑盒 Given-When-Then，技术栈无关、人可读。
  - Q3=接受为 MUST：每条用例必须可追溯映射回某条 FR/验收标准，否则不写（防与 PRD §5 / plan TDD 重复）。
  - Q4=三类推演都注入：mental/impl/redteam 三个 prompt 均把 tests.md 逐条用例作为统一"突破点/对账点"。
- 依据/来源：开发者 2026-06-02 AskQuestion 答复。
- 客观评价结论：值得做（补"检验 AI 理解"的真实空白 + 给推演统一突破点）；关键风险=三产物重复，已用 Q3 映射硬约束化解。
- CLAUDE.md 为 AGENTS.md 的软链（`ls -la` 确认），改 AGENTS.md 即覆盖两者。

## 2026-06-02 07:22 · [计划 PLAN]
- 背景：依据已确认目标产出 PRD + tests.md + plan.md。
- 内容：PRD 列 FR1-FR6；tests.md 自举写出 TC1-TC8（黑盒、逐条映射回 FR）；plan 拆 T1-T9（建模板/建技能/改脚本/插 phase/skills 衔接/三类推演注入/命令双副本/全局计数/整体验证）。状态机序列三种写法已核对（README/AGENTS 缩写式、.cursor/rules 中文全称式、state 枚举式），TESTCASES 统一插在 OBJECTIVES 与 PLAN 之间。
- 依据/来源：grep 核对 6 处序列位置（README.md:23、AGENTS.md:22、.cursor/rules/sandtable.mdc:22、state-and-memory:38、templates/state.md:3、using-sandtable:44）。
- 下一步：开发者确认 PRD/tests/plan → 头脑预演。

## 2026-06-02 07:35 · [预演+异常 MENTAL_REHEARSAL]
- 背景：并行派 3 个只读头脑预演子 agent（状态机一致性/防重复边界/机制）。
- 内容：
  - mental-3（机制）=LOGIC_CLOSED：init 幂等覆盖 tests.md、无占位误伤、prompt 注入不破坏结构、红线未违反。
  - mental-1（状态机一致性）=ANOMALY，已亲自核实属实：①objectives 命令 :16 写死 phase=PLAN 与新路由冲突 ②writing-prd 内部 :15/:28-32 旧路由未改 ③plan/resume/refine/rehearse 四命令、AGENTS:43、.cursor/rules:36、using-sandtable:61/70/88、README:58、state-and-memory:64 等副本遗漏 ④T4 恢复流程锚点不存在 ⑤TC3 锚点(OBJECTIVES) 在 README/AGENTS(用 PRD) 不满足。
  - mental-2（防重复）=ANOMALY，已核实属实且属方法论级：A1 映射源措辞(FR/验收) 与自举(MUST/MUST NOT)矛盾；A2 元需求下 §5 已 operational 使 tests.md ≈ §5 1:1，价值立论需重定位；A3 plan 验证≈tests.md 第三重叠；A6 双清单审阅 UX 无应对；A4/A5 自举覆盖缺口。
- 依据/来源：核实 sandtable-objectives.md:16、sandtable-plan.md:8、sandtable-resume.md:12、sandtable-refine.md:9-11、sandtable-rehearse.md:8-16；prd.md:40 vs tests.md 映射字段。
- 处置：机制类遗漏直接扩计划（无须开发者）；A1/A2/A6/TC3 属设计决策，向开发者提 Q5-Q7。phase 回退 PLAN，blocked=true。

## 2026-06-02 07:45 · [决策+修正 PLAN]
- 背景：开发者就 Q5-Q7 拍板。
- 内容：Q5=B（§5 只写抽象成功定义，具体可演练场景含可执行检查下沉 tests.md，plan 验证引用 TC 编号）；Q6=映射源扩为 FR/验收/MUST/MUST NOT；Q7=加审阅指引（tests.md 理解闸门先读、§5 完成闸门）。据此 + mental-1 遗漏统一修订：PRD 新增 FR7、§5 改抽象、FR2/FR6 扩写；tests.md 重映射 + 补 TC9 命名/双副本 + TC4 含 frontmatter + TC3/TC6 放宽/收紧；plan 扩 T4（6 权威副本，修恢复锚点为 resume 命令承载）、T5（writing-prd 内部三处路由 + §5 重定位 + templates/prd.md）、T7（6 命令双副本含 objectives 路由修正）、T9（引用 TC 编号）、T1/T2（映射源 + 边界 + UX）、T3（注释 5→6）。
- 依据/来源：questions.md Q5-Q7；rehearsals/mental-1.md、mental-2.md。
- 下一步：重跑头脑预演两条异常链验证闭环。

## 2026-06-02 07:55 · [预演重演+异常 MENTAL_REHEARSAL 轮2]
- 背景：重跑状态机一致性头脑预演（防重复那条因网络中断，待重派）。
- 内容：重演确认上轮 6 异常在计划层已覆盖、无假锚点、双副本同源成立；但又揪出更细遗漏：①using-sandtable:88 异常写回清单仅 prd/plan ②being-truthful:44 同 ③commands/sandtable-mental :8/:10 读取与修正清单无 tests ④sandtable-rehearse:10 修正行 ⑤frontmatter 描述：sandtable-start:2、writing-prd:3、writing-plan:3 走旧序列。已亲自核实（grep + 读）全部属实。
- 处置：新增计划任务 T10 统一清扫上述写回清单/命令/frontmatter；扩 TC6 覆盖"写回清单含 tests.md"。phase 仍 MENTAL_REHEARSAL，再重演。
- 依据/来源：grep 命中 using-sandtable:88、being-truthful:44、sandtable-mental:10、sandtable-rehearse:10、sandtable-start:2、writing-prd:3、writing-plan:3。

## 2026-06-02 08:00 · [预演收尾 MENTAL_REHEARSAL closed]
- 背景：轮3两个子 agent 耗时过长被中断；改由主 agent 亲自全仓 grep 审计（符合"亲自核实"原则）。
- 内容：grep 穷举所有"序列/写回/路由/产物清单/frontmatter"位置，逐条对照计划：全部被 T4/T5/T7/T8/T10 覆盖，无遗漏（live/debrief 泛指"计划"有意保留）。防重复链：TC1-9 映射全落 {FR/验收/MUST/MUST NOT}，§5 已纯抽象无 grep/bash，三处边界一致，覆盖缺口已补。判 LOGIC_CLOSED，报告 rehearsals/mental-5.md。
- 处置：mental.runs=3 last=closed。下一步交开发者选 redteam / 实现预演 / 停在计划。
- 备注：子 agent 长跑两次被用户中断，后续推演宜更聚焦、分小批派发。

## 2026-06-02 08:30 · [实现预演+集成 IMPL_REHEARSAL→INTEGRATE→DONE]
- 背景：开发者选直接实现预演（跳过 redteam）。隔离 worktree ../sandtable-rehearsal-1 / 分支 sandtable/rehearse/test-cases-1。
- 内容：实现子 agent 跑约 20 分钟（验证阶段被中断），但已 7 commit 完整实现 T1-T10、工作树干净。主 agent 亲自复核 TC1-TC9：全绿（见 rehearsals/impl-1-test-cases.md）。集成方式：从分支 `git checkout -- <源码路径>` 取入主仓 master，保留主仓更新的 feature 文档；与文档一并提交。
- 依据/来源：worktree git log 7 提交；主仓 grep/json/bash 复核；diff --stat 确认外科手术式（being-truthful 仅写回行；mental/redteam/impl 三 SKILL 正文未动）。
- 残余：worktree/分支待清理。
