# 红蓝对抗战报 · redteam-2（修正后复攻，主 agent）

> 对 redteam-1 的 4 处攻破点复攻，并扫描修正是否引入新破口。
> 结论：**HELD**（B1/B2/B3/B4 已扛住；无新可复现杀招；记 2 条残余风险）。

## B1 复攻（调查并行撞车）→ HELD
- 现纪律：采集集中由主 agent 先做一次落 `<scratch>`，调查子 agent 只读分析、禁跑复现/起 sink。`[prd FR-BUGFIX-SQUAD; plan T2 investigator-prompt]` 并行不再争抢设备/端口。攻不动。

## B2 复攻（日志泄密）→ HELD
- 现纪律：日志落**仓库外/临时目录**，绝不 `git add`、不放 docs/sandtable、不自动改用户 .gitignore；feedback.md 只存摘录+行号。`[prd FR-BUGFIX-COLLECT; plan T2/T4]` 密钥不入库。攻不动。

## B3 复攻（无 feature 报障）→ HELD
- 现纪律：无对应 feature 时自动新建轻量 `<date>-bugfix-<slug>` 再受理。`[prd FR-FEEDBACK-SKILL; plan T1/T5]` 入口不再卡死。攻不动。

## B4 复攻（lessons.md 不存在）→ HELD
- 现纪律：三处"若存在 lessons.md 则读"，不存在静默跳过；triaging-feedback 首次沉淀按需创建。`[prd FR-FEEDFORWARD; plan T1/T8]` 攻不动。

## 新破口扫描（修正是否引入新问题）→ 未发现可复现杀招
- "日志在仓库外/临时目录"→ 原始日志易随机器/时间丢失：但 feedback.md 保留关键摘录+证据出处（行号/时间戳），**durable 记录在 feedback.md**，原文短暂可接受且更安全。记残余风险 R1。
- "自动建 `<date>-bugfix-<slug>`"→ 可能与已存在同名目录冲突：复用 init 幂等守卫（已存在则不覆盖/换 slug）。记残余风险 R2，实现时遵循 init 幂等。

## 残余风险（不阻断）
- R1：仓库外日志原文非持久——已用 feedback.md 摘录+行号兜底，可接受。
- R2：自动建 feature 命名冲突——实现复用 sandtable-init 幂等逻辑即可。
