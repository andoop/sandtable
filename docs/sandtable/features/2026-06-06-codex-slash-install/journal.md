# Codex Slash Install · Journal

## 2026-06-06 10:42 · [受领任务]
- 背景: 用户使用 `/sandtable-start` 提出新需求。
- 内容: 原始需求为“让 codex 中用通过的 ai 一句话安装，也可以像cursor那样可以正常使用 slash命令”。
- 依据/来源: 开发者消息，2026-06-06。

## 2026-06-06 10:42 · [侦察]
- 背景: 需要确认现有安装路径与 Codex 能力边界。
- 内容: 已确认 README 当前支持中英两条 AI 一句话安装提示词，并写明 Codex/Kiro 属于通用安装对象；但 README 同时明确“Codex 与 Kiro 走同一条通用安装路径；本仓库不会为它们新增专属 rules / hooks / 脚本接线”。INSTALL 也写明“Codex 与 Kiro 也走这条通用路径，不新增它们各自的专属 rules、专属 hooks 或安装脚本”。
- 依据/来源: `README.md:10-20`, `README.md:61-75`, `INSTALL.md:25-39`, `INSTALL.md:191`。

## 2026-06-06 10:42 · [侦察]
- 背景: 需要确认 Codex 是否存在可承载命令资产的接线形态。
- 内容: 本地 Codex CLI 暴露 `codex plugin` 管理命令；本地 Codex 插件示例说明 plugin 可包含 `.codex-plugin/plugin.json`、`skills/`、`commands/` 等 companion surfaces。Vercel 插件示例的 manifest 使用 `.codex-plugin/plugin.json`，并有 plugin-level `commands/*.md`。这说明“为 Codex 提供 plugin/commands 资产”是可规划方向；但未确认 Codex 会自动读取项目根 `commands/` 或 `.cursor/commands/` 作为 slash 命令。
- 依据/来源: `codex plugin --help`, `/Users/andoop/.codex/.tmp/plugins/README.md:5-8`, `/Users/andoop/.codex/.tmp/plugins/plugins/vercel/.codex-plugin/plugin.json:1-53`, `/Users/andoop/.codex/.tmp/plugins/plugins/vercel/commands/status.md:1-7`。

## 2026-06-06 10:42 · [阻塞]
- 背景: 本需求将改变现有“Codex/Kiro 不新增专属接线”的边界。
- 内容: 已在 `questions.md` 记录 Q1，等待开发者确认是否按 Codex plugin/commands 方向推进。
- 依据/来源: `questions.md`。

## 2026-06-06 10:45 · [问答]
- 背景: PRD 阶段需要开发者确认 Codex 接线方向。
- 内容: 开发者回复“继续呀”。主 agent 按推荐方案解释为确认新增 Sandtable Codex plugin/commands 接线，并继续写 `tests.md` 与 `plan.md`。
- 依据/来源: 开发者消息，2026-06-06。

## 2026-06-06 10:45 · [计划]
- 背景: `/sandtable-start` 需要完成 TESTCASES 与 PLAN。
- 内容: 已创建 `tests.md`，覆盖 Codex 文档路径、plugin 资产完整性、13 个命令、非覆盖红线、locale 规则、现有 Cursor/Claude/通用路径不回退；已创建 `plan.md`，拆为 T1-T5。
- 依据/来源: `tests.md`, `plan.md`。

## 2026-06-06 11:27 · [推演]
- 背景: 用户触发 `/sandtable-mental`，主 agent 派出两个只读子 agent 推演 Codex plugin/commands 与安装/locale 链路。
- 内容: 两个子 agent 均返回 `ANOMALY_FOUND`。核心问题是计划只创建根目录 `.codex-plugin/plugin.json` 与 commands，但 Codex plugin discovery 是 marketplace-based，示例结构为 `plugins/<name>/.codex-plugin/plugin.json`，且需要 `.agents/plugins/marketplace.json` 指向 plugin root。
- 依据/来源: `rehearsals/mental-1.md`, `/Users/andoop/.codex/.tmp/plugins/plugins/plugin-eval/README.md:141-148`, `/Users/andoop/.codex/.tmp/plugins/plugins/plugin-eval/README.md:201-228`。

## 2026-06-06 11:27 · [修正]
- 背景: 主 agent 亲自核实 anomaly 后需要回修 PRD/测试/计划。
- 内容: 已把方案修正为 marketplace-compatible 结构：`plugins/sandtable/.codex-plugin/plugin.json`、`plugins/sandtable/commands/`、`.agents/plugins/marketplace.json`；并把 marketplace 文件纳入非覆盖检查、验证清单与 TC7.5。
- 依据/来源: `prd.md`, `tests.md`, `plan.md`。

## 2026-06-06 11:34 · [推演]
- 背景: 回修后重跑 mental-2，重点验证 `plugins/sandtable` + `.agents/plugins/marketplace.json` 链路。
- 内容: 子 agent 返回 `LOGIC_CLOSED`。端到端链路为：marketplace-compatible plugin root、workspace marketplace 注册、13 个 commands 同步、中英 locale 镜像、`/sandtable-start` 前五步语义、T5 验证清单闭环。
- 依据/来源: `rehearsals/mental-2.md`。

## 2026-06-06 11:43 · [推演]
- 背景: 用户触发 `/sandtable-live`，主 agent 按显式指令跳过红蓝对抗，创建隔离 worktree `/private/tmp/sandtable-codex-slash-live-1` 并派发实现预演。
- 内容: worker 返回 `DONE`，但主 agent 抽查发现 `.agents/plugins/marketplace.json` 结构不符合 Codex marketplace 规范：`plugins` 被写成对象而不是数组，且缺少 `policy.authentication`。
- 依据/来源: `rehearsals/impl-1-sandtable-rehearse-codex-slash-install-1.md`, `/Users/andoop/.codex/.tmp/plugins/.agents/skills/plugin-creator/references/plugin-json-spec.md`。

## 2026-06-06 11:43 · [修正]
- 背景: impl-1 anomaly 需要回修计划与测试后重演。
- 内容: 已将 `TC7.5` 和 `plan.md` marketplace 要求补强为精确结构：top-level `plugins` 数组，`source.path=./plugins/sandtable`，`policy.installation=AVAILABLE`，`policy.authentication=ON_INSTALL`，`category=Developer Tools`。
- 依据/来源: `tests.md`, `plan.md`。

## 2026-06-06 11:51 · [推演]
- 背景: impl-2 在第二个隔离 worktree 中完成实现并返回 `DONE`。
- 内容: 主 agent 抽查确认 marketplace JSON 已修好，但发现两个偏差：README 顶部/Quickstart 仍保留“安装完成后运行 `/sandtable-start`”和“第一条命令：`/sandtable-start`”的一刀切旧文案；INSTALL 验证代码直接使用 `jq`，不符合零依赖安装体验。
- 依据/来源: `rehearsals/impl-2-sandtable-rehearse-codex-slash-install-2.md`。

## 2026-06-06 11:51 · [修正]
- 背景: impl-2 anomaly 需要回修计划后重演。
- 内容: 已补充计划要求：README 顶部和 Quickstart 步骤 3 都必须按工具区分命令入口；INSTALL 验证代码块不得依赖 `jq`、Python、Node 或其它非 POSIX/coreutils 工具，JSON 结构检查改为 AI/人工结构化检查要求。
- 依据/来源: `plan.md`。

## 2026-06-06 11:58 · [推演]
- 背景: impl-3 在第三个隔离 worktree 中按回修计划实现。
- 内容: worker 返回 `DONE`，主 agent 抽查通过。README 两处命令入口已按工具区分；INSTALL 未引入 `jq` 验证依赖；Codex marketplace JSON 使用 plugins 数组并包含 `policy.authentication=ON_INSTALL`；三套命令数量均为 13 且中英 Codex plugin commands 与既有 commands 镜像一致。
- 依据/来源: `rehearsals/impl-3-sandtable-rehearse-codex-slash-install-3.md`, `/private/tmp/sandtable-codex-slash-live-3`。

## 2026-06-06 12:08 · [集成]
- 背景: 用户要求继续，主 agent 按 debrief 选择 impl-3 集成到主工作区。
- 内容: 已从 `/private/tmp/sandtable-codex-slash-live-3` 集成 README、INSTALL、`.agents/plugins/marketplace.json`、`plugins/sandtable/.codex-plugin/plugin.json`、`plugins/sandtable/commands/*.md`、`locales/en/plugins/sandtable/commands/*.md`。集成验证时发现 plugin manifest 仍不符合计划中的 `interface` 结构，主 agent 已修正为本地 Codex plugin spec 形态。
- 依据/来源: `rehearsals/debrief-1.md`, `plugins/sandtable/.codex-plugin/plugin.json`。

## 2026-06-06 12:08 · [验证]
- 背景: 集成后需要在主工作区确认验收。
- 内容: 验证通过：`plugins/sandtable/.codex-plugin/plugin.json` 与 `.agents/plugins/marketplace.json` JSON 可解析；marketplace 使用 plugins 数组并包含 `sandtable` 条目；根命令、Codex 中文 plugin commands、Codex 英文 plugin commands 数量均为 13；中英命令镜像 diff 无差异；README/INSTALL 中旧的一刀切 `/sandtable-start` 文案、旧 Codex/Kiro 通用路径承诺和 `jq -e` 验证依赖均无命中。
- 依据/来源: 主工作区验证命令输出。

## 2026-06-06 12:15 · [修正]
- 背景: 用户重启 Codex 后 slash 命令仍不可用，询问是否需要发布插件。
- 内容: 主 agent 核实 `codex plugin marketplace list`，发现本地 `sandtable-local` marketplace 未注册。已在本机执行 `codex plugin marketplace add /Users/andoop/Documents/projects/sss/sandtable` 与 `codex plugin add sandtable --marketplace sandtable-local`，确认 `sandtable@sandtable-local (installed, enabled)`。同时回写 README/INSTALL，明确 Codex 需要本地注册 marketplace 并安装 plugin；不需要发布插件。
- 依据/来源: `codex plugin marketplace list`, `codex plugin list`, `README.md`, `INSTALL.md`。

## 2026-06-06 12:23 · [修正]
- 背景: 用户反馈“输入 `/` 还是不提示”，并要求用 `skill-creator` 检查为什么不行。
- 内容: 主 agent 用 skill/plugin 规范核实后发现 Sandtable Codex plugin 缓存只包含 `.codex-plugin` 与 `commands/`，不包含命令依赖的 `skills/`；同时现有文档仍把 Codex 与 Cursor 的裸 slash/autocomplete 体验说得过满。已把 `plugins/sandtable/skills/**` 与 `locales/en/plugins/sandtable/skills/**` 纳入插件包，manifest 增加 `"skills": "./skills/"` 与更完整的 interface metadata，并更新 README/INSTALL：Codex 优先使用 namespaced command `/sandtable:sandtable-start`，本地插件命令是否出现在 `/` 菜单取决于 Codex 客户端能力，不再承诺 Cursor 式裸 slash 提示。
- 验证: 重新运行 skill 校验，中文与英文 plugin skills 全部 `Skill is valid!`；`diff -rq skills plugins/sandtable/skills` 与 `diff -rq locales/en/skills locales/en/plugins/sandtable/skills` 通过；重新执行 `codex plugin remove sandtable --marketplace sandtable-local` 与 `codex plugin add sandtable --marketplace sandtable-local` 后，缓存 `/Users/andoop/.codex/plugins/cache/sandtable-local/sandtable/0.1.0` 已包含 13 个 commands 与 12 个 skills。
- 剩余限制: 终端可验证本地插件 installed/enabled 与缓存完整，但不能强制验证 Codex Desktop composer 的 `/` autocomplete 是否展示本地插件命令；这属于客户端 UI 行为，应如实区分。
- 依据/来源: `plugins/sandtable/.codex-plugin/plugin.json`, `plugins/sandtable/skills/`, `locales/en/plugins/sandtable/skills/`, `README.md`, `INSTALL.md`, `codex plugin list`。
