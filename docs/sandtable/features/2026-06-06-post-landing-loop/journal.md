# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/预演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-06 14:50 · [决策] INTAKE 受领需求
- 背景：开发者通过 `/sandtable-start` 提出两条需求并要求"结合 Sandtable 思考最合理/最完美做法"。
- 内容：①增加 bug report（验收反馈）功能，并思考"用户验收反馈的问题是否对沙盘推演流程有帮助"；②增加 debug 模式——通过在关键处加日志（优先用工程自带日志框架、统一 tag）追根究底找根因，禁止表面/临时修复，需形成 skill 闭环。
- 依据/来源：开发者原始消息（/sandtable-start 命令正文）。

## 2026-06-06 14:55 · [侦察] RECON 情报简报
- 背景：在定目标前摸清 Sandtable 仓库地形与本需求落点。
- 已确认事实（带来源）：
  - 规范仓库是 `sandtable/`（git，分支 main）；工作区根 `sss/` 非 git，仅为外壳。`[已确认: git -C sandtable status]`
  - 状态机当前止于 DONE：`INTAKE→RECON→OBJECTIVES→TESTCASES→PLAN→MENTAL_REHEARSAL→REDTEAM→IMPL_REHEARSAL→EVALUATE→INTEGRATE→VERIFY→DONE`，**无落地后（验收反馈）回路**。`[已确认: skills/using-sandtable/SKILL.md:28-72; skills/state-and-memory/SKILL.md:39]`
  - 方法论核心是"自举/落地前暴露破口"，README 明确"自举证明"。落地后反馈如何回流强化流程，当前**没有任何 skill 覆盖**。`[已确认: README.md:58-59; Grep 无 debug/bug-report/根因 专用 skill]`
  - `being-truthful` 是"不猜测"的被动门禁，但只覆盖规划/预演/实现期，**不覆盖运行期排障（debug）**。`[已确认: skills/being-truthful/SKILL.md]`
  - 镜像面巨大：skill 有 4 个根（`skills/`、`plugins/sandtable/skills/`、`locales/en/skills/`、`locales/en/plugins/sandtable/skills/`）；command 有 6 个根（`commands/`、`.cursor/commands/`、`plugins/sandtable/commands/` + 三个 locales 镜像）。新增 skill/command 须全镜像并在 `using-sandtable`、`.cursor/rules/sandtable.mdc`、`AGENTS.md`、README 索引登记。`[已确认: ls 各镜像根; closed-loop-guidance/prd.md FR7]`
  - 仓库当前有两个未提交在制 feature：`closed-loop-guidance`、`superpowers-harness-parity`；新增 `closing-the-loop` skill 尚未提交。本需求与 `closing-the-loop`（回合收尾）互补而非冲突。`[已确认: git status]`
- 分析（回答开发者"验收反馈是否对流程有帮助"）：
  - 有，且是当前方法论缺失的关键一环。Sandtable 命题是"落地前用三类推演逼出破口"；但任何逃逸到用户验收阶段的 bug，按定义就是一处**推演盲区**——要么 RECON 漏看、要么 OBJECTIVES 没定义、要么 tests.md 没标定、要么红军没想到的战术。
  - 因此一条验收反馈不止"修好它"，更是**对方法论覆盖度的诊断信号**：每条逃逸 bug 应产出两份输出——(1) 根因修复（=debug 模式）；(2) 回归用例 + 反哺 RECON 清单/红线/红军战术，让下一轮推演逮得住同类问题。这正是 README"自举"的闭环补全。
  - 两需求关系：bug report=触发/输入；debug 模式=找根因的调查引擎；输出=根因修复+回归用例+加固推演。三者构成 Sandtable 缺失的**落地后闭环（after-action）**：`DONE → 用户验收 → BUG REPORT → DEBUG(根因) → FIX(mini 推演) → REGRESS(回归用例) → HARDEN(回写 RECON/红线/红军)`。
- 待澄清（产品决策，读码/读档无法定，记入 questions.md）：Q1 范围拆分、Q2 状态机是否新增 phase、Q3 反馈产物落点、Q4 是否加 slash 命令、Q5 debug 日志 tag/清理纪律。
- 依据/来源：见上各 `[已确认]` 标注。

## 2026-06-06 15:05 · [问答] Q1-Q5 选型拍板
- 背景：OBJECTIVES 前用 AskQuestion 就 5 个产品决策征询开发者。
- 内容：开发者全选 A（最完整方案）：
  - Q1=A 单 feature + 两 skill（`triaging-feedback`=验收反馈分诊与加固；`debugging-with-evidence`=证据驱动根因排障）。
  - Q2=A 新增 `FEEDBACK` 阶段（战后讲评/after-action），DONE 后可重入；授权改动 state-and-memory / using-sandtable / rules / AGENTS 等核心文本与 README。
  - Q3=A per-feature `feedback.md` 台账 + 回写该 feature `tests.md` 的回归用例。
  - Q4=A 新增 `/sandtable-bug`（验收反馈入口）与 `/sandtable-debug`（debug 闭环入口）两命令。
  - Q5=A debug 三条硬门禁：先复用工程自带日志框架（无则用该语言惯用日志，禁裸 print）；统一 tag `[SANDTABLE-DEBUG:<id>]`；根因确认后移除临时日志。
- 依据/来源：开发者 AskQuestion 答复（本回合）。

## 2026-06-06 15:20 · [决策] PRD 确认 + TESTCASES + PLAN 完成
- 背景：开发者确认 PRD 方向（选 ok_plan：一气写完 tests + plan）。
- 内容：
  - 命名定稿：phase=`FEEDBACK`；skill=`triaging-feedback`/`debugging-with-evidence`；命令=`/sandtable-bug`/`/sandtable-debug`；产物=`feedback.md`；日志 tag=`[SANDTABLE-DEBUG:<feature-or-bug-id>]`。
  - tests.md 产出 TC1–TC14（含边界 TC12 非缺陷不进 debug、TC13 无框架降级、TC14 非 Sandtable 不强加）。
  - plan.md 产出 T1–T7：两 skill 中文源（含硬门禁全文）、feedback 模板、FEEDBACK 写入 7 个状态机单一事实来源、两命令中文 3 根、镜像同步 plugins+locales/en、全局核对。
  - 镜像基数：两 skill × 4 根=8 个 SKILL；两命令 × 6 根=12 个命令文件。
- 依据/来源：prd.md / tests.md / plan.md（本 feature 目录）；镜像现实参照 closed-loop-guidance/plan.md。

## 2026-06-06 15:32 · [反馈/精修] 开发者 /sandtable-objectives 追加 debug 两项需求
- 背景：开发者读 plan 后通过 `/sandtable-objectives` 提出对 debug 模式的两项增强，回退 OBJECTIVES 精修 PRD。
- 内容（原话要点）：
  - ①**自动收集日志**：debug 时按项目类型判断——能自动收集就别让用户提供（如 adb 命令、起一个 server 接收日志、类似 Cursor debug 模式）；提供专门位置接收/存放用户日志文件或 `log.zip`；总之能自动就自动，尽量方便。
  - ②**调查红军分队**：准备一队"红军人马"从多方排查、深入骨髓地查根因。
- 主 agent 分析：
  - ②与现有 `red-team-wargame` 的 OPFOR 并行子 agent 模式同源 `[已确认: skills/red-team-wargame/SKILL.md:33-52]`，区别在使命：红蓝对抗=击溃计划；调查分队=多角度挖根因。可在 `debugging-with-evidence` 内编排"调查分队"，复用并行隔离子 agent 纪律 `[已确认: skills/implementation-rehearsal/SKILL.md:12-16]`。
  - ①与本 feature 原非目标"不做日志框架探测/自动插桩工具"有张力：需区分 **自动收集（采集既有日志，现 IN scope 作为 skill 指引）** vs **捆绑收集工具/自动插桩脚本（仍 OUT，护 constraints 零依赖）**。Sandtable 仍只发 markdown skill；采集动作在用户项目用其自带工具链完成。
  - 由此产生 Q6-Q9（落点/边界/编排/纪律）待开发者拍板，记入 questions.md。
- 依据/来源：开发者 /sandtable-objectives 消息；red-team-wargame / implementation-rehearsal skill。

## 2026-06-06 15:48 · [决策] Q6-Q9 拍板（全 A）并并入 PRD/tests/plan
- 背景：开发者就 debug 两项增强的 4 个决策点全选推荐项。
- 内容：
  - Q6=A 纯 skill 指引（不捆绑 server/脚本，护零依赖）；Q7=A 日志落 per-feature `logs/` 默认不提交；Q8=A 调查分队并入 `debugging-with-evidence`；Q9=A 先自动收集纪律 + 非平凡缺陷默认派 N=3 并行调查子 agent。
  - PRD 新增 FR-DEBUG-COLLECT、FR-DEBUG-SQUAD；修订非目标（自动采集 IN=skill 指引；捆绑工具/插桩脚本 OUT）；补 MUST 与验收两条。
  - tests.md 新增 TC15（先自动收集 adb 例）、TC16（logs/ 不入库）、TC17（≥3 并行调查多角度）、TC18（仅 markdown 不捆绑工具边界）。
  - plan.md：T2 增「自动收集策略表」「调查分队（≥3）」+ 硬门禁第5条 + 新建 `investigator-prompt.md`；T3 feedback 模板加「日志来源」字段；T4 state-and-memory 目录加 `logs/`；T6 镜像含 investigator-prompt；VERIFY 扩到 TC1–TC18 + 不捆绑工具核对。
- 依据/来源：questions.md Q6-Q9；prd.md / tests.md / plan.md 本次编辑。

## 2026-06-06 15:52 · [反馈/精修] 排查生命周期 + 教训沉淀加强整个沙盘
- 背景：开发者 /sandtable-refine 指出排查是反复的、有生命周期的过程，关闭需用户确认收敛，且根因/预防/教训应被重视并吸取以加强整个沙盘推演。
- 主 agent 分析：
  - 现设计的"加固结论"仅一字段，不足以承载"被重视的教训闭环"。应升级为：①每条反馈的**显式生命周期状态机**（含反复迭代 + 用户确认收敛才关闭的闸门）；②关闭强制三件套（根因/预防/教训）；③教训沉淀到**全局** `lessons.md` 并候选更新 `constraints.md`/RECON 清单；④未来 RECON/REDTEAM/PRD **必读** lessons.md，使过去 bug 武装未来推演——真正闭环"自举"。
  - 成本：触达全局文件（新增 lessons.md、交叉引用 gathering-intel/red-team-wargame/writing-prd/constraints），镜像与索引面再扩。记入 Q10-Q13 请开发者拍板。
- 依据/来源：开发者 /sandtable-refine 消息；README「自举」承诺。

## 2026-06-06 16:05 · [决策] Q10-Q13 拍板（全 A）并并入 PRD/tests/plan
- 背景：开发者就排查生命周期 + 教训沉淀 4 个决策点全选推荐项。
- 内容：
  - Q10=A 反馈显式生命周期 `OPEN→TRIAGED→INVESTIGATING(可反复)→ROOT_CAUSED→FIXING→VERIFYING→USER_CONFIRMED→CLOSED`，未经用户确认不得关闭。
  - Q11=A 关闭强制三件套：根因 + 怎么预防 + 吸取的教训。
  - Q12=A 新增全局 `docs/sandtable/lessons.md`（与 project/constraints 平级单例），关闭写入教训 + 给 constraints/RECON 候选更新（不擅改红线）。
  - Q13=A `gathering-intel`/`red-team-wargame`/`writing-prd` 开新需求必读 lessons.md。
  - PRD 新增 FR-LIFECYCLE / FR-LESSONS / FR-FEEDFORWARD，扩 FR-ARTIFACT/FR-MIRROR/验收/MUST。
  - tests.md 新增 TC19（生命周期+用户确认关闭）、TC20（三件套）、TC21（lessons.md+候选红线）、TC22（反哺 RECON/红军/PRD）。
  - plan.md：T1 加生命周期/用户确认/三件套/教训沉淀硬门禁 + 流程图更新；T3 feedback 模板加生命周期/用户确认/预防/教训字段；新增 **T8**（templates/lessons.md + init 脚本全局循环加 lessons.md + 三处 skill 交叉引用 + 镜像）；VERIFY 扩到 TC1–TC22。
  - 已确认 init 脚本全局循环现为 `project.md constraints.md`（scripts/sandtable-init.sh:68），加 `lessons.md` 即可，幂等不覆盖。
- 依据/来源：questions.md Q10-Q13；scripts/sandtable-init.sh:64-75；prd/tests/plan 本次编辑。

## 2026-06-06 16:10 · [反馈/精修] 暂停 mental，追加 bugfix 改名 + 日志100%锁根因 + 排查动用推演武器
- 背景：开发者在 `/sandtable-mental` 派发前喊停，补充三项需求。
- 内容（原话要点）：①"debug 模式"应叫"**bugfix 模式**"；②**确定问题只靠看代码不行，必须配合日志 100% 确定根本原因——最最根本的要求**；③排查过程可走头脑推演、侦查、红军等；④排查思维要广、深、活跃（发散）。
- 主 agent 分析：
  - ②强化 debug HARD-GATE：根因必须有**日志/运行时证据**佐证；纯静态读代码推断不得视为已确认根因（编译/类型等纯静态可判定缺陷为窄例外，且仍优先复现）。与 FR-DEBUG-COLLECT（自动收集日志）咬合：日志是 100% 锁根因的证据底座。
  - ③把现有"调查红军分队"升级为"动用推演武器库"：头脑预演（推因果链）、gathering-intel（摸日志/数据流地形）、red-team（**证伪候选根因**——攻不破才算真根因）。④对应"广(多角度)+深(到根因)+活跃(发散假设)"的排查纪律。
  - 改名零成本：尚未实现，仅改文档。涉及 skill/命令/tag/prompt 命名，记入 Q14。
- 依据/来源：开发者 /sandtable-mental 前的补充消息。

## 2026-06-06 16:25 · [决策] Q14-Q16 拍板（全 A）并并入 PRD/tests/plan
- 背景：开发者就第三轮精修 3 个决策点全选 A；Q16 补充"把活跃改为发散"。
- 内容：
  - Q14=A 全套改名：skill `debugging-with-evidence`→`bugfix-with-evidence`；命令 `/sandtable-debug`→`/sandtable-bugfix`；tag `[SANDTABLE-DEBUG]`→`[SANDTABLE-BUGFIX]`；`/sandtable-bug`(报障)与`/sandtable-bugfix`(修障)并存。
  - Q15=A 最根本硬门禁：根因必须靠**日志/运行时证据 100% 确认**，纯读代码推断不算；窄例外=纯静态可判定缺陷且说明。
  - Q16=A 排查动用推演武器库（头脑预演/侦查/红军**证伪候选根因**），思维**广+深+发散**（活跃→发散）。
  - 改动：prd 重命名 FR-DEBUG-*→FR-BUGFIX-*，FR-BUGFIX-GATE 增第1条(日志100%)，FR-BUGFIX-SQUAD 增推演武器+广深发散，FR-BUGFIX-SKILL 强调日志锁根因，补两条验收。
  - tests：全量改名 + 新增 TC23(根因必靠日志100%)、TC24(推演武器+广深发散+红军证伪)。
  - plan：全量改名(debug→bugfix)；T2 skill HARD-GATE 增第1条(日志100%最根本)、调查分队增推演武器+广深发散、闭环图根因门改"有日志证据?"、Red Flags 增两行、investigator-prompt 增姿态/日志证据；step3 覆盖加 TC23/TC24。
  - 历史保留：questions.md Q1-Q13 的"已写回 FR-DEBUG-*"为历史记录，按只增不改不回改；改名在 Q14 + 本条登记。
  - 注：尚未派 mental 子 agent（开发者喊停），改名零实现成本。
- 依据/来源：questions.md Q14-Q16；prd/tests/plan 本轮编辑。

## 2026-06-06 16:45 · [推演/异常] 头脑预演 mental-1：发现 3 处异常
- 背景：用户中断 4 个并行只读子 agent 后，主 agent 自跑头脑预演（基于真实文件）。报告见 rehearsals/mental-1.md。
- 内容：
  - **M1**（待开发者裁决）：FR-LIFECYCLE"用户确认才关闭"与 autopilot"非阻塞自动续跑"交互未定义；FEEDBACK 是否可被 autopilot 驱动、"等待确认"映射成什么状态，无定义。
  - **M2**（计划缺口，可直接修）：state-and-memory 的 autopilot 恢复/配额闭包分支无 FEEDBACK 情形；DONE 后进入 FEEDBACK 的 feature 若 autopilot resume 会误路由回 EVALUATE。plan T4 漏改 state-and-memory 恢复分支。
  - **M3**（待开发者裁决）：根因必靠日志100%，但"既不能自动采、用户也给不出、又非纯静态可判定"时无出路，可能死锁 FEEDBACK 闭环。
- 依据/来源：autonomous-orchestration:13/76, state-and-memory:117-124（已确认）；rehearsals/mental-1.md。
- 下一步：M1/M3 问开发者（questions Q17/Q18）；定性后修 prd/plan（含 M2 的 T4 补丁），再重演 mental。

## 2026-06-06 17:00 · [决策/推演] Q17/Q18=A 修正三异常 + mental-2 复验闭合
- 背景：开发者裁决 Q17=A（FEEDBACK 人在环、autopilot 不驱动）、Q18=A（无日志升级 blocked，不擅自降级）。
- 内容：
  - 修 M1：prd FR-LIFECYCLE 补"FEEDBACK 人在环、autopilot 不驱动、等待确认=合法停点、按 phase 恢复"；plan T1 同步。
  - 修 M2：plan T4 补"state-and-memory 恢复分支：DONE/FEEDBACK 不参与配额闭包、按 phase 恢复，不误路由 EVALUATE"。
  - 修 M3：prd FR-BUGFIX-COLLECT 增"无日志出路→blocked+questions.md"；FR-BUGFIX-GATE 1 引用。
  - tests 新增 TC25（无日志升级 blocked）、TC26（FEEDBACK 人在环+按 phase 恢复）。
  - mental-2 复验：三处修正闭合、无新异常（报告 rehearsals/mental-2.md），mental.last=closed。
- 依据/来源：questions.md Q17/Q18；autonomous-orchestration:13；rehearsals/mental-2.md。
- 下一步：红蓝对抗（redteam）。上轮子 agent 被用户中断，redteam 方式待与开发者确认。

## 2026-06-06 17:15 · [对抗/异常] redteam-1：攻破 3 处 + 1 低危
- 背景：开发者选"主 agent 直接压测"，红军一轮。报告 rehearsals/redteam-1.md。
- 内容：
  - **B1**（中高危）：调查分队并行子 agent 与日志采集撞车——未明令"集中采集、子 agent 只读分析、禁自行跑复现/起 sink"。
  - **B2**（高危·安全）：自动采集日志常含密钥/PII，落点在 git 仓内 docs/sandtable，"默认不提交"无强制 → 要么提交泄密、要么自动改用户 .gitignore 越界。需开发者裁决落点策略。
  - **B3**（中危）：/sandtable-bug 假设有 feature 目录；对未走过 sandtable 的代码报 bug 时无家可归、卡入口。
  - **B4**（低危）：feedforward"必读 lessons.md"未处理文件不存在；应"若存在则读"+按需创建。
  - 蓝军扛住：phase 枚举解析、擅改 constraints、需求背离（除上述洞）。
- 依据/来源：rehearsals/redteam-1.md；state-and-memory:8；sandtable-init.sh:94-98。
- 下一步：B2 问开发者（Q19 落点策略）；B1/B3/B4 提修复方案；裁决后修 prd/tests/plan，从 mental 重新验证。

## 2026-06-06 17:30 · [对抗/决策] Q19/Q20=A 修 4 破口 + redteam-2 复攻 HELD
- 背景：开发者 Q19=A（日志放仓库外，绝不入库）、Q20=A（无 feature 自动建轻量 bugfix feature）。B1/B4 按主 agent 提案修。
- 内容：
  - 修 B2：prd FR-BUGFIX-COLLECT 落点改"仓库外/临时目录、绝不 git add、不改用户 .gitignore"；plan T2 采集表落点改 `<scratch>`、T4 目录结构去掉 logs/、feedback 模板日志来源改仓库外。
  - 修 B1：prd FR-BUGFIX-SQUAD + plan T2/investigator-prompt 明确"采集集中、子 agent 只读、禁自行跑复现/起 sink"。
  - 修 B3：prd FR-FEEDBACK-SKILL + plan T1/T5 "无 feature 自动建 <date>-bugfix-<slug>"。
  - 修 B4：prd FR-FEEDFORWARD + plan T8 "若存在 lessons.md 则读"；T1 "首次沉淀按需创建 lessons.md"。
  - tests：TC16 改"日志仓库外绝不入库"、TC17 加"集中采集+只读"、新增 TC27（无 feature 自动建）、TC28（lessons 不存在跳过）；TC1–TC28。
  - redteam-2 复攻 4 点全 HELD，无新杀招（报告 rehearsals/redteam-2.md）；记 2 残余风险（R1 仓库外日志非持久—feedback.md 摘录兜底；R2 自动建 feature 命名—复用 init 幂等）。
- 依据/来源：questions Q19/Q20；rehearsals/redteam-1.md、redteam-2.md。
- 下一步：实现预演（impl）——方式（worktree best-of-N vs 直接实现）待与开发者确认。

## 2026-06-06 17:50 · [集成] 单一实现完成于分支 sandtable/post-landing-loop
- 背景：开发者选"单一实现"。在分支按 plan T1–T8 实现。
- 内容：
  - 落地：2 新 skill×4 根(+investigator-prompt)、2 命令×6 根、templates/{feedback,lessons}.md、init 中英加 lessons.md(幂等,bash -n 过)、FEEDBACK 写入 7 源(中英)、M2 恢复分支补丁、3 处教训反哺交叉引用(中英)。
  - 校验：TC1–TC28 结构性脚本全绿（skill/命令/模板存在、FEEDBACK 各源命中、lessons 交叉引用、init lessons.md）。报告 rehearsals/impl-1-post-landing-loop.md，impl.last=done。
  - 注意：工作树原有未提交改动（closing-the-loop 等，全部命令 M）随分支带入，非本实现产物；合并时需区分。未提交（仅在分支工作树）。
- 依据/来源：本轮实现编辑 + git status + bash -n。
- 下一步：开发者验收（VERIFY）+ 决定是否合并到 main（INTEGRATE）。未经允许不提交。

## 2026-06-06 18:00 · [集成] 已合并到 main
- 背景：开发者选"合并到 main"。
- 内容：因 closing-the-loop 未提交改动与本需求共用文件（using-sandtable/state-and-memory），工作树无法非交互式按需求拆分；故 `git add -A` 提交全部工作树为单 commit `7879e71`，并 `git checkout main && git merge --ff-only` 快进合并。main 现领先 origin/main 1 个 commit，**未 push**（未获授权）。commit message 已注明本 commit 同时打包了 closing-the-loop 在制改动与 closed-loop-guidance/superpowers-harness-parity 的规划文档。
- 依据/来源：git commit 7879e71；git merge --ff-only。
- 状态：phase=DONE。如需可按需进入 FEEDBACK（/sandtable-bug）继续落地后闭环；push 待开发者指令。
