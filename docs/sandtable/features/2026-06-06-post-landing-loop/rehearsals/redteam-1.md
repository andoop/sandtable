# 红蓝对抗战报 · redteam-1（主 agent 一轮压测）

> 蓝军=本 feature 的设计/计划。红军沿多个攻击向量找可复现杀招。
> 结论：**BREACH_FOUND ×3（B1/B2/B3 成立）+ 1 低危（B4）**。链路暂停，待裁决/修正后从 mental 重新验证。

## B1 · 侧翼包抄/边界突袭（成立，中高危）：调查分队并行子 agent 与日志采集会撞车
- 杀招：FR-BUGFIX-SQUAD 默认派 ≥3 个并行调查子 agent。若每个子 agent 各自"跑复现/起 log sink"取证，会争抢同一设备（adb 单连接）、端口（sink）、日志文件 → 互相污染、结果不可信；且"跑复现/起 sink"是副作用操作，与"只读分析"矛盾。
- 证据：`investigator-prompt` 写了"已采集日志：<logs/路径>"（暗示集中采集），但**未明令**子 agent"只读分析、禁止自行跑复现/起 sink"；FR-BUGFIX-SQUAD 也未规定采集归属。`[plan.md T2 investigator-prompt; prd.md FR-BUGFIX-SQUAD]`
- 影响：并发取证撞车、证据污染、与实现预演不同（impl 用独立 worktree 隔离，调查无隔离设计）。
- 建议修：明确"**采集集中由主 agent 先做一次**，落 logs/；调查子 agent 是**只读分析者**，禁止自行跑复现/起 sink"。

## B2 · 红线渗透（成立，高危·安全）：自动采集的日志含密钥/PII，落在 git 仓内会被提交泄漏
- 杀招：自动采集（logcat、log.zip）常含 token/密钥/PII。落点 `docs/sandtable/features/<id>/logs/` **在 git 仓内**，而 `docs/sandtable/` 本就是"提交进 git 的记忆"。"默认不提交"只是建议、**无强制**：要么日志被 `git add` 连同记忆一起提交 → **机密泄漏**；要么 agent 自动改用户 `.gitignore` → **越界改用户仓配置**（范围蔓延 + 触碰 constraints「不破坏用户已存在文件」）。
- 证据：`[prd.md FR-BUGFIX-COLLECT 落点约定]`；`docs/sandtable` 提交语义见 `state-and-memory/SKILL.md:8`。
- 影响：安全事故（密钥入库）或越界。两条路都坏。
- 建议修（需开发者定）：① logs/ 改放**仓库外/临时目录**（如系统 temp 或 `.sandtable-logs/`），feedback.md 只引用路径与摘录；或 ② 保留 feature 内 logs/ 但**硬纪律：agent 绝不 `git add` logs/、并提示用户自行 gitignore（不自动改）、且采集后做机密扫描/提示**。

## B3 · 假设斩首（成立，中危）：/sandtable-bug 假设"当前有 feature 目录"，无 feature 时无家可归
- 杀招：`triaging-feedback`/`/sandtable-bug` 第一步"确认当前 feature"。但用户可能对一段**从未走过 sandtable** 的代码报 bug → 没有 feature 目录，feedback.md 无处落，流程卡在第一步。
- 证据：`[plan.md T5 sandtable-bug 步骤1；T1 受理流程]`。
- 影响：常见场景（验收老代码）直接卡死入口。
- 建议修：定义无 feature 时的落点——新建一个轻量 feature（如 `<date>-bugfix-<slug>`）或允许全局 `docs/sandtable/feedback-inbox.md` 暂收后再归集。

## B4 · 边界（低-中危）：feedforward「必读 lessons.md」未处理"文件不存在"
- 杀招：FR-FEEDFORWARD 让 RECON/红军/PRD"必读 lessons.md"，但全新项目（或 init 未建）尚无 lessons.md → "必读"一个不存在的文件会卡或报错。
- 证据：`[prd.md FR-FEEDFORWARD; plan.md T8]`。
- 建议修：措辞改"**若存在** lessons.md 则读"；并让 triaging-feedback 在首次沉淀教训时**按需创建** lessons.md（不仅靠 init）。

## 未被攻破（蓝军扛住，记为信心依据）
- 反例攻击 phase 枚举解析：init 仅 sed state.md，不强校验枚举，新增 FEEDBACK 不破解析。`[scripts/sandtable-init.sh:94-98]`
- 红线渗透"擅改 constraints"：FR-LESSONS 已限定"只给候选、开发者拍板"，未越界。
- 需求背离：改动虽大但每项可追溯到 FR；非范围蔓延（除上述具体洞）。
