# 测试用例产物 tests.md · 本需求的测试用例

> 黑盒、场景化、人可读。每条用例映射回 prd.md 的某条 FR / 验收标准 / MUST / MUST NOT（映射硬约束，Q6 扩展映射源）。
> 职责（Q5=B）：本文件是检验理解的**唯一具体载体**（含可执行检查命令）；PRD §5 只写抽象成功定义；plan 验证步骤引用本文件 TC 编号、不另造预期。
> 审阅指引（Q7）：开发者**先读本文件**判断 AI 是否真懂（理解闸门）；§5 留作 VERIFY 勾选（完成闸门）。
> 状态：待验证 / 已验证。本文件随 PRD/plan 一起持续完善修正。本文件同时是「新产物 tests.md 应长什么样」的自举示范。

---

## TC1 · 新建 feature 自带 tests.md
- **映射**：FR4
- **Given**：一个含本插件 `templates/` 与改造后 `scripts/sandtable-init.sh` 的空工作目录。
- **When**：运行 `bash scripts/sandtable-init.sh demo 2026-06-02`。
- **Then**：`docs/sandtable/features/2026-06-02-demo/` 下同时存在 `prd.md plan.md tests.md state.md journal.md questions.md` 六个文件；脚本结尾"创建清单"列出 `tests.md`；exit 0。
- **状态**：待验证

## TC2 · init 幂等不覆盖已有 tests.md
- **映射**：FR4 / MUST NOT"不覆盖用户文件"
- **Given**：已存在的 feature 目录，其 `tests.md` 被人为写入内容 `MY-CONTENT`。
- **When**：再次对同一 slug/date 运行 init。
- **Then**：脚本因 feature 目录已存在而报错退出（exit 1）、不改动该目录任何文件；`tests.md` 仍为 `MY-CONTENT`。
- **状态**：待验证

## TC3 · 状态机序列处处含 TESTCASES 且位置正确
- **映射**：FR3 / FR6
- **Given**：改造后的仓库。
- **When**：`grep -rn "TESTCASES"`（中文全称式副本用"测试用例"）扫描 using-sandtable、state-and-memory、templates/state.md、README.md、AGENTS.md、.cursor/rules/sandtable.mdc。
- **Then**：六处全部命中；且在每处的流程序列中，`TESTCASES`/测试用例位于 `OBJECTIVES`（或其产物 PRD，缩写式副本）之后、`PLAN` 之前；CLAUDE.md 经软链与 AGENTS.md 一致。
- **状态**：待验证

## TC4 · 测试用例可映射 + 三产物边界 + 技能就位（防重复硬约束生效）
- **映射**：FR2 / FR7 / MUST"映射硬约束、三产物职责边界"
- **Given**：`skills/writing-tests/SKILL.md` 与 `templates/tests.md`。
- **When**：人读其 frontmatter、门禁与模板。
- **Then**：writing-tests 含合法 frontmatter（`name: writing-tests` + description）；门禁写出"每条用例必须映射回某条 **FR/验收/MUST/MUST NOT**，否则不写"；模板每条用例含"映射"与"状态"字段；并显式区分 §5（抽象成功定义）/ tests.md（具体可演练场景，唯一具体载体）/ plan 验证（引用 TC 编号）三者职责；含审阅指引（tests.md 先读=理解闸门）。
- **状态**：待验证

## TC5 · 三类推演拿到逐条用例当突破点
- **映射**：FR5
- **Given**：改造后的三个 prompt 文件。
- **When**：读 mental-rehearsal-prompt、implementation-rehearsal-prompt、opfor-prompt。
- **Then**：每个都含"待验证用例清单（来自 tests.md）"上下文块；且各自工作要求落到逐条用例——头脑预演"逐条推该用例链路是否闭环"、实现预演"逐条让用例 Then 成立"、红军"逐条对用例构造反例"。
- **状态**：待验证

## TC6 · 流程闭环：PRD 确认→TESTCASES→PLAN，命令层与 skill 层一致
- **映射**：FR6 / FR3 / FR7
- **Given**：改造后的 `skills/writing-prd/SKILL.md`、`skills/writing-plan/SKILL.md`、`commands/sandtable-objectives.md`(及 `.cursor/` 副本)、`commands/sandtable-plan.md`(及副本)。
- **When**：读各自的衔接/路由段落。
- **Then**：writing-prd 的 HARD-GATE、dot、结尾**三处一致**指向"PRD 确认后→phase=TESTCASES、加载 writing-tests"（无残留 PLAN/writing-plan 旧路由）；`sandtable-objectives` 第 5 步设 `phase=TESTCASES`、不再写死 PLAN；writing-plan 前置输入与 `sandtable-plan` 命令都读 `tests.md`；writing-tests 结尾路由到 PLAN/writing-plan；且异常修正"写回清单"（using-sandtable:88、being-truthful:44、sandtable-mental/rehearse 命令）均含 `tests.md`；链路首尾相接无断点。
- **状态**：待验证

## TC7 · 黑盒、技术栈无关（形态正确）
- **映射**：FR1 / MUST"黑盒、技术栈无关、人可读"
- **Given**：`templates/tests.md`。
- **When**：人读模板与字段。
- **Then**：用例用 Given/When/Then + 具体输入→预期输出表达，无任何编程语言断言代码、无框架名；非技术读者也能看懂"输入什么、期望看到什么"。
- **状态**：待验证

## TC8 · 现有产物未被破坏（回归）
- **映射**：验收"未破坏现有" / MUST NOT
- **Given**：改造后的仓库。
- **When**：`python3 -m json.tool .claude-plugin/plugin.json`、同样校验 `.cursor-plugin/plugin.json`、`bash -n scripts/sandtable-init.sh`，并对照改动前后 diff 检查无关 skill 的 Red Flags/合理化表/硬门禁文本。
- **Then**：两个 json 合法、脚本语法通过；无关已调校文本零改动；`docs/sandtable/` 既有 feature 未被触碰。
- **状态**：待验证

## TC9 · 全仓命名自洽 + 命令双副本同步
- **映射**：FR6 / 验收"命名自洽、双副本同步"
- **Given**：改造后的仓库。
- **When**：`grep -rn "TESTCASES\|writing-tests\|tests.md"` 扫全仓；对每个改动的命令文件运行 `diff commands/<x>.md .cursor/commands/<x>.md`。
- **Then**：无 `test-cases`/`testcase`/`writing-test`(漏 s) 等拼写变体；start、objectives、plan、resume、refine、rehearse 六个命令的两副本 `diff` 均无差异。
- **状态**：待验证
