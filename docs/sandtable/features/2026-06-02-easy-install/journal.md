# 记忆日志 · Journal（只增不改）

## 2026-06-02 00:58 · [决策] 立项：安装/上手像 superpowers 一样方便
- 背景：用户需求"让用户用起来方便，想用 superpower 一样安装方便"。
- 内容：选定需求 = 给 Sandtable 增加 superpowers 式的"插件市场一行安装"，取代当前 README 里"手工拷贝目录"的接入方式。
- 依据/来源：`README.md:27-44`（现安装小节为手工拷贝/并入目录）。

## 2026-06-02 01:00 · [推演] RECON 情报简报
### 已确认事实（带来源）
- superpowers 的"安装方便"本质是**插件市场**：用户两行命令
  `/plugin marketplace add obra/superpowers-marketplace` + `/plugin install superpowers@superpowers-marketplace`，并可 `/plugin update` 自动更新。〔来源：obra-superpowers.mintlify.app/installation/claude-code；github.com/obra/superpowers-marketplace README〕
- superpowers 用**独立的 marketplace 仓库**（obra/superpowers-marketplace），其 `.claude-plugin/marketplace.json` 用 `source: {source:"url", url:"https://github.com/obra/superpowers.git"}` 指向插件仓库。〔来源：obra/superpowers-marketplace/main/.claude-plugin/marketplace.json 原文〕
- Claude Code marketplace 机制（官方文档）：
  - 市场清单文件路径固定 `.claude-plugin/marketplace.json`（仓库根）。
  - 每个 plugin 条目至少含 `name` + `source`；可附带 plugin.json 任意字段 + 市场专属字段 `source/category/tags/strict`。`strict` 默认 true=插件自带 plugin.json 管自己的组件。
  - 安装时 Claude Code 把插件目录**整份拷到缓存**，插件不能引用自身目录外的文件（`../` 无效）。
  - 同仓库插件可用相对路径 `"./..."`（须以 `./` 开头，相对"市场根"=含 `.claude-plugin/` 的目录），但**相对路径仅在用户经 Git 添加市场时生效**；经直接 URL 添加 marketplace.json 时相对路径失效。
  - 校验命令：`claude plugin validate .`（校验 marketplace.json）/ `claude plugin validate <plugin-dir>`。
  - 安装命令格式：`/plugin install <plugin-name>@<marketplace-name>`。
  〔来源：code.claude.com/docs/en/plugin-marketplaces 全文，行 86/115/181/188/213/235/250/260/262〕
- 本仓现状：已有 `.claude-plugin/plugin.json`（含 skills/commands/hooks 指向，完整）与 `.cursor-plugin/plugin.json`；`skills/ commands/ hooks/` 均在仓库根。**缺 `.claude-plugin/marketplace.json`**，因此无法被 `/plugin marketplace add` 识别。〔来源：`ls .claude-plugin`、`cat .claude-plugin/plugin.json`〕
- 本仓 git remote = `git@github.com:andoop/sandtable.git`，仅 1 个 commit。〔来源：`git remote -v`、`git log`〕
- Cursor 插件分发现状（官方文档）：插件以 Git 仓库形式分发，公共市场需**提交给 Cursor 团队人工审核**；多插件仓库用 `.cursor-plugin/marketplace.json`；团队市场需 Teams/Enterprise 套餐由管理员导入；个人本地可 symlink 到 `~/.cursor/plugins/local`。**Cursor 没有对任意公共仓库的免审核一行安装**（不同于 Claude Code）。〔来源：cursor.com/docs/plugins；github.com/cursor/plugins README；forum.cursor.com 2.6 团队市场〕

### 设计判断（基于上述事实，避免相对路径边界）
- 单仓库实现"superpowers 式一行装"的最稳方案：在本仓加 `.claude-plugin/marketplace.json`，列一个插件 `sandtable`，`source` 用 **github 源指向本仓自身**（`{source:"github", repo:"andoop/sandtable"}`），而非相对路径 `"./"`——既保持单仓库，又避开"./=市场根作插件"未见示例、相对路径仅 Git 生效等边界。这与 superpowers 用 url/github 源指向插件仓的机制同构，只是市场与插件同处一仓。
- 用户体验对齐 superpowers：`/plugin marketplace add andoop/sandtable` → `/plugin install sandtable@sandtable` → `/plugin update sandtable`。

### 未知 / 待开发者确认（记入 questions.md）
- Q1 仓库 `andoop/sandtable` 是否为 GitHub 公共仓库（一行安装前提）。
- Q2 harness 范围：仅 Claude Code 市场？是否也加 `.cursor-plugin/marketplace.json`（Cursor 公共市场需审核、团队市场需套餐，给不出免审核一行装）？是否要给无插件机制的 harness 一个兜底安装方式？
- Q3 市场名/命令默认 `sandtable`（→ `/plugin install sandtable@sandtable`）是否认可。

## 2026-06-02 01:08 · [问答+决策] 开发者答复，确定范围
- 背景：OBJECTIVES 阶段就 Q1/Q2/Q3 征询开发者。
- 内容：Q1=仓库已公开；Q2=都支持（Claude Code 市场 + Cursor 市场），并额外要"让 AI 阅读、自己把 Sandtable 装成技能"的便捷手动安装说明；Q3=默认 `sandtable`。
- 决策：交付物=`.claude-plugin/marketplace.json` + `.cursor-plugin/marketplace.json` + `INSTALL.md`（面向 AI 的自助安装）+ 重写 README 安装小节。
- 依据/来源：开发者 AskQuestion 答复。

## 2026-06-02 01:08 · [推演] RECON 增补：Cursor marketplace.json schema
- 已确认：Cursor `.cursor-plugin/marketplace.json` 顶层 `name/owner{name,email}/metadata{description}/plugins[]`；plugin 条目 `name/source/description`，`source` 为指向插件目录的相对路径（官方 `cursor/plugins` 用裸子目录名如 `"teaching"`）。〔来源：cursor.com/docs/plugins；cursor/plugins/main/.cursor-plugin/marketplace.json 原文〕
- 残余风险（非阻塞）：本仓为单插件且位于仓库根，`source` 取 `"."`——官方示例只见子目录形式，未见仓库根形式。Cursor 可靠手动路径=本地 symlink 到 `~/.cursor/plugins/local/`；marketplace.json 主供团队市场导入/未来官方上架。决定带 `source:"."` 实现并在 README 以 symlink 为 Cursor 首选可靠路径，留待开发者在真实 Cursor 验证。
- 依据/来源：cursor.com/docs/plugins（"For multi-plugin repositories, add a marketplace manifest at .cursor-plugin/marketplace.json"；本地 symlink 测试流程）。

## 2026-06-02 01:20 · [推演] 头脑预演第 1 轮 — ANOMALY_FOUND（已亲自核实）
- 派发 2 个只读子 agent；A（marketplace.json）因网络中断未返回，B（INSTALL.md+README）返回 ANOMALY_FOUND。
- 主 agent 亲自核实（不轻信）：
  - 异常A（严重·确认）：INSTALL.md 文首红线"禁止覆盖"与步骤 2-3 无条件 `cp -R` 自相矛盾。本机复现：`cp -R src/skills dst/skills`（dst/skills 已存在）→ 生成 `dst/skills/skills/...`（错误嵌套）；`cp file file`（file 已存在）→ 覆盖为 SRCNEW（毁数据）。
  - 异常B（严重·确认）：README `ln -s "$(pwd)/sandtable" ...` 假设 cwd 为仓库父目录；用户在仓库根执行则为悬空路径。应指向仓库根本身。
  - 异常C（中·确认）：手工拷贝兜底漏 `hooks/`，Claude Code 走兜底缺 sessionStart hook（`.cursor-plugin/plugin.json`/旧 README:43 均依赖 hooks）。
  - 疑似D（`<slug>`）：判定为 CLI 参数占位写法，与现有 README:39、sandtable-init.sh 用法一致，非"内容占位符"，保留不改。
  - 疑似E（自查漏 `.cursor/commands`）：补入 T3 自查清单。
- 依据/来源：子 agent ce78e3ca 战报 + 本机 `cp` 复现 + `README.md:27-44` 实读。

## 2026-06-02 01:22 · [决策] 修正计划（异常→修正，未顺手带过）
- T3：INSTALL.md 改为"存在即跳过并上报"的非破坏式（`for d ...; [ -e ./$d ] && 跳过 || cp -R`；Cursor 规则/命令、hooks 均加 `-e` 守卫；CLAUDE.md 用 `[ -e ] || ln -s`）。彻底消除异常A。
- T4：Cursor symlink 改为先 `git clone && cd sandtable` 再 `ln -s "$(pwd)"`（指向仓库根），消除异常B；手工拷贝兜底补 `hooks/` 并注明 Claude Code 依赖，消除异常C。
- T3 自查清单补 `.cursor/commands`、`skills/using-sandtable/SKILL.md`（疑似E）。
- 依据/来源：上述核实结论。

## 2026-06-02 01:32 · [推演] 头脑预演第 2 轮 — 仍 ANOMALY_FOUND（已亲自核实）
- A2（marketplace.json）：T1 Claude **LOGIC_CLOSED**（字段合官方 schema：顶层 owner 必需且本计划已含、email 可省、plugin version 可省；`source:{github,repo}` 合法；`sandtable@sandtable` 自洽；同仓 github 源不冲突）。T2 Cursor **ANOMALY**：`source:"."` 官方零示例，社区报告 Cursor 2.6+ 静默拒绝根级 source，唯一更稳写法需 `metadata.pluginRoot`+迁移到 `plugins/sandtable/`（违反"不重构目录"红线）。
- B2（INSTALL/README）：前轮异常 A/B/C 已确认消除；新发现**异常 F（严重）**：步骤1本地路径回退 + 步骤6 `rm -rf` 组合会删用户源码仓。
- 主 agent 核实：F 属真问题（逻辑可推导，后果=毁用户数据），已修计划（步骤6加"仅删临时 clone"守卫，本地路径跳过）。T2 属产品决策（是否仍交付一个大概率不可用且与红线相关的 Cursor 市场文件）→ 上报开发者。
- 残余风险（记录、不阻塞）：`for f in *.md` nullglob（源恒有匹配，不触发）；断链 CLAUDE.md 的 `ln -s` 报 File exists（低）；`/tmp/sandtable-src` 已存在则 clone 失败（低，报错清晰）。
- 依据/来源：子 agent d35c86c2、bd6bf23f 战报 + 官方 schema 文档（schemastore claude-code-marketplace、cursor/plugins schema）+ 主 agent 核对。

## 2026-06-02 01:38 · [问答+决策] T2 取消（开发者拍板）
- 背景：T2 Cursor marketplace.json 的 `source:"."` 在不破"不重构目录"红线前提下大概率不可用。
- 决策：开发者选 drop——不交付 `.cursor-plugin/marketplace.json`。Cursor 由本地 symlink（官方文档机制）+ 官方市场提交 + INSTALL.md 自助安装支持；已有 `.cursor-plugin/plugin.json` + `.cursor/rules` 不变。
- 影响：PRD FR2 标取消；plan T2 标取消；T5 校验改为单 json + 断言未创建该文件。Claude Code 市场（FR1）+ INSTALL.md（FR3）+ README（FR4）不变。
- 依据/来源：开发者 AskQuestion 答复 = drop。

## 2026-06-02 01:55 · [对抗] 红蓝对抗第 1 轮 — BREACH_FOUND（已亲自核实）
- 红军1（INSTALL.md）：#1 AGENTS.md 合并无守卫（致命）；#2 步骤6 按路径字符串判 provenance 仍可删用户源码（致命）；#3 已有 skills/ 整树跳过 + 步骤5单点检查→假阳性（严重）；附带 cwd/scripts/hooks 边界。
- 红军2（T1+README）：版本双写致 /plugin update 空转（高）；Cursor symlink 不加载 alwaysApply 规则（高）；FR2 drop 后 README 仍写团队市场导入本仓走不通（中高）。未破：同目录共存、命名、email/version 省略、github 简写（官方先例/schema 确认）。
- 依据/来源：子 agent 574ae7c2、9ba1db8f 战报 + 官方文档（plugin-marketplaces version resolution、cursor plugins reference/repo 结构、schemastore）+ 本仓文件核对。

## 2026-06-02 01:58 · [决策] 修正计划（第 2 次加固）
- T1：marketplace 插件条目去掉 `version`（避免与 plugin.json 双写、plugin.json 恒优先的更新空转）；metadata 也去掉 version。
- T3 INSTALL.md：① AGENTS.md 改为 `[ ! -e ]`/`grep -q "Sandtable · 沙盘推演驱动开发"`/受保护 append（消除 #1）；② 源用 `SB_SRC=$(mktemp -d)/sandtable`，清理按"是否本 agent clone"判定、用户本地路径绝不删（消除 #2）；③ 步骤5 校验 using-sandtable/being-truthful/red-team-wargame/AGENTS.md 代表集合，MISSING=安装不完整并报跳过清单（消除 #3）；④ 步骤4 `[ -f ]` guard；⑤ 统一"项目根执行"。
- T4 README：Claude 更新措辞改"发布新版本后升级"（不夸大自动）；Cursor 改为"拷 .cursor/ 为可靠路径，symlink 如实降级（不加载项目级规则）"；删除"团队市场导入本仓"误导项（FR2 已无 marketplace.json）。
- 依据/来源：上述核实结论。

## 2026-06-02 02:10 · [对抗] 红蓝对抗第 2 轮 — 仍 BREACH_FOUND（已亲自核实）
- 红军1-r2（INSTALL.md）：向量A 致命——`./AGENTS.md` 为符号链接时 `>>` 写穿链接目标；向量B 严重——步骤5代表集过窄，hooks/templates/.cursor 规则不在 MISSING 循环致残缺栈假"完整"；向量C 中高——grep 子串锚点易假命中。上轮三修补对普通文件路径已堵。
- 红军2-r2（T1+README）：版本叙事未真修——`plugin.json` 仍 pin 0.1.0，官方 plugin.json 恒优先，仅删 marketplace version 不够；README"push commit 后升级"+ plan 注释"commit 驱动更新"均不实。其余 HELD（同目录共存/命名/schema/Cursor 降级/团队市场删除）。
- 依据/来源：子 agent a4d0202a、693e70a9 战报 + 官方 Version resolution 文档 + `.claude-plugin/plugin.json:5` + bash 重定向跟随 symlink 语义。

## 2026-06-02 02:13 · [决策] 修正计划（第 3 次加固）
- T3 INSTALL.md：AGENTS.md 分支加 `[ -L ]||[ ! -f ]` 守卫（symlink/非普通文件跳过，杜绝写穿）+ 锚点改全标题 `Sandtable · 沙盘推演驱动开发 — Agent 行为基线`（消 A/C）；步骤5 拆通用核心(含 templates)+Cursor 追加(.cursor/rules、.cursor/commands)+Claude 追加(hooks/hooks.json)，有 MISSING 不得报完成（消 B）。
- T1+README：版本策略对标 superpowers=保留 `plugin.json` version、每次发版 bump；marketplace 条目仍不写 version（单一来源）；不改动现有 `plugin.json`。README 改"递增 plugin.json version 并 push 后升级"；plan T1 注释删除"commit 驱动更新"错误依据。
- 残余低风险（记录不阻塞）：zsh 无 nullglob 的 `*.md` 字面展开（源恒有匹配不触发）；断链 CLAUDE.md 的 `ln -s` 报 File exists（功能缺损非毁数据）。顶层"诚实报告/存在即跳过"原则兜底。
- 依据/来源：上述核实结论。

## 2026-06-02 02:25 · [对抗+决策] 红蓝第 3 轮 + 收口（已亲自核实）
- 红军-r3 确认：致命毁数据类（symlink 写穿 / 误删 SB_SRC / marketplace 双 version / 版本叙事）已全部堵死。仍 BREACH 的全属同一类——"假完整/诚实报告缺口"：用户已有同名 skills/templates/commands/hooks → 安全跳过但步骤5 `-e` 仍 ok 误报完整；grep 全标题仍子串假命中。非毁数据。
- 收口（根治整类，非逐个打补丁）：①顶层"诚实报告"升为硬性规则——步骤2/3 跳过任一核心项即必报"安装不完整"，`-e` 为真也不算完整，跳过清单为权威；②AGENTS.md 锚点换 `四条不可违背的底线`（AGENTS.md 正文独特标题，降低"仅提及"假命中）；③步骤5 先看跳过清单再辅助存在性。
- 残余（低）：只读 AGENTS.md 追加失败（静默不完整非毁数据）；步骤6 依赖执行纪律；均由顶层硬性诚实原则兜底。
- 依据/来源：子 agent 7dc4761f 战报 + 官方 Version resolution 文档 + 本仓 AGENTS.md 标题核对。

## 2026-06-02 02:35 · [预演+复盘+集成] 实现预演 #1 落地（DONE）
- 实现子 agent（隔离 worktree ../sandtable-rehearsal-1）DONE，提交 `02d5e47`，仅 3 文件改动。
- 主 agent 亲自核实（不轻信 DONE）：git show --stat 确认仅 marketplace.json/INSTALL.md/README 安装节；JSON 合法、plugin 名一致、INSTALL.md 10 路径全 ok、守卫逐字与计划一致、无 .cursor-plugin/marketplace.json、现有插件未破坏、README 无"四个命令"。越界=无。
- 复盘择优：内容确定唯一无竞争变体，impl-1 即选定方案（红线零违反、需求全覆盖、外科手术式）。
- 集成：fast-forward 合并 master（a29f427..02d5e47），master 上复跑验收全绿；worktree + 分支已清理。
- 残余低危（已如实写入文档、不阻塞）：Cursor `.cursor/rules` 不随本地插件加载（需拷 .cursor/）；`/plugin update` 需维护者递增 plugin.json version。
