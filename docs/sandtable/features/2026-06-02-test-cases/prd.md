# 测试用例产物 tests.md · PRD

> 对应 project.md 北极星（方法论自举改进自身）/ 继承 constraints.md 红线。实现细节见 plan.md，具体用例见 tests.md。

## 1. 目标
在 Sandtable 流程里新增一份**一等公民产物 `tests.md`**（黑盒、场景化、人可读的测试用例），定位在 PRD 与 PLAN 之间，用来**检验 AI 对需求的理解是否完善**（人也能一眼看懂），并为三类推演提供统一的"突破点/对账点"。它像 PRD/plan 一样持续完善修正。这是方法论自身的增强。

## 2. 背景与现状（已确认事实，标来源）
- PRD 模板已有"§5 验收标准（成功定义，可验证）"，但形态是**抽象判定条件**（`templates/prd.md:18-20`；实例 `docs/.../easy-install/prd.md:24-29` 多为"JSON 合法""命名自洽"），能判"做完没"，难暴露"理解对不对"。
- plan 采用 TDD 代码级测试（`skills/writing-plan/SKILL.md:34-46`、`templates/plan.md:23-33`），依附具体任务/语言。
- 三类推演的 prompt 仅引用"PRD 验收标准"，缺逐条可对账的用例清单（`skills/mental-rehearsal/mental-rehearsal-prompt.md:16-17`、`skills/implementation-rehearsal/implementation-rehearsal-prompt.md:19-20`、`skills/red-team-wargame/opfor-prompt.md:17-18`）。
- 状态机 phase 枚举、init 脚本拷贝的 5 个 feature 模板、闭环图、技能索引、目录结构均无"测试用例"概念（`skills/state-and-memory/SKILL.md:13-52`、`scripts/sandtable-init.sh:83`、`skills/using-sandtable/SKILL.md:28-70`、`README.md:22-25,93-116`、`AGENTS.md`、`.cursor/rules/sandtable.mdc`）。
- `CLAUDE.md` 是 `AGENTS.md` 的软链（`ls -la` 确认），改 `AGENTS.md` 即覆盖两者。
- 全局红线：脚本零依赖、内容单一来源 templates、不覆盖用户文件、不擅改 skill 已调校文本（除非本需求明确要求）（`constraints.md`）。

## 3. 用户故事 / 场景
- 作为开发者，AI 写完 PRD/plan 后，我希望读一份**具体的测试用例**（输入→预期输出），一眼判断 AI 是否真理解了我要什么——比读抽象验收标准更能暴露理解偏差。
- 作为接手的另一个人/AI，我希望 `tests.md` 是与 PRD/plan 并列的事实地基，能据它续接。
- 作为推演子 agent，我希望拿到一份**逐条用例清单**作为统一突破点：头脑预演逐条推逻辑闭环、实现预演逐条跑通、红军逐条找反例。

## 4. 功能需求
- **FR1（新产物 + 模板）**：新增 `templates/tests.md`，定义黑盒测试用例的标准结构：用例编号、标题、映射字段（指向 FR/验收/MUST/MUST NOT）、前置(Given)、操作(When)、预期(Then 含具体输入与预期输出)、当前状态(待验证/已验证)。〔Q2=A 黑盒；开发者确认〕
- **FR2（新技能 writing-tests）**：新增 `skills/writing-tests/SKILL.md`，规定从已确认 PRD 派生测试用例：硬门禁=**每条用例必须映射回某条 FR / 验收标准 / MUST / MUST NOT**（防重复，Q6 扩展映射源）；含黑盒/技术栈无关/人可读要求、自查表、Red Flags；指明它是"检验 AI 理解"的闸门；写明三产物职责边界（见 FR7）。〔Q3 映射为 MUST + Q6；开发者确认〕
- **FR3（状态机新增 phase TESTCASES）**：在 `OBJECTIVES` 与 `PLAN` 之间新增 phase `TESTCASES`（军事隐喻：标定靶标），更新所有出现状态机序列/phase 枚举/闭环图的权威文本，保持各副本一致。不新增独立 slash 命令。〔Q1=C；开发者确认〕
- **FR4（脚手架）**：`scripts/sandtable-init.sh` 拷贝 feature 模板的列表加入 `tests.md`（5→6 个），同步更新脚本内"5 个模板"注释，保持幂等、不覆盖、零依赖、单一来源。
- **FR5（三类推演注入突破点）**：`mental-rehearsal-prompt.md`、`implementation-rehearsal-prompt.md`、`opfor-prompt.md` 各新增"待验证用例清单（来自 tests.md）"上下文块与对应工作要求（头脑预演逐条推闭环、实现预演逐条让 Then 成立、红军逐条找反例）。〔Q4=三类都注入；开发者确认〕
- **FR6（衔接与索引——所有副本，一处改处处改）**：把 `tests.md`/`writing-tests`/`TESTCASES` 自洽接入下列**全部**副本（mental-1 核实的遗漏已并入）：
  - 状态机序列/phase 枚举/闭环图：`skills/using-sandtable/SKILL.md`(dot 图+阶段表+异常修正 FIX 锚点+"编排前 N 步"+refine 行)、`skills/state-and-memory/SKILL.md`(目录结构+枚举+回退锚点 :64)、`templates/state.md`、`README.md`(闭环图+目录结构+skills 列表+`/start` 描述 :58)、`AGENTS.md`(=CLAUDE.md，闭环+技能索引 :43)、`.cursor/rules/sandtable.mdc`(闭环 :22+feature 产物清单 :36+技能索引)。
  - skill 衔接：`writing-prd`（**内部全部路由一致**：HARD-GATE :15、dot :28-32、结尾 :70 均改为 PRD 确认后→TESTCASES/writing-tests）、`writing-plan`（前置输入加入 tests.md；验证引用 TC 编号）。
  - 命令（每个含 `commands/` 与 `.cursor/commands/` 两副本，须同步）：`sandtable-start`（编排加 TESTCASES 步）、`sandtable-objectives`（**第 5 步 phase 改 TESTCASES、不再写死 PLAN**）、`sandtable-plan`（读 prd+tests）、`sandtable-resume`（读 prd+tests+plan）、`sandtable-refine`（增 writing-tests/tests.md 分支）、`sandtable-rehearse`（读/修 prd+tests+plan）。
  - `docs/sandtable/project.md` 计数（skills 10→11、templates 7→8、feature 文件清单加 tests）。
- **FR7（§5 重定位 + 审阅指引）**〔Q5=B、Q7；开发者确认〕：
  - 修订 `writing-prd`/`templates/prd.md` 的 §5 指引：**§5 只写抽象成功定义；一切具体可演练场景（含可执行检查命令）下沉 tests.md**；`writing-plan` 的验证步骤**引用 tests.md 的 TC 编号**而非另造预期。
  - 在 `writing-tests`（并在 `writing-prd` 提一句）写明开发者审阅顺序：**tests.md = 理解闸门（先读，判断 AI 是否真懂）**；**PRD §5 = 完成闸门（VERIFY 阶段勾选）**。

## 5. 验收标准（成功定义 · 抽象层；具体可演练场景见 tests.md TC1–TC9）
- [ ] 新产物与技能就位：`templates/tests.md` 与 `skills/writing-tests/SKILL.md` 存在且自洽、无占位符、风格与现有一致。〔具体检查见 TC4/TC7〕
- [ ] phase `TESTCASES` 在全部权威副本一致存在且位置正确（OBJECTIVES/PRD 之后、PLAN 之前）。〔见 TC3〕
- [ ] 脚手架生成含 `tests.md` 的新 feature 目录且保持幂等不覆盖。〔见 TC1/TC2〕
- [ ] 三类推演 prompt 均以逐条用例为突破点。〔见 TC5〕
- [ ] 流程闭环：PRD 确认→TESTCASES/writing-tests→PLAN/writing-plan，命令层与 skill 层一致、无写死旧路由。〔见 TC6〕
- [ ] 防重复落地：映射门禁 + §5 抽象/tests.md 具体/plan 引用 TC 的边界成立，无三产物冗余。〔见 TC4〕
- [ ] 全仓命名自洽、命令双副本同步、未破坏现有（两 plugin.json 合法、无关已调校文本未动）。〔见 TC8/TC9〕

## 6. MUST（绝对要做）
- **映射硬约束（防重复，核心）**：`tests.md` 每条用例必须能追溯映射回某条 **FR / 验收标准 / MUST / MUST NOT**；不允许写无法映射的"补充用例"。
- **三产物职责边界（Q5=B）**：PRD §5=抽象成功定义；tests.md=具体可演练场景（含可执行检查，是检验理解的唯一具体载体）；plan 验证=引用 tests.md 的 TC 编号落到代码/命令，不另造预期。三者不重叠。
- **审阅指引（Q7）**：tests.md 为理解闸门（先读）、§5 为完成闸门（VERIFY 勾选），写入 writing-tests/writing-prd。
- 单一事实来源：产物正文只来自 `templates/`；脚本只"指路"，不硬编码模板副本。
- 状态机/索引/闭环图/命令的所有副本严格自洽（一处改、处处改）。
- 黑盒、技术栈无关、人可读（Q2=A）。

## 7. MUST NOT（绝对不能做）
- 不把代码级可执行测试塞进 tests.md（那是 plan 的 TDD 职责）。
- 不引入第三方依赖；脚本仍零依赖、macOS/Linux bash 可跑。
- 不覆盖/破坏用户已有 `docs/sandtable/` 文件；init 保持幂等。
- 不擅改与本需求无关的 skill 已调校文本（Red Flags/合理化表/硬门禁），仅做衔接性增改。
- 不新增独立 slash 命令（Q1 决策）。
- 不做未被要求的兜底/灵活性、不节外生枝（继承 constraints.md）。

## 8. 非目标 / 暂不做（YAGNI）
- 不实现"自动把 tests.md 转成可执行测试"的工具。
- 不强制历史 feature 回填 tests.md（仅对新 feature 生效；已有 feature 不动）。
- 不引入测试框架/运行器。

## 9. 未决问题
见 questions.md：Q1-Q7 均已答复（2026-06-02；Q5-Q7 由头脑预演 mental-2 触发）。无剩余阻塞。
