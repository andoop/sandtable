# 记忆日志 · Journal（只增不改）

> 每条记录决策/问答/预演/异常/集成。永远不要删改历史条目；修正用新条目。

## 2026-06-06 00:11 · [决策] 立项：Cross-AI one-click install + English-first docs
- 背景：开发者执行 `/sandtable-rehearse` 并补充需求“支持 codex kiro ai 一键安装，支持英文文档”。
- 内容：判定这不是对 `2026-06-02-easy-install` 的直接复盘，而是一个新的增量 feature；将以新需求目录独立推进。
- 依据/来源：开发者原话 + `2026-06-02-easy-install/state.md` 已为 `DONE` 且旧范围不含 `Kiro` / 英文主文。

## 2026-06-06 00:14 · [问答+决策] 开发者确认范围
- 背景：英文文档与 Codex/Kiro 支持的实际含义会直接决定 PRD 与文件地图，不能靠猜。
- 内容：
  - “英文文档”范围 = 尽量覆盖主要仓库文档。
  - “Codex / Kiro 一键安装”范围 = 只要求 README / INSTALL 明确这两个 AI 可使用统一安装提示词，不要求工具专属接线。
  - 英文文档形态 = 英文主文，不做同页双语，也不新增英文副本。
- 依据/来源：开发者 AskQuestion 答复。

## 2026-06-06 00:18 · [推演前准备] RECON 摘要与计划成形
- 背景：进入三类推演前，需把已确认事实落到 PRD / tests / plan。
- 内容：
  - 现有 README 默认路径已经是“让 AI 读 `INSTALL.md`”，但 README / INSTALL / AGENTS / 命令说明仍主要是中文。
  - `INSTALL.md` 现只显式写到 `Cursor / Claude Code / Codex / 其它`，尚未点名 `Kiro`。
  - 插件元数据展示字段仍是中文，属于用户可见文案。
  - 已据此写出新 feature 的 `prd.md`、`tests.md`、`plan.md`，并把 state 推进到 `MENTAL_REHEARSAL`。
- 依据/来源：`README.md`、`INSTALL.md`、`AGENTS.md`、`commands/*.md`、`.cursor/commands/*.md`、三个 plugin json 文件。

## 2026-06-06 00:23 · [推演] 头脑预演第 1 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：从元数据一致性角度派发只读 mental-rehearsal 子 agent。
- 内容：子 agent 指出计划虽已限制“只翻译 display text”，但测试与验证步骤没有把 `version` 与 marketplace `source` 的“不漂移”写成显式验收。主 agent 复核 `tests.md` / `plan.md` 后确认成立：原文只重新检查了 `name` 与 JSON 合法，确实缺少 `version` / `source` 的明确守卫。
- 处置：已把 `TC5` 扩展为同时校验 `name` / `version` / marketplace `source` 不漂移，并把 `plan.md` 的 T3/T4 验证步骤同步补强为显式检查这些字段。修正后重跑 mental。
- 依据/来源：子 agent [Mental metadata scope](72ae88d0-15f6-45ed-a445-301301c340e6) 战报 + 主 agent 实读 `tests.md` / `plan.md`。

## 2026-06-06 00:49 · [问答+决策] 需求改向：语言不再固定为英文主文
- 背景：开发者提出新规则“复制给 AI 的是什么，就让 AI 安装什么语言的命令”。
- 内容：
  - 语言跟随规则作用于安装流程和放到用户本地的文档。
  - 首期只支持中文与英文。
  - 语言由 AI 根据用户实际贴过去的话自行判断，不新增显式语言 flag。
  - “放到用户本地的文档”明确**包含 `skills/`**。
- 影响：当前 feature 不再是“English-first docs”，而是“prompt-language localized install assets”；此前围绕“英文主文”的 PRD / tests / plan 全部失效，需要整体回写后再推演。
- 依据/来源：开发者连续答复。

## 2026-06-06 00:54 · [推演前准备] 补充侦察：模板与 hook 也会形成混语尾巴
- 背景：为了确定语言切换范围，继续核读安装资产。
- 内容：
  - `templates/*.md` 全是自然语言模板，安装后运行 `scripts/sandtable-init.sh` 会把这些模板产出到用户项目，因此模板必须跟随语言切换。
  - `hooks/session-start` 会把 `skills/using-sandtable/SKILL.md` 注入 session context，且文件自身还包含自然语言包装文本；若英文安装时仍复用中文/混语 wrapper，就会形成隐蔽混语路径。
  - `hooks/hooks.json`、`hooks/hooks-cursor.json` 只是机器接线，可继续共享单份。
- 依据/来源：`templates/project.md`、`templates/constraints.md`、`hooks/session-start`、`hooks/hooks.json`、`hooks/hooks-cursor.json`。

## 2026-06-06 00:56 · [决策] 回写新 PRD / tests / plan
- 背景：新需求已经改变了目标、作用范围和实现结构。
- 内容：
  - `prd.md` 已改为“按提示词语言安装本地资产”，并把“不覆盖已有文件导致无法切换语言时必须如实报告”写成 FR6。
  - `tests.md` 已改为中英提示词分流、本地资产范围、无额外 flag、换语言不覆盖、模板与 hook wrapper 不混语等用例。
  - `plan.md` 已改为“根目录中文资产 + `locales/en/` 英文镜像 + 共享机器资产单份”的结构，范围覆盖 `AGENTS`、rules、commands、Cursor commands、skills、templates 和必要的 hook wrapper。
- 依据/来源：主 agent 对 feature 文档的回写。

## 2026-06-06 01:02 · [推演] 头脑预演第 2 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：按“资产覆盖面”方向重跑 mental-rehearsal。
- 内容：子 agent 指出 `scripts/sandtable-init.sh` 被安装到用户本地，且包含中文 `usage` / 报错 / “下一步”提示，因此不能继续被当作“共享机器资产”。主 agent 复核脚本内容后确认成立。
- 处置：已把 `scripts/sandtable-init.sh` 纳入 FR3 的语言切换范围；`tests.md` 的 `TC7` 增补 init script 文本检查；`plan.md` 已改为为 `locales/en/scripts/sandtable-init.sh` 建英文镜像，并从“共享机器资产”中剔除该脚本。
- 依据/来源：子 agent [Mental asset coverage](a57aadc3-6d57-4e46-85c1-a21fbbcba0f2) 战报 + 主 agent 实读 `scripts/sandtable-init.sh`。

## 2026-06-06 01:06 · [推演] 头脑预演第 3 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：修正 init script 后，再次检查是否还有安装面漏网之鱼。
- 内容：子 agent 指出安装说明当前复制的是整个 `scripts/` 目录，而仓库里还存在 `scripts/test-sandtable-init.sh`，其中同样包含中文注释与失败文本；如果继续整目录安装，英文安装仍会把这个中文脚本带进用户项目。
- 处置：决定收紧安装面，而不是把测试脚本也做双语。`plan.md` 已改为在 `INSTALL.md` 中明确“只安装 `scripts/sandtable-init.sh`，不安装 `scripts/test-sandtable-init.sh`”，从源头消除该混语路径。
- 依据/来源：子 agent [Mental asset coverage v2](0d505356-c5d9-4524-a8c6-ef05699f48d7) 战报 + 主 agent 实读 `scripts/test-sandtable-init.sh`。

## 2026-06-06 01:10 · [推演] 头脑预演第 4 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：在 scripts 收口后，再次复查 hook wrapper 的语言闭环。
- 内容：子 agent 指出根目录 `hooks/session-start` 当前 wrapper 文本本身是英文，而计划又把根目录当作中文安装源；若不修正，中文安装会拿到英文 wrapper 包着中文 skill 的混语结果。
- 处置：`plan.md` 已改为显式修改根目录 `hooks/session-start` 使其成为中文安装源，并必建 `locales/en/hooks/session-start` 作为英文镜像；两者保持相同 hook 结构，只切换 wrapper 文本语言。
- 依据/来源：子 agent [Mental asset coverage v3](2dd2b33a-3070-46fc-99a4-4b24f6773421) 战报 + 主 agent 实读 `hooks/session-start`。

## 2026-06-06 01:15 · [推演] 头脑预演第 5 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：继续检查 hook 路径是否还有用户可见语言泄漏。
- 内容：子 agent 指出 `hooks/run-hook.cmd` 仍被当作共享机器资产，但它包含用户可见 `usage:` 错误提示；若继续共享，中文安装路径仍会留下英文 launcher 文本。
- 处置：已把 `hooks/run-hook.cmd` 纳入 FR3 范围；`tests.md` 的 `TC7` 增补 hook launcher 检查；`plan.md` 改为把根目录 `hooks/run-hook.cmd` 作为中文源，并创建 `locales/en/hooks/run-hook.cmd` 英文镜像，同时将其从共享机器资产清单中移除。
- 依据/来源：子 agent [Mental asset coverage final](45e4f9b6-13e6-4da2-a7ac-367a75d0e540) 战报 + 主 agent 实读 `hooks/run-hook.cmd`。

## 2026-06-06 01:20 · [推演] 头脑预演第 6 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：在资产范围补齐后，最后检查语言镜像是否对所有关键本地资产都写了“语义等义”的专项约束。
- 内容：子 agent 指出 `.cursor/rules/sandtable.mdc` 虽然已被纳入语言切换范围，但 `tests.md` / `plan.md` 还没有像命令、skills 那样显式要求它保持同一状态机、同一子 agent 纪律、同一“异常即停”规则。
- 处置：已把 `tests.md` 的 `TC4` 扩展为显式覆盖 `.cursor/rules/sandtable.mdc` 语义；`plan.md` 的 T2 也补上 English rule file 必须保持同一状态机、子 agent 纪律和异常规则，并在验证步骤中纳入专项抽查。
- 依据/来源：子 agent [Mental asset coverage final v2](693b4534-3fcb-4f15-91f1-48cee8817ab0) 战报 + 主 agent 实读 `tests.md` / `plan.md`。

## 2026-06-06 01:24 · [推演] 头脑预演第 7 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：语言选择逻辑已闭环后，继续检查验证层是否把所有“只换语言不改行为”的约束都写成了测试闸门。
- 内容：子 agent 指出 `templates/*`、`scripts/sandtable-init.sh`、`hooks/run-hook.cmd`、`hooks/session-start` 在计划里都要求“只改语言不改行为/契约”，但 `tests.md` 的 `TC7` 还只验证“不混语”，没有把这些行为契约写成 Then 条件。
- 处置：已把 `TC7` 扩展为同时校验：模板输出语义不变、`sandtable-init.sh` 的参数校验/幂等保护/输出结构不变、`run-hook.cmd` 不改变转发行为、`session-start` 不改变 bootstrap 与 JSON 输出契约。
- 依据/来源：子 agent [Mental asset coverage closed](4b510780-61a1-4e48-a4be-51b898e8a5a3) 战报 + 主 agent 实读 `tests.md` / `plan.md`。

## 2026-06-06 01:28 · [推演] 头脑预演第 8 轮 — ANOMALY_FOUND（已亲自核实）
- 背景：在补完行为契约后，再次检查 tests 是否完全覆盖计划里宣称的安装面收口。
- 内容：子 agent 指出两处仍缺测试闸门：①模板虽然已检查语言一致，但还没显式写“章节骨架 / 模板职责等义”；②计划里已经要求“不安装 `scripts/test-sandtable-init.sh`”，但 tests 里还没有单独用例守这条边界。
- 处置：已把 `TC7` 扩展为模板角色/章节骨架等义检查，并新增 `TC8` 明确要求仓库内部测试脚本不得进入用户项目；`plan.md` 的验证步骤与 TC 映射同步补上 `TC8`。
- 依据/来源：子 agent [Mental asset coverage closed v3](d9259c8e-6598-4f3f-8e1a-434b4068056a) 战报 + 主 agent 实读 `tests.md` / `plan.md`。

## 2026-06-06 01:33 · [推演] 头脑预演收口 — LOGIC_CLOSED
- 背景：在补齐规则语义、模板等义、hook launcher/wrapper、本地脚本安装面与测试闸门之后，重跑 mental-rehearsal。
- 内容：最终复核结论为 `LOGIC_CLOSED`。当前 PRD / tests / plan 已在计划层闭环：两条官方中英提示词、AI 自行判断语言、统一 `INSTALL.md` 路径、非覆盖式重装如实报不完整、Codex/Kiro 仅走通用路径、本地自然语言资产范围完整、共享机器资产与本地化资产拆分清晰。
- 依据/来源：子 agent [Mental language selection closed](29fa247f-2378-47bc-bad2-6dd46929809f) + [Mental asset coverage closed v4](ba049186-4cd3-4d31-beef-6c5e50d46ac6) 战报。

## 2026-06-06 01:41 · [对抗] 红蓝对抗第 1 轮 — BREACH_FOUND（已亲自核实）
- 背景：进入 `REDTEAM` 后并行派发 3 个红军方向：语言判断绕过、资产侧翼包抄、非覆盖式重装伪成功。
- 内容：
  - 红军1（语言判断）成立：当前规则把“用户实际贴过去的话”说得太宽，混合语言、包装词、非官方改写版都会导致 AI 可能误判中英。
  - 红军2（资产侧翼）成立：`skills/` 中除了 `SKILL.md`，还有 `opfor-prompt.md`、`mental-rehearsal-prompt.md`、`implementation-rehearsal-prompt.md` 等安装后继续被命令/skills 引用的自然语言模板，原计划漏掉。
  - 红军3（重装伪成功）成立：`hooks/` 目录里既有共享机器文件，也有语言相关文件；若继续按整目录存在即跳过，旧语言 hook 会在重装时留下伪成功。
- 处置：已回写修正：
  - FR2 改为只认**官方提示词正文**；混合/包装/非官方改写版一律先澄清。
  - FR3 / `TC4` / `plan.md` 扩大为覆盖 `skills/**` 下会被安装后继续引用的 prompt 模板。
  - `hooks/` 改为文件级非覆盖映射：`hooks.json` / `hooks-cursor.json` 共享，`run-hook.cmd` / `session-start` 逐文件按语言切换并逐文件报告未切换项。
- 依据/来源：红军子 agent [Redteam prompt spoofing](b6d011d9-d134-4594-aeaa-0c920d476f66)、[Redteam asset leakage](09c2cc53-f1d6-4da1-852c-8026c7c763df)、[Redteam reinstall honesty](eba61333-30f4-4b1a-8a28-11a0aa0085eb) 战报 + 主 agent 实读相关文件。

## 2026-06-06 01:49 · [对抗] 红蓝对抗第 2 轮 — BREACH_FOUND（已亲自核实）
- 背景：回修第 1 轮后重打同三条攻击向量。
- 内容：
  - 红军1 再次打出一记杀招：若“包装文本 + 完整官方正文”仍算命中，就会重新打开第二条语言选择路径。
  - 红军2 指出 `hooks/session-start` 的 fallback 错误文本也要本地化；同时提醒 `templates` 不能搬到 `locales/en/templates`，否则违反 `constraints.md` 的单一模板根目录。
  - 红军3 指出更大的系统性问题：如果语言相关资产仍按单文件各自跳过，重装时会出现“英文脚本 + 中文模板”这类半切换状态。
- 处置：已回写修正：
  - FR2 改为只在**整条官方提示词正文精确命中**时自动选语言，任何包装/混合/改写都先澄清。
  - `hooks/session-start` 的 fallback 错误文本纳入本地化；英文模板从 `locales/en/templates` 收回到 `templates/en/`，保持 `templates/` 为唯一模板根。
  - FR6 与计划改为：所有语言相关安装资产先做 locale-pack 预检；只要任一相关目标已存在，就不再继续复制该 locale 的其它语言相关资产，避免半切换。
- 依据/来源：红军子 agent [Redteam prompt spoofing v3](9435d357-23b8-4d63-bbc6-ae44ef5dbbe4)、[Redteam asset leakage v3](0bfee100-1bfe-49c8-a9ec-9f6c57d8e3f3)、[Redteam reinstall honesty v3](4e7f6ba8-c560-4883-a882-ad4d48a91b38)、[Redteam reinstall honesty v3](931654fa-4c97-4eb1-bacd-d1c400eee5f8) 战报 + 主 agent 复核。

## 2026-06-06 01:56 · [对抗] 红蓝对抗收口 — HELD
- 背景：在收紧“整条官方提示词正文精确命中”、补齐 `skills/**` prompt 模板、本地化 hook fallback 文本、恢复 `templates/en` 到单模板根、并把语言相关资产改为 locale-pack 预检后，重打红军。
- 内容：红军在语言判断与 locale-pack/重装两条主攻击面均未再给出成立的可复现杀招。包装/混合/非官方提示词已被澄清路径封死；`templates/` 单根、`skills/**` 覆盖、`hooks/` 文件级处理、`scripts/test-sandtable-init.sh` 排除、以及“任一语言相关目标已存在则整包不落地”的规则，也共同堵住了剩余混语与伪成功路径。
- 依据/来源：红军子 agent [Redteam prompt contract final](7f8d46ef-1612-47f8-a960-27d3272e93c3) + [Redteam locale-pack final](064f45c7-427f-454f-9320-a16549637781) 战报。

## 2026-06-06 02:05 · [预演+复盘] 实现预演 #1 完成并选定
- 背景：在隔离 worktree `sandtable-rehearsal-1` 中按最终计划试做实现。
- 内容：
  - 子 agent 在 `sandtable/rehearse/cross-ai-install-english-docs-1` 上完成实现，修改 `README.md`、`INSTALL.md`、`hooks/run-hook.cmd`、`hooks/session-start`，并新增 `locales/en/` 与 `templates/en/`。
  - 主 agent 亲自抽查 worktree：确认 README/INSTALL 入口、locale-pack 规则、hook 根文件中文源、英文 locale 资产目录、`templates/en` 单模板根都已落地。
  - 验证通过：相关 bash 脚本语法检查、shared hook JSON 解析、资产布局检查、编辑区 lint 均通过。
  - 因当前只有 1 个实现预演候选，且抽查无越界与明显回归，复盘后将其设为 `selected_impl`。
- 依据/来源：实现子 agent [Impl rehearsal cross-ai install](fd4a3ca9-c733-4fe6-b962-816cde3c057c) 战报 + 主 agent 对 worktree 的 `git status --short` / `git diff --stat` / 关键文件实读。

## 2026-06-06 02:12 · [集成+验证] 已按确认落地主工作区
- 背景：开发者在 `INTEGRATE` 就绪态给出“确认”，允许把已选中的实现预演方案从隔离 worktree 集成回主工作区。
- 内容：
  - 已将 worktree 中的目标实现同步回主工作区：更新 `README.md`、`INSTALL.md`、`hooks/run-hook.cmd`、`hooks/session-start`，并落地 `locales/en/**`（46 个文件）与 `templates/en/*.md`（8 个文件）。
  - 主 agent 复核主工作区 `git status --short` / `git diff --stat`，确认变更面与预期一致；新增目录数量与抽样文件内容均对上。
  - 主工作区验证通过：相关 bash 脚本语法检查通过，hook JSON 解析通过，编辑范围 lint 无报错。
  - 因主工作区已完成集成且未发现新增异常，本 feature 状态推进到 `DONE`。
- 依据/来源：集成子 agent [Integrate selected rehearsal](61be532e-e794-4248-9c55-3bc33d5c3704) 战报 + 主 agent 对主工作区的 `git status --short` / `git diff --stat` / `INSTALL.md` 实读 / `ReadLints` 复核。
