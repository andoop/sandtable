# PRD · 落地后闭环：验收反馈（bug report）+ bugfix 模式

> 对应 project.md 北极星（自举式方法论）/ 继承 constraints.md 红线。实现细节见 plan.md，具体场景见 tests.md。

## 目标

给 Sandtable 补上**落地后的闭环**：当功能落地、用户自行验收时反馈的问题（bug），不再是"修了就完"，而是被当作**对推演覆盖度的诊断信号**，驱动一条可复现的链路——
`DONE → 用户验收 → BUG REPORT → BUGFIX(证据驱动找根因) → FIX(mini 推演) → REGRESS(回归用例) → HARDEN(回写 RECON/红线/红军战术)`。
落地两个 skill（`triaging-feedback`、`bugfix-with-evidence`）、一个新阶段 `FEEDBACK`、一份 per-feature 产物 `feedback.md`、两个命令（`/sandtable-bug`、`/sandtable-bugfix`），让方法论真正"用 bug 反哺自己"。

## 背景与现状

- 状态机当前止于 `DONE`，**无落地后回路** `[skills/using-sandtable/SKILL.md:45; skills/state-and-memory/SKILL.md:39]`。
- `being-truthful` 是"规划/预演/实现期不猜测"的门禁，**不覆盖运行期排障** `[skills/being-truthful/SKILL.md]`。
- 全仓**无任何** bugfix / debug / bug-report / 根因 专用 skill（已搜索确认）。
- 镜像面：skill 4 根、command 6 根 + `using-sandtable`/`.cursor/rules/sandtable.mdc`/`AGENTS.md`/README 索引 `[已确认: 目录枚举; closed-loop-guidance/prd.md FR7]`。
- 仓库有两个未提交在制 feature（`closed-loop-guidance`、`superpowers-harness-parity`）；`closing-the-loop` skill 已存在未提交，本需求与之**互补**（收尾区块需新增 `FEEDBACK` 行）。

## 用户故事 / 使用场景

- 作为开发者，功能落地后我自己验收发现一个问题，我执行 `/sandtable-bug` 把它记进该 feature 的 `feedback.md`，AI 据此分诊：是真缺陷 / 漏掉的需求 / 误解。
- 作为开发者，面对一个"不知道为什么"的缺陷，我执行 `/sandtable-bugfix`，AI **不靠猜**：列假设 → 用工程自带日志框架按统一 tag 在关键点插桩 → 复现取证 → 逐一证伪 → 锁定根因（能用 `file:line`+日志讲清因果链）→ 根因修复 → 复现消失 → 清理临时日志。
- 作为方法论维护者，我希望每条逃逸 bug 修完后，AI 都回答"**为什么推演没逮到它**"，并落一条回归用例 + 反哺 RECON 清单/红线/红军战术，让下一轮更难被同类问题穿透。

## 方案探索（已与开发者确认，全选最完整方案 A）

| 维度 | 选定（A） | 备选 | 理由 |
|------|-----------|------|------|
| 范围 | 单 feature + 两 skill | 拆两 feature / 合一 skill | 二者强耦合，共享回归与加固回路 |
| 状态机 | 新增 `FEEDBACK` 阶段，DONE 后可重入 | 复用回退重演 / 仅文档 | 最贴"自举"，显式承接验收反馈 |
| 产物 | per-feature `feedback.md` + 回写 tests.md | 全局 bugs/ / 每 bug 新 feature | 与"哪个需求漏的"强绑定 |
| 命令 | `/sandtable-bug` + `/sandtable-bugfix` | 只加一个 / 都不加 | bugfix 与反馈都是高频独立动作 |
| bugfix 日志 | 硬门禁（根因必靠日志100%等） | 调整 tag/清理 | 开发者明确"追根究底、禁表面/临时修复" |

## 功能需求

- **FR-PHASE（新增 FEEDBACK 阶段）**：在状态机 `DONE` 之后新增可重入阶段 `FEEDBACK`（军事隐喻：战后讲评/after-action）。`FEEDBACK` 承接验收反馈：分诊后，缺陷类反馈回环到 bugfix→修复→回归→加固，必要时回退到 `OBJECTIVES`（漏需求）或 `PLAN`（实现缺陷）重走最短闭环。须更新 phase 枚举（`state-and-memory`、`templates/state.md`）、状态机图与阶段表（`using-sandtable`、`.cursor/rules/sandtable.mdc`、`AGENTS.md`、README mermaid）、`closing-the-loop` 的 phase→下一步映射（新增 `FEEDBACK` 行）。〔已确认：Q2=A〕

- **FR-FEEDBACK-SKILL（`triaging-feedback` skill）**：新建 `skills/triaging-feedback/SKILL.md`。职责：①把一条验收反馈固化为 `feedback.md` 条目（含复现步骤、期望/实际、严重度）；②分诊三类（真缺陷 / 漏需求 / 误解或预期内）；③缺陷类**必须**转入 `bugfix-with-evidence` 找根因，禁止跳过根因直接改；④修复闭合后**必须**产出回归用例（回写该 feature `tests.md`）与一条"加固结论"（回答"为什么推演没逮到"→指向 RECON 清单 / `constraints.md` / 红军战术中的具体补强点）。**无 feature 兜底（修 redteam-1 B3）**：若反馈针对的代码**没有对应 feature 目录**，自动新建轻量 feature `<date>-bugfix-<slug>`（最小 state/feedback），按一次正常 feature 走闭环。〔已确认：Q1=A、Q3=A、Q20=A〕

- **FR-BUGFIX-SKILL（`bugfix-with-evidence` skill）**：新建 `skills/bugfix-with-evidence/SKILL.md`，作为"不猜测"在运行期的延伸闭环：复现并定义期望 vs 实际 → 列**多个**假设（不默默选一个）→ 插桩取证 → 证据逐一证伪 → **靠日志/运行时证据锁定根因**（只读代码不算，见 FR-BUGFIX-GATE 1）→ 根因修复 → 验证复现消失 → 清理。与 `being-truthful` 交叉引用。〔已确认：Q1=A、Q15=A〕

- **FR-BUGFIX-COLLECT（自动收集日志，少打扰用户）**：`bugfix-with-evidence` 必含"**先自动收集**"纪律——取证前先按项目类型判断**能否由 agent 自动采集**，能自动就**不让用户提供**：
  - 采集策略菜单（按项目识别选用）：Android→`adb logcat`（如 `adb logcat -d > <drop>/logcat.txt`）；有日志文件/目录→直接读/尾随；能跑复现→运行并抓 stdout/stderr；运行时/远程→在**用户项目内、用用户技术栈**临时起一个 log sink（用完即清，纳入临时日志清理纪律）。
  - 仅当**确实只有用户能提供**（设备日志、生产 `log.zip`）才请用户提供，并给**最省事路径**：指明丢到哪（见落点）、给**现成命令**让用户一键导出。
  - **无日志出路（守住 100%）**：当日志**既不能自动采集、用户也无法提供、又非纯静态可判定**时，**不擅自降级关闭**——升级为 `blocked=true`、写 `questions.md` 问开发者（补日志手段，或由开发者明确决定如何处置）。〔已确认：Q18=A（修 mental-1 M3）〕
  - **落点约定（修 redteam-1 B2，安全）**：采集到的日志 / 用户 `log.zip` 放**仓库外/临时目录**（如系统 temp 或项目外 scratch，**不在 git 仓内**），因日志常含密钥/PII；`feedback.md` 只记**来源 + 关键摘录 + 证据出处（行号/时间戳）**，agent **绝不把日志原文 `git add`/入库**。〔已确认：Q19=A〕
  - **边界（护红线）**：Sandtable **只发 markdown skill**，**不捆绑**通用日志 server/采集脚本/自动插桩工具；一切采集动作发生在用户项目、由 agent 用用户工具链完成。〔已确认：Q6=A、Q7=A、Q9=A〕

- **FR-BUGFIX-SQUAD（调查红军分队 + 推演武器库，广+深+发散）**：`bugfix-with-evidence` 必含"**调查分队**"编排，排查思维要**广**（多角度）、**深**（到根因非症状）、**发散**（大胆列假设不过早收敛）——非平凡缺陷（多假设 / 跨子系统 / 难复现）默认派 **≥3 个并行调查子 agent**（与 `red-team-wargame` `min_agents` 一致），每个攻一个角度（时序 / 数据流 / 依赖与配置 / 并发 / 状态与生命周期 / 外部 IO 等），**深入取证**并回报**带日志证据**的发现（纯推断不算，见 FR-BUGFIX-GATE 1）。**可动用沙盘推演武器库**：头脑预演（推因果链）、`gathering-intel`（摸日志/数据流地形）、**红军 `red-team-wargame`（证伪候选根因——攻不破才算真根因）**。**采集集中、子 agent 只读（修 redteam-1 B1）**：日志采集/跑复现/起 sink **由主 agent 集中先做一次**，调查子 agent 是**只读分析者**（对已采集日志/代码取证），**禁止各自跑复现或起 sink**，以免并行争抢设备/端口/文件、污染证据。主 agent 汇总、**亲自核实**，锁定**单一根因**（不轻信任一子 agent 的"我觉得"）。复用并行隔离子 agent 纪律，但**使命是找根因、非击溃计划**。平凡缺陷可单线，不强派分队。配套子 agent 派发模版 `skills/bugfix-with-evidence/investigator-prompt.md`。〔已确认：Q8=A、Q9=A、Q16=A〕

- **FR-BUGFIX-GATE（bugfix 硬门禁）**：`bugfix-with-evidence` 必含 HARD-GATE：
  1. **【最根本】根因必须靠日志/运行时证据 100% 确认**：**只靠读代码推断不得视为已确认根因**；锁定根因必须有日志或运行时证据贯通整条因果链。唯一窄例外：缺陷本质**纯静态可判定**（编译/类型错误、明显笔误）并须说明，且仍优先复现验证。**日志确实无法获得**（不能自动采、用户给不出、又非纯静态可判定）→ 不擅自降级，升级 `blocked` 写 `questions.md` 问开发者（见 FR-BUGFIX-COLLECT 无日志出路）。〔已确认：Q15=A、Q18=A〕
  2. **优先复用工程自带日志框架**（先侦察项目用什么日志框架/约定）；项目无统一框架时降级到该语言惯用日志方式，**禁止裸 `print`/`console.log` 式临时输出冒充**（除非该项目本就以此为约定）。
  3. **统一 tag**：所有为本次排障新增的日志带统一可 grep 前缀 `[SANDTABLE-BUGFIX:<feature-or-bug-id>]`，便于检索与一键清理。
  4. **根因确认后移除临时日志**：根因落定、修复验证后必须按 tag 清理本次新增的临时日志（确有长期价值需保留的，要显式说明并改为正式日志，不留 SANDTABLE-BUGFIX 临时 tag）。
  并显式禁止：表面修复（改症状不改因）、临时修复（try/catch 吞掉、sleep 规避、注释掉报错）、"先这样以后再说"。〔已确认：Q5=A、Q15=A〕

- **FR-ARTIFACT（feedback.md 产物 + 模板）**：每个 feature 目录可有 `feedback.md` 台账（一条 bug 一节：id、来源、生命周期状态、复现、期望/实际、严重度、日志来源、分诊结论、根因、修复指向、回归用例指向、预防、教训）。新增 `templates/feedback.md`，并纳入 `state-and-memory` 的目录结构说明与英文模板。回归用例**回写该 feature 的 `tests.md`**，不另起台账。〔已确认：Q3=A〕

- **FR-LIFECYCLE（反馈生命周期 + 用户确认关闭）**：每条反馈带**显式生命周期状态**，承认排查是**反复**过程：`OPEN(待分诊) → TRIAGED(已分诊) → INVESTIGATING(调查中，可反复:假设⇄证伪) → ROOT_CAUSED(根因锁定) → FIXING(修复中) → VERIFYING(验证复现是否消失) → USER_CONFIRMED(用户确认收敛/解决) → CLOSED(已关闭，教训已沉淀)`。规则：VERIFYING 未通过弹回 INVESTIGATING；**未经用户确认收敛，不得置 USER_CONFIRMED/CLOSED**（主 agent 不得自行宣布"已解决"而关闭）。状态写在 `feedback.md` 该 bug 节，并驱动 `state.md` 的 `phase=FEEDBACK`。**FEEDBACK 是人在环阶段**：`autopilot` **不驱动** FEEDBACK（其强制范围止于 `EVALUATE/DONE`，见 `autonomous-orchestration`），FEEDBACK 仅由 `/sandtable-bug`、`/sandtable-bugfix` 手动进入；"等待用户确认收敛"是合法停点；恢复/续跑时 `phase=FEEDBACK`（及 DONE 之后）不参与 autopilot 配额闭包，一律**按 phase 恢复**，不得被误路由回 `EVALUATE`。〔已确认：Q10=A、Q17=A（修 mental-1 M1/M2）〕

- **FR-LESSONS（关闭三件套 + 全局教训沉淀）**：反馈**关闭时必须**产出三件套——**根因**（带因果链+证据）、**怎么预防**（流程/红线/检查项层面的预防措施，非仅"以后小心"）、**吸取的教训**（一句可复用的经验）。教训**必须**写入**全局** `docs/sandtable/lessons.md`（项目级、跨 feature 累积，与 `project.md`/`constraints.md` 平级单例），每条含：日期、来源 feature/bug、根因摘要、预防、教训、**候选红线/检查项更新建议**。同时给出对 `constraints.md`（新红线）/ RECON 清单（新检查项）的**候选更新**供开发者采纳（采纳与否由开发者拍板，不擅自改全局红线）。〔已确认：Q11=A、Q12=A〕

- **FR-FEEDFORWARD（教训反哺未来推演）**：在开新需求时，`gathering-intel`(RECON)、`red-team-wargame`、`writing-prd` **若存在** `docs/sandtable/lessons.md` 则**必读**（修 redteam-1 B4：文件不存在则跳过，不报错），把历史教训转成本次的侦察检查项、红军攻击向量、PRD 红线候选——让过去的 bug 武装未来的推演。三处仅**追加交叉引用**（"开工前若有 lessons.md 则读"），不改其已调校正文。`lessons.md` 由 `triaging-feedback` 首次沉淀教训时**按需创建**（不仅靠 init）。〔已确认：Q13=A〕

- **FR-CMD（两个命令）**：新增 `/sandtable-bug`（受理一条验收反馈，进入 `triaging-feedback`，必要时把 phase 置 `FEEDBACK`）与 `/sandtable-bugfix`（对一个缺陷启动 `bugfix-with-evidence` 闭环）。两命令须在**全部 6 个 command 镜像根**落地，并在 README 命令入口、`.cursor/rules` 技能/命令索引、`AGENTS.md` slash 列表登记。〔已确认：Q4=A〕

- **FR-INDEX（接入点登记）**：在技能索引与状态机相关单一事实来源登记两个新 skill 与新阶段：`skills/using-sandtable/SKILL.md`（阶段表 + 三类推演之外的落地后闭环说明 + 技能索引）、`.cursor/rules/sandtable.mdc`（技能索引 + 状态机 + slash 列表）、`AGENTS.md`(=`CLAUDE.md`)（状态机 + 技能索引 + slash 列表）、README（命令入口 + 可选 mermaid）。〔已确认：Q1/Q2/Q4 蕴含〕

- **FR-MIRROR（全镜像 + 英文）**：所有新增 skill/command/template（含 `templates/feedback.md`、`templates/lessons.md`、`investigator-prompt.md`）须同步到 `plugins/sandtable/`、`locales/en/`（含 `locales/en/plugins/sandtable/`）对应镜像；`scripts/sandtable-init.sh` 的全局循环加入 `lessons.md`（如有 en 脚本镜像同步）；`gathering-intel`/`red-team-wargame`/`writing-prd` 的交叉引用同步到中英 4 个 skill 根。英文镜像正文为英文，slash 名仍为 `/sandtable-*`，tag 仍为 `[SANDTABLE-BUGFIX:<id>]`。〔已确认：继承 closed-loop-guidance FR7 的多镜像现实〕

## 验收标准（抽象成功定义）

- [ ] 开发者能用 `/sandtable-bug` 把一条验收反馈落进对应 feature 的 `feedback.md` 并得到分诊结论。
- [ ] 缺陷类反馈在修复前**必经** bugfix 根因闭环；最终交付包含"根因（带 `file:line`/日志证据）+ 回归用例 + 加固结论"，而非仅"已修复"。
- [ ] `/sandtable-bugfix` 全程不靠猜：有显式假设清单、有按统一 tag 的插桩取证、根因落定后临时日志被清理。
- [ ] bugfix 取证**优先自动收集**：能 `adb`/读文件/抓复现输出的，agent 自采不打扰用户；仅"只有用户能给"时才请用户提供并给现成命令；日志落 per-feature `logs/`（不入库）。
- [ ] 非平凡缺陷会派**≥3 个并行调查子 agent**多角度深挖，主 agent 汇总并亲自核实锁单一根因。
- [ ] **根因必须靠日志/运行时证据 100% 确认**：只读代码推断不被接受为已确认根因（纯静态可判定缺陷为窄例外且需说明）。
- [ ] 排查可动用头脑预演/侦查/红军（红军证伪候选根因），思维体现广+深+发散。
- [ ] 每条反馈有显式生命周期；**未经用户确认收敛不得关闭**；排查可在 INVESTIGATING↔VERIFYING 间反复。
- [ ] 关闭必产出**根因+预防+教训**三件套；教训累积进全局 `lessons.md`，并给出 `constraints.md`/RECON 候选更新。
- [ ] 开新需求时 RECON/红军/PRD 会**读 `lessons.md`**，历史教训成为本次检查项/攻击向量——过去的 bug 武装未来推演。
- [ ] 状态机 `FEEDBACK` 阶段在 `using-sandtable` / `state-and-memory` / rules / AGENTS / `closing-the-loop` 映射中**一致可见**，无相互矛盾。
- [ ] 两个新 skill、两个新命令、`feedback.md` 模板在中英镜像与各接入点索引齐备、无遗漏路径。

## MUST

- 必须新增 `skills/triaging-feedback/SKILL.md` 与 `skills/bugfix-with-evidence/SKILL.md`（两个单一事实来源）。
- bugfix skill 必须含 FR-BUGFIX-GATE 硬门禁（含根因必靠日志100%），并显式禁止表面/临时修复。
- 缺陷类反馈必须经根因再修复；修复必须产出回归用例（回写 tests.md）+ 加固结论。
- 必须新增 `FEEDBACK` phase 并在所有状态机单一事实来源保持一致。
- bugfix 取证必须**先尝试自动收集**，能自动则不打扰用户；非平凡缺陷必须可派并行调查分队（默认 ≥3）多角度深挖。
- 反馈必须有显式生命周期，**未经用户确认收敛不得关闭**；关闭必产出根因+预防+教训三件套。
- 必须新增全局 `docs/sandtable/lessons.md`（与 project/constraints 平级单例，init 脚本幂等创建），教训跨 feature 累积。
- 开新需求时 RECON/红军/PRD 必读 `lessons.md`（仅追加交叉引用，不改其已调校正文）。
- 必须同步 `plugins/sandtable/` 与 `locales/en/` 全部镜像与索引。

## MUST NOT

- 禁止 bugfix 时靠猜测下结论、做表面修复或临时修复（吞异常/sleep/注释报错）。
- 禁止把 bug 修复绕过根因直接改症状。
- 禁止新增运行时依赖或违反 `constraints.md`（POSIX sh / 零依赖、幂等、不毁用户 `docs/sandtable/`）。
- 禁止改动**与本需求无关** skill 的 Red Flags / 合理化 / 硬门禁正文（仅允许：本需求授权的状态机/索引登记，与新 skill 的交叉引用追加）。
- 禁止把全局 bug 台账写进用户项目（产物为 per-feature `feedback.md`，由方法论描述、不硬编码业务）。

## 非目标 / 暂不做

- 不做自动抓取/解析外部 issue tracker（GitHub/Jira）的集成。
- **不在 Sandtable 内捆绑**通用日志接收 server / 采集脚本 / 自动插桩工具（护零运行时依赖）。注意：**自动收集日志本身在范围内**，但它是 **skill 指引**——由 agent 在用户项目用其自带工具链完成，临时 sink 用完即清；Sandtable 只发 markdown。
- 不为日志做框架探测**脚本**；框架识别由 agent 按 skill 纪律在排障时判断。
- 不改造 `AskQuestion`/`closing-the-loop` 既有纪律，仅为其补 `FEEDBACK` 行。
- 不为非 Sandtable 的普通排障强加流程（与 closing-the-loop 第三态边界一致）。

## 未决问题

无（Q1-Q5 已由开发者确认，见 questions.md）。新发现的不确定按 `being-truthful` 处理并回写本文件。
