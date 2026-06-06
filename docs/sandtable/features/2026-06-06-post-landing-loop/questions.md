# 待开发者澄清 · Questions

> 仅放"读代码、读文档都无法确定，必须开发者拍板"的阻塞性问题。
> 有未解决的问题时，state.md 的 blocked 应为 true。

## Q1 范围拆分（状态：已答复）
- 问题：bug report 与 debug 模式，作为一个 feature 两个 skill，还是拆成两个独立 feature？
- 开发者答复：**A** — 单 feature + 两个 skill，共享"落地后闭环"主干。
- 已写回：prd.md §目标/§功能需求；journal 2026-06-06 15:05。

## Q2 状态机是否新增 phase（状态：已答复）
- 问题：是否在 DONE 之后新增显式 `FEEDBACK` 阶段并回环？
- 开发者答复：**A** — 新增 `FEEDBACK` 阶段，DONE 后可重入（授权改动 state-and-memory / using-sandtable 等核心文本）。
- 已写回：prd.md §功能需求 FR-PHASE；journal 2026-06-06 15:05。

## Q3 反馈产物落点（状态：已答复）
- 问题：验收反馈/bug 记录放哪？
- 开发者答复：**A** — per-feature `feedback.md` 台账 + 回写该 feature 的 `tests.md` 回归用例。
- 已写回：prd.md §功能需求 FR-ARTIFACT。

## Q4 是否新增 slash 命令（状态：已答复）
- 问题：是否新增 debug/bug 命令？
- 开发者答复：**A** — 两个都加：`/sandtable-debug` 与 `/sandtable-bug`。
- 已写回：prd.md §功能需求 FR-CMD。

## Q5 debug 日志纪律（状态：已答复）
- 问题：三条日志硬门禁是否认可？
- 开发者答复：**A** — 三条全部作为硬门禁（复用自带框架/统一 tag/根因后清理）。
- 已写回：prd.md §功能需求 FR-DEBUG-GATE。

## Q6 自动收集日志——Sandtable 是否捆绑工具（状态：已答复）
- 开发者答复：**A** — 纯 skill 指引；采集发生在用户项目、用其自带工具链，临时 sink 用完即清，护零依赖。
- 已写回：prd.md FR-DEBUG-COLLECT、非目标修订；journal 2026-06-06 15:45。

## Q7 日志落点约定（状态：已答复）
- 开发者答复：**A** — per-feature `logs/` 暂存目录，默认不提交，feedback.md 只记来源与关键摘录。
- 已写回：prd.md FR-DEBUG-COLLECT；plan.md T2/T3；tests.md TC16。

## Q8 调查红军分队——编排归属（状态：已答复）
- 开发者答复：**A** — 并入 `debugging-with-evidence`，新增「调查分队」节 + 派发 prompt，复用并行隔离纪律。
- 已写回：prd.md FR-DEBUG-SQUAD；plan.md T2。

## Q9 自动收集纪律 + 调查分队并行数（状态：已答复）
- 开发者答复：**A** — 两条纪律全认可，非平凡缺陷默认 N=3 并行调查（与 redteam min_agents 一致）。
- 已写回：prd.md FR-DEBUG-COLLECT/FR-DEBUG-SQUAD；tests.md TC15/TC17。

## Q10 反馈生命周期 + 用户确认关闭（状态：已答复）
- 开发者答复：**A** — `OPEN→TRIAGED→INVESTIGATING(可反复)→ROOT_CAUSED→FIXING→VERIFYING→USER_CONFIRMED→CLOSED`，未经用户确认不得 CLOSED。
- 已写回：prd.md FR-LIFECYCLE；tests.md TC19；plan.md T1/T3。

## Q11 关闭强制三件套（状态：已答复）
- 开发者答复：**A** — 根因 + 怎么预防 + 吸取的教训 三件套强制。
- 已写回：prd.md FR-LESSONS；tests.md TC20；plan.md T1/T3。

## Q12 教训沉淀落点（状态：已答复）
- 开发者答复：**A** — 新增全局 `docs/sandtable/lessons.md` 跨 feature 累积 + 关闭时给 `constraints.md`/RECON 候选更新。
- 已写回：prd.md FR-LESSONS；plan.md T8（含 init 脚本全局循环加 lessons.md）；tests.md TC21。

## Q13 教训反哺未来推演（状态：已答复）
- 开发者答复：**A** — `gathering-intel`/`red-team-wargame`/`writing-prd` 开新需求时必读 `lessons.md`。
- 已写回：prd.md FR-FEEDFORWARD；plan.md T8；tests.md TC22。

## Q14 debug→bugfix 改名范围（状态：已答复）
- 开发者答复：**A** — 全套改名：skill `bugfix-with-evidence`、命令 `/sandtable-bugfix`、tag `[SANDTABLE-BUGFIX:<id>]`；`/sandtable-bug`(报障) 与 `/sandtable-bugfix`(修障) 并存。
- 已写回：prd/tests/plan 全量改名（journal 2026-06-06 16:25）。

## Q15 根因必须靠日志100%确认（状态：已答复）
- 开发者答复：**A** — 列为最高优先硬门禁；窄例外=纯静态可判定缺陷且需说明。
- 已写回：prd.md FR-BUGFIX-GATE 1 / FR-BUGFIX-SKILL；tests.md TC23；plan.md T2。

## Q16 排查动用推演武器库 + 广深发散（状态：已答复）
- 开发者答复：**A**（"活跃"改"发散"）— 调查可采 mental/recon/红军姿态，红军证伪候选根因；思维广+深+发散。
- 已写回：prd.md FR-BUGFIX-SQUAD；tests.md TC24；plan.md T2。

## Q17 FEEDBACK 与 autopilot 的关系（mental-1 M1，状态：待答复）
- 问题：FEEDBACK（落地后验收闭环）是否定性为"**人在环、始终 manual 风格**"——即 autopilot **不驱动** FEEDBACK，"等待用户确认收敛"是合法停点（按 blocked/收尾处理）？
- 为什么阻塞：FR-LIFECYCLE"用户确认才关闭"与 autopilot"非阻塞自动续跑"交互未定义，会导致 agent 擅自关闭或卡死。
- 可选项：A. 是，FEEDBACK 人在环、autopilot 不驱动；autopilot 范围维持到 EVALUATE/DONE，FEEDBACK 由 `/sandtable-bug`、`/sandtable-bugfix` 手动进入；"等待确认"=合法停点（推荐）。B. autopilot 也可驱动 bugfix 调查取证，但**关闭前必停**等用户确认（半自动）。C. 其他（我说明）。
- 开发者答复：**A** — FEEDBACK 人在环，autopilot 不驱动，等待确认=合法停点。
- 已写回：prd.md FR-LIFECYCLE；plan.md T1/T4（state-and-memory 恢复分支补 FEEDBACK，修 M2）；tests.md TC26。

## Q18 日志确实拿不到时的出路（mental-1 M3，状态：待答复）
- 问题："根因必靠日志100%"在**既不能自动采、用户也给不出、又非纯静态可判定**时，如何收口避免死锁？
- 可选项：A. 升级为 blocked、写 `questions.md` 问开发者（要么补日志手段、要么由开发者决定降级），不擅自降级（推荐：守住"100%"字面）。B. 允许"最佳可得证据 + 显式标注残余不确定 + 开发者签字"降级关闭（会削弱100%）。C. 其他（我说明）。
- 开发者答复：**A** — 拿不到日志即升级 blocked 问开发者，不擅自降级。
- 已写回：prd.md FR-BUGFIX-GATE/FR-BUGFIX-COLLECT；plan.md T2；tests.md TC25。

## Q19 日志落点与机密安全（redteam-1 B2，状态：待答复）
- 问题：自动采集的日志常含密钥/PII，现落点 `docs/sandtable/features/<id>/logs/` 在 git 仓内（docs/sandtable 是提交进 git 的记忆），"默认不提交"无强制 → 风险：提交泄密 / 或自动改用户 .gitignore 越界。怎么定？
- 可选项：A. logs/ 改放**仓库外/临时目录**（系统 temp 或项目外 scratch），`feedback.md` 只引用路径+关键摘录，证据出处用行号；agent 绝不入库日志原文（推荐：从源头杜绝泄密）。B. 保留 feature 内 `logs/`，但**硬纪律**：绝不 `git add` logs/、采集后做机密扫描/提示、建议用户自行 gitignore（不自动改）。C. 其他（我说明）。
- 开发者答复：**A** — logs 放仓库外/临时目录，feedback.md 只引用路径+摘录，绝不入库原文。
- 已写回：prd FR-BUGFIX-COLLECT；plan T2/T4（state-and-memory 不再列 logs/）；tests TC16。

## Q20 无 feature 时 bug 的落点（redteam-1 B3，状态：待答复）
- 问题：对**从未走过 sandtable** 的代码报 bug 时，没有 feature 目录，`/sandtable-bug` 卡在第一步。怎么收口？
- 可选项：A. 自动新建一个轻量 feature `<date>-bugfix-<slug>`（最小 state/feedback），把它当作一次正常 feature 走闭环（推荐：统一、可追溯）。B. 设全局 `docs/sandtable/feedback-inbox.md` 暂收，再按需归集到 feature。C. 直接拒绝并提示先建 feature。
- 开发者答复：**A** — 无 feature 时自动新建轻量 `<date>-bugfix-<slug>` 走闭环。
- 已写回：prd FR-FEEDBACK-SKILL/FR-CMD；plan T5；tests TC27。

## B1/B4 修复（主 agent 提案，待确认，无需单列问题）
- B1：在 bugfix skill 与 investigator-prompt 明确"采集集中由主 agent 先做、调查子 agent 只读分析、禁自行跑复现/起 sink"。
- B4：FR-FEEDFORWARD 改"**若存在** lessons.md 则读"；triaging-feedback 首次沉淀教训时按需创建 lessons.md。
- 如无异议将随 Q19/Q20 一并写入 prd/tests/plan。
