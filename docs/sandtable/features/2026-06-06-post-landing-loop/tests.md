# 测试用例 · 落地后闭环（验收反馈 + bugfix 模式）

> tests.md = 理解闸门（先读）。PRD §验收标准 = 完成闸门（VERIFY 勾选）。
> 黑盒 Given/When/Then，技术栈无关；每条映射回 PRD 的 FR / 验收 / MUST / MUST NOT。

## TC1 · `/sandtable-bug` 受理验收反馈并落 `feedback.md`

- **映射**: FR-CMD, FR-ARTIFACT；验收「能落进对应 feature 的 feedback.md」
- **Given**: feature `X` 已 `phase=DONE`；开发者验收发现"点击保存后列表不刷新"。
- **When**: 开发者发送 `/sandtable-bug` 并描述该现象。
- **Then**: 主 agent 在 `docs/sandtable/features/X/feedback.md` 追加一条 bug 节，含字段：`id`(如 BUG1)、来源(验收)、复现步骤、期望(列表刷新)/实际(不刷新)、严重度、分诊结论(待填)；并把 `state.md` 的 `phase` 置为 `FEEDBACK`、`updated` 刷新；journal 追加一条 `[反馈]`。不直接开始改代码。
- **状态**: 待验证

## TC2 · `triaging-feedback` 把反馈分诊为三类

- **映射**: FR-FEEDBACK-SKILL
- **Given**: `feedback.md` 有一条新 bug（期望/实际已填）。
- **When**: 主 agent 加载 `triaging-feedback` 做分诊。
- **Then**: 分诊结论必为三类之一并写回该 bug 节：①真缺陷（须转 bugfix）②漏需求（回退 OBJECTIVES 补 PRD/用例）③误解或预期内（说明为何、不改代码）；分诊依据标注来源（`file:line` 或 PRD 条目），不凭空判定。
- **状态**: 待验证

## TC3 · 缺陷类必经 bugfix 根因，禁止跳过

- **映射**: FR-FEEDBACK-SKILL, MUST「缺陷类必经根因再修复」
- **Given**: 一条 bug 分诊为"真缺陷"。
- **When**: 主 agent 准备处理它。
- **Then**: **必须**先转入 `bugfix-with-evidence`（或 `/sandtable-bugfix`）走根因闭环；在根因未锁定前，禁止出现"直接改某行试试"的修复动作；`feedback.md` 的"根因"字段在修复前不得为空。
- **状态**: 待验证

## TC4 · `/sandtable-bugfix` 不猜测：假设清单 + 取证 + 锁根因

- **映射**: FR-BUGFIX-SKILL；验收「全程不靠猜」
- **Given**: 一个"保存后列表不刷新"的缺陷，原因未知。
- **When**: 开发者发送 `/sandtable-bugfix` 处理它。
- **Then**: 主 agent 产出（a）期望 vs 实际的明确表述；（b）**≥2 条**并列假设（不默默选一个）；（c）插桩取证计划；（d）依据日志/`file:line` 证据**逐一证伪**假设直到锁定单一根因；（e）根因表述含完整因果链与证据出处。仅凭"我觉得是 X"无证据即下结论 = 不通过。
- **状态**: 待验证

## TC5 · bugfix 日志门禁①：复用工程自带日志框架，禁裸 print

- **映射**: FR-BUGFIX-GATE 条1, MUST NOT
- **Given**: 目标项目已有日志框架（如存在统一 logger / 日志约定）。
- **When**: 主 agent 为排障插桩。
- **Then**: 新增日志**调用该项目自带日志框架**（与既有日志同风格/同入口）；**不得**用裸 `print`/`console.log` 等临时输出冒充（除非该项目本就以此为约定，且需说明）。
- **状态**: 待验证

## TC6 · bugfix 日志门禁②：统一可 grep tag

- **映射**: FR-BUGFIX-GATE 条2
- **Given**: 正在排查 feature `X` 的 BUG1。
- **When**: 主 agent 插入若干临时日志。
- **Then**: 每条新增日志带统一前缀 `[SANDTABLE-BUGFIX:X-BUG1]`（或等义 `<feature-or-bug-id>`）；开发者可用一次 grep 检索到本次全部插桩点。
- **状态**: 待验证

## TC7 · bugfix 日志门禁③：根因确认后清理临时日志

- **映射**: FR-BUGFIX-GATE 条3；验收「临时日志被清理」
- **Given**: 根因已锁定、修复已验证、复现消失。
- **When**: 主 agent 收尾。
- **Then**: 按 `[SANDTABLE-BUGFIX:...]` tag 移除本次新增的临时日志；确有长期价值需保留的，**显式说明**并改为项目正式日志（去掉 SANDTABLE-BUGFIX 临时 tag），不残留临时 tag。
- **状态**: 待验证

## TC8 · 禁表面修复 / 临时修复

- **映射**: MUST NOT「禁表面/临时修复」
- **Given**: 缺陷根因为"保存后未触发列表数据重取"。
- **When**: 主 agent 给修复方案。
- **Then**: 修复针对**根因**（修复数据重取/通知链路）；**不得**采用：吞异常(try/catch 静默)、`sleep`/定时器规避时序、注释掉报错、仅改症状文案等临时手法；若只能临时缓解，须显式标注并仍要求根因修复跟进。
- **状态**: 待验证

## TC9 · 修复闭合产出回归用例 + 加固结论

- **映射**: FR-FEEDBACK-SKILL, FR-ARTIFACT；验收「交付含回归用例+加固结论」
- **Given**: BUG1 根因已修复并验证。
- **When**: 主 agent 关闭该反馈。
- **Then**: （a）向该 feature 的 `tests.md` 追加一条回归用例（Given/When/Then，复现该 bug 的场景，状态置"已验证"），**不另起台账**；（b）`feedback.md` 该 bug 节填入"加固结论"，回答"**为什么推演没逮到它**"并指向具体补强点（RECON 清单项 / `constraints.md` 红线 / 红军战术之一）；（c）journal 追加 `[集成]`/`[决策]` 记录。
- **状态**: 待验证

## TC10 · `FEEDBACK` 阶段在各单一事实来源一致可见

- **映射**: FR-PHASE, FR-INDEX；验收「FEEDBACK 一致可见无矛盾」
- **Given**: 开发者抽查状态机相关文件。
- **When**: 对照 `skills/state-and-memory/SKILL.md` 的 phase 枚举、`skills/using-sandtable/SKILL.md` 状态机图/阶段表、`.cursor/rules/sandtable.mdc`、`AGENTS.md`、`skills/closing-the-loop/SKILL.md` 的 phase→下一步映射、`templates/state.md` 注释。
- **Then**: 每处都含 `FEEDBACK`，语义一致（DONE 后可重入；缺陷类回环 bugfix→修复→回归→加固）；`closing-the-loop` 映射表有 `FEEDBACK` 行指向 `/sandtable-bug`/`/sandtable-bugfix`；无任一处遗漏或相互矛盾的下一步。
- **状态**: 待验证

## TC11 · 全镜像 + 英文等义

- **映射**: FR-MIRROR；MUST「同步 plugins/ 与 locales/en/」
- **Given**: 用户用英文官方提示词安装。
- **When**: 检查镜像。
- **Then**: 两个新 skill 存在于 4 个 skill 根（`skills/`、`plugins/sandtable/skills/`、`locales/en/skills/`、`locales/en/plugins/sandtable/skills/`）；两个新命令存在于 6 个 command 根；`templates/feedback.md`（及英文镜像，如适用）齐备；英文镜像正文为英文，slash 名仍为 `/sandtable-*`、日志 tag 仍为 `[SANDTABLE-BUGFIX:<id>]`；语义与中文等义。
- **状态**: 待验证

## TC12 · 边界：非缺陷反馈不强行进 bugfix

- **映射**: FR-FEEDBACK-SKILL 边界
- **Given**: 验收反馈实为"理解偏差/预期内行为"（如开发者误读需求）。
- **When**: 分诊判定为"误解或预期内"。
- **Then**: **不**进入 bugfix 根因流程；在 `feedback.md` 说明原因与依据；若属"漏需求"，则回退 OBJECTIVES 补 PRD/用例，而非 bugfix。
- **状态**: 待验证

## TC13 · 边界：项目无统一日志框架时的降级

- **映射**: FR-BUGFIX-GATE 条1 边界
- **Given**: 目标项目无统一日志框架/约定（侦察后确认）。
- **When**: 主 agent 需要插桩。
- **Then**: 降级到该语言**惯用**日志方式（仍带统一 tag、仍可清理），并在 `feedback.md`/journal 说明"项目无统一框架，已降级到 X"；不把"无框架"当作裸 print 不清理的借口。
- **状态**: 待验证

## TC14 · 非 Sandtable 排障不强加流程

- **映射**: MUST NOT「不为普通排障强加流程」；与 closing-the-loop 第三态一致
- **Given**: 开发者在一个**非 Sandtable** 上下文随口问"这个报错咋回事"，本回合非 Sandtable 工作步。
- **When**: 主 agent 协助排查。
- **Then**: 可自愿借鉴 bugfix 思路，但**不强制**落 `feedback.md`、不强制走 FEEDBACK 阶段收尾、不要求开发者发 `/sandtable-bugfix`；仅当处于某 feature 的 Sandtable 工作步时才强约束闭环。
- **状态**: 待验证

## TC15 · bugfix 先自动收集日志，不打扰用户

- **映射**: FR-BUGFIX-COLLECT；验收「优先自动收集」
- **Given**: 目标项目是一个 Android 工程，缺陷为"某操作后崩溃"，且环境有 `adb` 可用（侦察确认）。
- **When**: 开发者发 `/sandtable-bugfix` 处理它。
- **Then**: 主 agent **不**第一句就让用户"把日志发我"；而是判断可自动采集，给出/执行采集动作（如 `adb logcat -d > docs/sandtable/features/<id>/logs/logcat.txt`），从采集到的日志取证；仅当确认 agent 无法自取时才请用户提供，并给现成导出命令与落点。
- **状态**: 待验证

## TC16 · 日志落仓库外、绝不入库（修 redteam-1 B2，安全）

- **映射**: FR-BUGFIX-COLLECT 落点约定；Q19=A
- **Given**: 一次排障采集到 `logcat.txt`（含一个 access token），用户另丢了一个 `crash.zip`。
- **When**: 主 agent 处理这些日志。
- **Then**: 文件落在**仓库外/临时目录**（如 `$TMPDIR/sandtable-logs/<feature>/`），**不在 git 仓内**；`feedback.md` 只写**来源 + 关键摘录 + 证据出处（行号/时间戳）**；agent **绝不 `git add` 日志原文**、**不**把日志放进 `docs/sandtable/`、**不**自动改用户 `.gitignore`；那个 token 不会进入 git 历史。
- **状态**: 待验证

## TC17 · 非平凡缺陷派 ≥3 个并行调查子 agent 多角度深挖

- **映射**: FR-BUGFIX-SQUAD；验收「派 ≥3 调查子 agent」
- **Given**: 一个"难复现、疑似跨子系统"的缺陷。
- **When**: 主 agent 启动 `bugfix-with-evidence` 的调查分队。
- **Then**: 默认派 **≥3** 个**并行**调查子 agent，各指派不同角度（如时序 / 数据流 / 依赖与配置 / 并发 / 外部 IO）；**日志采集由主 agent 集中先做一次**，子 agent 是**只读分析者**（禁止各自跑复现/起 sink，避免争抢设备/端口）；每个回报**带证据**的发现（`file:line`/日志），不接受空泛猜测；主 agent **汇总并亲自核实**，锁定**单一根因**，不直接采信某一子 agent 的结论。平凡缺陷（一眼定位）允许单线、不强派。
- **状态**: 待验证

## TC18 · Sandtable 不捆绑采集工具（纯 skill 指引边界）

- **映射**: FR-BUGFIX-COLLECT 边界；MUST NOT「不捆绑 server/脚本」；constraints 零依赖
- **Given**: 开发者检查本 feature 的全部新增交付物。
- **When**: 审查是否引入了可执行的日志 server / 采集脚本 / 自动插桩工具。
- **Then**: 交付物**只有 markdown**（skill / 命令 / 模板）；**无**随 Sandtable 分发的 node/python/server/采集脚本；采集策略以 skill 文字指引存在；临时 sink 在用户项目内用用户技术栈临时搭建并要求清理。
- **状态**: 待验证

## TC19 · 反馈生命周期反复 + 用户确认才关闭

- **映射**: FR-LIFECYCLE；验收「未经用户确认不得关闭」
- **Given**: BUG1 已 `ROOT_CAUSED→FIXING→VERIFYING`，agent 认为已修复。
- **When**: agent 想结束这条反馈。
- **Then**: 若复现仍在 → 状态弹回 `INVESTIGATING`（承认反复），不得置 CLOSED；若复现消失 → 状态置 `VERIFYING` 完成并**请用户确认收敛**，在用户明确确认前**不得**置 `USER_CONFIRMED`/`CLOSED`；feedback.md 的状态字段如实反映当前生命周期阶段（不得 agent 自行宣布"已解决"而关闭）。
- **状态**: 待验证

## TC20 · 关闭强制三件套（根因+预防+教训）

- **映射**: FR-LESSONS；验收「关闭必产出三件套」
- **Given**: BUG1 已 `USER_CONFIRMED`。
- **When**: agent 关闭它。
- **Then**: feedback.md 该 bug 节必须**同时**含非空：**根因**（因果链+证据出处）、**怎么预防**（流程/红线/检查项层面措施，非"以后小心"）、**吸取的教训**（一句可复用经验）；缺任一项不得置 `CLOSED`。
- **状态**: 待验证

## TC21 · 教训沉淀进全局 lessons.md + 候选红线

- **映射**: FR-LESSONS；MUST「新增全局 lessons.md」
- **Given**: BUG1 关闭，教训为"保存后未触发列表重取——状态变更未广播"。
- **When**: agent 沉淀教训。
- **Then**: `docs/sandtable/lessons.md` 追加一条（日期、来源 feature/bug、根因摘要、预防、教训、**候选红线/检查项更新建议**）；并向开发者提出对 `constraints.md`（新 MUST，如"状态变更必须广播到依赖视图"）或 RECON 清单（新检查项）的**候选更新**；是否采纳由开发者拍板，agent **不擅自**改 `constraints.md`。`lessons.md` 为跨 feature 累积、与 project/constraints 平级。
- **状态**: 待验证

## TC22 · 开新需求时 RECON/红军/PRD 读 lessons.md

- **映射**: FR-FEEDFORWARD；验收「过去的 bug 武装未来推演」
- **Given**: `lessons.md` 已有上条"状态变更未广播"教训；开发者开一个**新** feature。
- **When**: 该新 feature 走 RECON / 红蓝对抗 / 写 PRD。
- **Then**: `gathering-intel` 在侦察时读 `lessons.md` 并把相关教训列为本次检查项；`red-team-wargame` 把历史教训作为一个攻击向量来打；`writing-prd` 据此评估是否需要对应红线——三处均能引用到 `lessons.md`，不是孤立死档。
- **状态**: 待验证

## TC23 · 根因必须靠日志/运行时证据 100% 确认（只读代码不算）

- **映射**: FR-BUGFIX-GATE 条1（最根本）；开发者「只靠看代码不行，必须配合日志 100% 确定根因」
- **Given**: 一个运行时缺陷，agent 读代码后形成一个"看起来很像根因"的判断，但尚无日志/运行时证据。
- **When**: agent 想据此锁定根因并开始修复。
- **Then**: **不得**仅凭代码推断置为"已确认根因"；必须先用日志/运行时证据贯通因果链（插桩复现取证）才可锁定；`feedback.md` 的根因字段须带**日志证据出处**（行号/时间戳），非仅 `file:line` 推断。唯一窄例外：缺陷本质纯静态可判定（编译/类型/明显笔误）且已说明——此时仍需说明为何无需运行时证据。
- **状态**: 待验证

## TC24 · 排查动用推演武器库（mental/recon/红军证伪），广+深+发散

- **映射**: FR-BUGFIX-SQUAD（推演武器）；开发者「可走头脑推演、侦查、红军，思维广深发散」
- **Given**: 一个难复现、疑似多因素的缺陷。
- **When**: agent 启动 bugfix 调查。
- **Then**: 调查体现**广**（多角度并行）、**深**（追到根因非症状）、**发散**（先大胆列假设不过早收敛）；可调用头脑预演推因果链、`gathering-intel` 摸日志/数据流地形、**红军证伪候选根因**（对"这是根因吗"发起攻击，攻不破——举不出反例——才采信）；红军成功举出反例即视为该候选根因被推翻，回到取证。
- **状态**: 待验证

## TC25 · 日志确实拿不到时升级 blocked，不擅自降级（修 mental-1 M3）

- **映射**: FR-BUGFIX-GATE 1 / FR-BUGFIX-COLLECT 无日志出路；Q18=A
- **Given**: 一个运行时缺陷，agent 既无法自动采集日志（无 adb/无日志文件/不能复现），用户也提供不出，且缺陷**非**纯静态可判定。
- **When**: agent 想推进到锁定根因/关闭。
- **Then**: **不得**仅凭代码推断锁根因，**也不得**降级关闭；必须置 `state.md` `blocked=true`、在 `questions.md` 写一条阻塞问题问开发者（补日志手段，或由开发者裁决处置）；反馈生命周期停在 INVESTIGATING，不前进到 ROOT_CAUSED/CLOSED。
- **状态**: 待验证

## TC26 · FEEDBACK 人在环：autopilot 不驱动、恢复按 phase（修 mental-1 M1/M2）

- **映射**: FR-LIFECYCLE（Q17=A）；与 `autonomous-orchestration` 一致
- **Given**: feature `X` 已 `phase=FEEDBACK`、`autonomy.mode=autopilot`（历史遗留）、三类配额早已达标；有一条反馈处于 VERIFYING 等待用户确认收敛。
- **When**: 用户 `/sandtable-resume` 或触发续跑。
- **Then**: 恢复逻辑**按 phase=FEEDBACK 恢复**，**不**因配额已达标而路由回 `EVALUATE`；autopilot **不自动驱动** FEEDBACK 闭环、**不擅自关闭**那条等待确认的反馈；"等待用户确认收敛"被当作合法停点（可 blocked 或收尾提示），由 `/sandtable-bug`/`/sandtable-bugfix` 手动推进。
- **状态**: 待验证

## TC27 · 无 feature 时报 bug 自动建轻量 feature（修 redteam-1 B3）

- **映射**: FR-FEEDBACK-SKILL 无 feature 兜底；Q20=A
- **Given**: 用户对一段**从未走过 sandtable** 的代码执行 `/sandtable-bug` 报一个问题，`docs/sandtable/features/` 下无对应目录。
- **When**: 主 agent 受理。
- **Then**: 自动新建轻量 feature `<date>-bugfix-<slug>`（最小 state.md/feedback.md），把反馈落入其 `feedback.md` 并正常分诊，不卡在"找不到 feature"；不要求用户先手动建 feature。
- **状态**: 待验证

## TC28 · feedforward 在 lessons.md 不存在时跳过不报错（修 redteam-1 B4）

- **映射**: FR-FEEDFORWARD 边界
- **Given**: 全新项目，`docs/sandtable/lessons.md` 尚不存在。
- **When**: 该项目开新需求走 RECON / 红蓝对抗 / 写 PRD。
- **Then**: 三处"读 lessons.md"为**若存在则读**，不存在则**安静跳过**、不报错、不阻塞；待首次反馈关闭沉淀教训时由 `triaging-feedback` 按需创建 `lessons.md`。
- **状态**: 待验证
