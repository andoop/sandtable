# 测试用例 · 自动模式、推演口径、live 完整性与 close loop 优化

> 读者提示：本文件是理解闸门。先看这些 Given/When/Then 是否准确表达了你要的行为；后续 `plan.md` 只引用 TC 编号，不重新发明预期。

## TC1 · 自动模式最低覆盖不再是 3/3/2

- **映射**: FR1、验收「默认最低覆盖为 mental/redteam/impl 各 1 轮」、MUST「保留三类推演至少各一轮」
- **Given**: 一个已进入 `/sandtable-autopilot` 的需求，`autonomy.completed_rounds` 初始为 `{ mental: 0, redteam: 0, impl: 0 }`。
- **When**: 自动模式初始化或刷新该需求的 `state.md`。
- **Then**: `autonomy.min_rounds` 的默认语义为最低覆盖，数值为 `{ mental: 1, redteam: 1, impl: 1 }`；文档不再要求 mental 3 轮、redteam 3 轮、impl 2 轮作为不可降级硬门槛。
- **状态**: 待验证

## TC2 · 最低覆盖完成后由 AI 自主决策

- **映射**: FR2、验收「达到最低覆盖后自主追加或进入评估」、MUST「非真实阻塞不打扰用户」
- **Given**: 自动模式下 mental、redteam、impl 都已至少完成 1 轮，且 `blocked=false`。
- **When**: 主 agent 需要决定下一步。
- **Then**: 主 agent 不询问用户“是否继续”；它必须根据风险、改动面、异常历史、实现差异、测试信心或抽查结果，选择追加某类推演/对抗/实现预演，或进入 `EVALUATE`，并把理由写入 `autonomy.last_decision`。
- **状态**: 待验证

## TC3 · 最低覆盖不是“只跑一轮就停”

- **映射**: FR2、MUST NOT「不得把至少一轮实现成只跑一轮就永远停止」
- **Given**: 自动模式已完成三类推演各 1 轮，但刚修复过一个 `ANOMALY_FOUND`，或实现候选之间差异明显。
- **When**: 主 agent 判断是否进入 `EVALUATE`。
- **Then**: 文档要求主 agent 说明是否追加推演的理由；若风险仍高，应自主追加对应阶段，而不是机械地因 1/1/1 已达标就停止。
- **状态**: 待验证

## TC4 · 老 feature 的历史 3/3/2 状态不被强制迁移

- **映射**: FR3、非目标「不迁移历史 feature 的既有 state.md 配额记录」
- **Given**: 一个历史 feature 的 `state.md` 已经记录 `autonomy.min_rounds: { mental: 3, redteam: 3, impl: 2 }`。
- **When**: 新规则落地后读取该历史 feature 的状态。
- **Then**: 文档不要求批量改写历史 feature；历史记录可以保持原样，新建或刷新自动模式时才使用最低覆盖语义。
- **状态**: 待验证

## TC5 · 头脑推演只上报真实影响闭环的问题

- **映射**: FR4、验收「真实问题口径」、MUST「保留不猜测原则」
- **Given**: 一个头脑推演子 agent 正在核对某条计划链路，发现一个与本需求无关、不会影响 PRD/plan/code reality 的极端假想输入。
- **When**: 子 agent 准备返回结果。
- **Then**: 它不应为了挑刺返回 `ANOMALY_FOUND`；只有当问题导致 PRD/plan/code reality 冲突、链路无法闭环、影响范围超出预期、违反红线，或关键事实无法确认且会影响决策时，才返回 `ANOMALY_FOUND`。
- **状态**: 待验证

## TC6 · 头脑推演仍不能带着关键不确定继续

- **映射**: FR4、MUST「保留异常即停闭环」、MUST NOT「不得删除不猜测原则」
- **Given**: 头脑推演发现计划依赖一个未确认的关键事实，该事实会决定实现是否可行。
- **When**: 子 agent 无法从代码或文档确认该事实。
- **Then**: 它必须返回 `ANOMALY_FOUND` 并说明需要澄清什么；不得为了“不要吹毛求疵”而假设一个答案继续推演。
- **状态**: 待验证

## TC7 · 红蓝对抗拒绝空泛风险

- **映射**: FR5、验收「可复现攻破口径」
- **Given**: 红军子 agent 只能提出“可能有风险”或“建议加强”，但没有具体场景、步骤、输入或可观察错误。
- **When**: 主 agent 裁决这份红军战报。
- **Then**: 该战报不算 `BREACH_FOUND`；应记录为未攻破或残余风险，不能驱动修正循环。
- **状态**: 待验证

## TC8 · 红蓝对抗仍要拦截真实可复现破口

- **映射**: FR5、MUST「保留可复现证据和主 agent 核实」
- **Given**: 红军给出一个与 PRD 验收或 MUST/MUST NOT 直接冲突的具体场景，并附带复现步骤和证据。
- **When**: 主 agent 亲自核实该场景成立。
- **Then**: 该场景必须登记为 `BREACH_FOUND` / anomaly，写回文档或计划并重演；不得以“不要吹毛求疵”为理由忽略。
- **状态**: 待验证

## TC9 · 实现预演 DONE 前必须给覆盖矩阵

- **映射**: FR6、验收「DONE 返回格式包含覆盖矩阵」
- **Given**: 实现预演子 agent 准备返回 `DONE`。
- **When**: 它整理最终报告。
- **Then**: 报告必须逐项列出 `prd.md`、`tests.md`、`plan.md` 中的必做项是否已实现、已验证、未覆盖；任何未覆盖项都不能被静默省略。
- **状态**: 待验证

## TC10 · 部分实现不得进入 debrief

- **映射**: FR6、验收「缺少必做项不得进入 debrief」
- **Given**: 实现预演完成了自动模式配额修改，但漏掉 close loop 已选择即续跑的规则。
- **When**: 主 agent 收到该实现的 `DONE` 报告并执行完整性审查。
- **Then**: 主 agent 必须独立重算当前 PRD/tests/plan 的结构化核对基准，并对照候选 worktree 的真实 diff / 改动清单；若覆盖矩阵自报全绿但 diff 缺少 close loop 相关文件，或报告内少报 `PRD-AC` / `MUST` / `MNOT` 键仍自洽，必须把该候选标记为 `ANOMALY_FOUND` 或 `BLOCKED`；不得把该候选送入 `evaluating-rehearsals`。
- **状态**: 待验证

## TC11 · 主 agent 可亲自或派子 agent 复核 DONE

- **映射**: FR6、MUST「把完整性覆盖检查写进主 agent skill 和相关 slash 命令」
- **Given**: 所有实现预演候选都自报 `DONE`。
- **When**: 主 agent 准备进入复盘择优。
- **Then**: 主 agent 必须先按规范从 PRD/tests/plan 独立派生 FR、PRD-AC、MUST、MNOT、TC、PLAN 键集合与正文 hash，再核对这些键与真实 diff / 改动文件是否 100% 对齐；简单明确的改动可亲自完成检查，复杂或高风险改动可派只读 mental / redteam 风格子 agent 辅助审查。无论采用哪种方式，都必须留下覆盖结论；审查通过后才允许进入 `EVALUATE`。
- **状态**: 待验证

## TC12 · 用户通过 AskQuestion 选择后直接续跑

- **映射**: FR7、FR8、验收「已选择路径直接续跑」
- **Given**: close loop 在手动模式下向用户展示多个下一步选项，用户选择“认可 PRD，下一步进入 TESTCASES 写 tests.md”。
- **When**: agent 收到该选择。
- **Then**: agent 在执行 TESTCASES 前或同时，先把 PRD 确认证据写入 `state.md` 或 `journal.md`，记录 AskQuestion answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；然后直接执行 TESTCASES 对应动作，不再只输出一段 `/sandtable-refine` 或 `/sandtable-plan` 的复制命令并停止。
- **状态**: 待验证

## TC13 · 自然语言确认也视为已选择路径

- **映射**: FR7、FR8
- **Given**: 用户没有点击 AskQuestion，而是直接发送“PRD 已确认，请继续写 tests.md”。
- **When**: agent 解析该消息。
- **Then**: agent 在执行 TESTCASES 前或同时，先把用户原话摘录、确认时间和用户消息来源写入 `state.md` 或 `journal.md`；然后直接进入 TESTCASES 写 `tests.md`，执行完成后报告状态，而不是要求用户再复制同一条命令。
- **状态**: 待验证

## TC14 · 命令边界要求停时仍必须停

- **映射**: FR7、非目标「不改变 /sandtable-start 写完 PRD 后必须等待开发者确认」
- **Given**: `/sandtable-start` 刚写完 `prd.md`，用户还没有确认 PRD。
- **When**: close loop 收尾。
- **Then**: agent 必须停在 PRD 确认点，输出确认/修改路径；不得自动进入 `tests.md` 或 `plan.md`。若后续通过 resume/autopilot/manual 推演入口、`/sandtable-plan` 或 refine 修改 tests/plan 续接，只有可追溯到开发者输入且已写入 `state.md` 或 `journal.md` 的确认记录才算 PRD 已确认；resume/autopilot、manual 推演入口、`/sandtable-plan` 同条消息携带确认时，也必须在继续前或同时落盘。AskQuestion 确认必须有 answer id 或 `source: askquestion:<id>`，自然语言确认必须有用户原话摘录、确认时间和用户消息来源；agent 自写 journal、伪造用户原话、仅写“AskQuestion 答复”但无 id、只有确认时间、`autonomy.last_decision`、`phase` 变化或自设 `state.md` 确认字段都不得绕过该确认点。
- **状态**: 待验证

## TC15 · 真实阻塞仍会打断用户

- **映射**: FR2、FR7、MUST NOT「不得为了减少打扰而吞掉真实阻塞」
- **Given**: 自动模式或 close loop 续跑时需要用户提供产品意图、权限、登录、外部资源或无法自行确认的关键事实。
- **When**: agent 判断该信息缺失会影响下一步。
- **Then**: agent 必须写入 `questions.md`、设置 `blocked=true` 并向用户提问；不得为了保持自动而继续猜测。
- **状态**: 待验证

## TC16 · 多镜像同步不能遗漏中文插件镜像

- **映射**: FR9、验收「中文根源、插件镜像、Cursor 命令镜像保持一致」
- **Given**: 本需求修改了 `skills/` 或 `commands/` 下的中文根源资产。
- **When**: 验证镜像一致性。
- **Then**: `plugins/sandtable/skills/` 或 `plugins/sandtable/commands/` 中对应文件包含同等语义改动；不允许只改根目录版本。
- **状态**: 待验证

## TC17 · 多镜像同步不能遗漏 Cursor 命令镜像

- **映射**: FR9、验收「Cursor 命令镜像保持一致」
- **Given**: 本需求修改了 `commands/sandtable-autopilot.md`、`commands/sandtable-live.md`、`commands/sandtable-rehearse.md` 或其他 slash 命令。
- **When**: 验证 `.cursor/commands/`。
- **Then**: `.cursor/commands/` 中对应命令包含同等语义改动；不允许根命令和 Cursor 命令行为分叉。
- **状态**: 待验证

## TC18 · 多镜像同步不能遗漏英文 locale

- **映射**: FR9、验收「英文 locale 与模板源路径保持一致」、历史教训
- **Given**: 本需求修改了中文根源 skill、command、state 模板或相关插件资产。
- **When**: 验证英文 locale。
- **Then**: `locales/en/skills/`、`locales/en/commands/`、`locales/en/.cursor/commands/`、`locales/en/plugins/sandtable/...` 与 `templates/en/` 的对应资产包含同等语义改动；不把英文模板误写到 `locales/en/templates/`。
- **状态**: 待验证

## TC19 · 不引入新依赖或无关脚本改动

- **映射**: MUST NOT「不得引入新的第三方依赖或脚本运行时」、全局 constraints
- **Given**: 本需求完成实现。
- **When**: 审查变更范围。
- **Then**: 没有新增第三方依赖；没有新增未要求的脚本运行时；没有改动与本需求无关的安装、脚手架、FEEDBACK/bugfix 语义。
- **状态**: 待验证

## TC20 · Red Flags 和已调校文本只改本需求明确要求的部分

- **映射**: 全局 constraints、MUST NOT「不得改动与本需求无关」
- **Given**: 本需求需要调整推演和红蓝对抗的发现口径。
- **When**: 审查方法论文本改动。
- **Then**: 只调整与自动模式配额、真实问题口径、live 完整性检查、close loop 已选择即续跑直接相关的段落；无关 Red Flags 表或硬门禁文本不被顺手重写。
- **状态**: 待验证
