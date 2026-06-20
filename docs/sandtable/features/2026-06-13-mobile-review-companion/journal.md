# 2026-06-13-mobile-review-companion Journal

## 2026-06-13 12:16 · [受领]
- 背景: 开发者要求扩展 Sandtable，支持手机安装 Flutter App(Android/iOS)，在开始使用 skill 时开启全局 server；server 提供 MCP，AI 在恰当进度把状态同步给 MCP，MCP 转到 server，再到手机 App。手机 App 用于审阅、回答问题、查看 PRD / plan / testcase 等。还要求方案完全通用，所有 agent(Cursor / Claude Code / Codex 等)都能使用；会话开启后永远不结束，主 agent 完事后开启低级便宜模型子 agent 轮询信箱，有消息/状态则通知主 agent 处理，循环直到电脑上主动停止。
- 内容: 新建 feature 目录 `docs/sandtable/features/2026-06-13-mobile-review-companion/`，进入 Sandtable INTAKE/RECON/OBJECTIVES。
- 依据/来源: 开发者本回合原始需求。

## 2026-06-13 12:16 · [侦察]
- 背景: 需要先确认仓库现状和约束，避免把跨 agent 能力误落成单一 Codex 功能。
- 内容: 已确认事实:
  - Sandtable 北极星是给 coding agent 用的方法论插件，目标是把简单需求做成逻辑闭环、细节完美的功能；仓库既是方法论本体也自举改进自己。来源: `docs/sandtable/project.md:5-6`
  - 当前插件结构包括 `skills/`、`commands/`、`templates/`、`hooks/`、Codex plugin、Cursor/Claude/通用 agent 接线。来源: `docs/sandtable/project.md:8-10`, `README.md:125-158`
  - README 已把目标工具列为 Cursor / Claude Code / Codex / Kiro / 通用 coding agent，并说明通用 agent 可通过普通消息执行命令。来源: `README.md:10-20`, `README.md:74-80`
  - Codex plugin manifest 当前只声明 skills 与交互/写能力，没有 MCP server 或 mobile runtime 声明。来源: `plugins/sandtable/.codex-plugin/plugin.json:10-26`
  - SessionStart hook 当前只注入 `using-sandtable` skill 上下文，没有启动任何 server。来源: `hooks/session-start:1-33`
  - 安装说明只安装方法论资产、hook、Codex plugin manifest/marketplace，不包含 server/mobile app。来源: `INSTALL.md:60-100`, `INSTALL.md:174-222`
  - 更新说明明确只更新方法论资产，最高红线是不读写/覆盖/删除 `docs/sandtable/` 下任何战役记忆。来源: `UPDATE.md:30-38`, `UPDATE.md:62-100`
  - 全局约束要求配套脚本零运行时依赖、禁止引入新的第三方依赖。来源: `docs/sandtable/constraints.md:5-18`
- 未知/风险:
  - Flutter App、MCP server、移动端通信机制是否允许作为本需求的新 runtime package 引入第三方依赖，需要开发者确认。
  - 手机端是否必须走公网推送，还是只要求同一局域网/本机配对访问，需要开发者确认。
  - "低级模型子 agent 轮询信箱并通知主 agent"在不同 agent 宿主中的最小通用接口尚未确认；必须避免依赖某一工具私有能力。

## 2026-06-13 12:16 · [决策]
- 背景: PRD 写作可以基于已确认事实推进，但后续 TESTCASES/PLAN/推演需要 PRD 确认门禁。
- 内容: 先写 PRD 草案和阻塞问题；`state.md` 保持 `blocked=true`，等待开发者确认依赖例外和通信边界。
- 依据/来源: `skills/writing-prd/SKILL.md` 的 PRD 确认门禁；`docs/sandtable/constraints.md:5-18` 的全局约束。

## 2026-06-13 17:45 · [问答]
- 背景: 上一轮收尾给出推荐继续模板，要求确认 Q1/Q2/Q3 后进入 tests.md。
- 内容: 开发者连续回复"继续"。按上下文记录为接受推荐默认项：Q1 允许新增可选 runtime 子系统，但现有安装/更新方法论资产仍保持零依赖；Q2 首版只做本机/局域网 server + 手机扫码配对；Q3 采用"文件信箱 + MCP 工具"的通用协议。
- 依据/来源: 开发者本回合消息"继续"。

## 2026-06-13 17:45 · [测试]
- 背景: PRD 阻塞已解除，需要把抽象验收标准转为可审阅黑盒用例。
- 内容: 创建 `tests.md`，覆盖启动/停止 server、MCP 同步、无 MCP 文件信箱、手机配对查看、手机回答写回、PRD 确认门禁、常驻轮询唤醒、安装更新边界和手机非事实源等场景。
- 依据/来源: `prd.md` FR1-FR8 与验收标准。

## 2026-06-13 17:56 · [计划]
- 背景: 开发者要求"下一步要干什么，写详细的plan 吧"。
- 内容: 记录为 tests.md 方向确认，创建 `plan.md`。计划采用可选 runtime 架构：`runtime/server` 提供 Node/TypeScript server、MCP、文件信箱、HTTP/配对/事件流；`apps/mobile` 提供 Flutter Android/iOS App；文档和 skill 接线只做最小边界说明，保持现有安装/更新方法论资产零依赖、不触碰 `docs/sandtable/` 战役记忆。
- 依据/来源: 开发者本回合消息；`prd.md` FR1-FR8；`tests.md` TC1-TC10。

## 2026-06-13 18:13 · [推演]
- 背景: 执行 mental-rehearsal，只读推演 plan.md 是否闭环。
- 内容: mental-1 返回 ANOMALY_FOUND。P1 包括：文件信箱没有桥接到手机/outbox；常驻轮询协议不足；扫码配对被计划成后续；`POST /stop` 未实现；MCP/document snapshot 未进入事件流；手机问题回答只写 journal 不足以解除阻塞。安装/更新边界视角 LOGIC_CLOSED，仅有 P2/P3 风险。
- 修正: 已回修 `plan.md`，新增事件桥、outbox、polling cursor、MCP event publish、HTTP SSE、pairing token/qrPayload、token 校验、`POST /stop`、questions/state 写回和更强 e2e 断言。
- 依据/来源: `rehearsals/mental-1.md`；主 agent 亲自核实 `plan.md`、`prd.md`、`tests.md`。

## 2026-06-13 18:28 · [调整]
- 背景: 开发者指出关键缺口："plan 和 prd 好像没有写，就是要让 agent 不能终止，以及让子 agent 等待信箱的过程"。
- 内容: 已把该要求提升为 PRD FR9、MUST/MUST NOT 和验收标准；新增 TC11/TC12；在 plan 中新增 continuation lease 协议、`.sandtable-runtime/session/continuation.json`、`runtime/server/src/continuation.ts`、`continuation.test.ts`，并把 polling worker 的空轮询、cursor、heartbeat、mobile 通知和 stop 退出过程写入 T3/T9/T11。
- 依据/来源: 开发者本回合反馈。

## 2026-06-13 18:51 · [决策]
- 背景: 主 agent 提出更保守的 guardian/resume 方案后，开发者明确要求按原方向推进：未来 agent 应是持续工作态，像人类流水线一样由主 agent 和许多不同功能子 agent 协同；没有确定终止时就一直存活，等待方式不局限于单个子 agent 或 wait/轮询，子 agent 可以便宜甚至免费。
- 内容: 已将 FR9/TC12/plan 的模型从单一 polling worker 扩展为低成本/免费等待 worker 队列：可 poll、subscribe、host-wait 或 mixed；通过 continuation lease、cursor、heartbeat、接力规则和 stop event 维持长驻流水线。
- 依据/来源: 开发者本回合反馈。

## 2026-06-13 19:06 · [集成]
- 背景: 开发者显式要求直接实现完整代码，并跳过 live/实现预演。
- 内容: 已创建 `runtime/server` Node/TypeScript runtime，包含 mailbox、events、polling cursor、continuation lease、Sandtable durable writes、真实 stdio MCP server 入口、HTTP/SSE/pairing/stop API 和测试；已创建 `apps/mobile` Flutter Android/iOS App，包含二维码配对、文档查看、回答/确认提交和停止入口；已补 `docs/mobile-review-companion/`、README/INSTALL/UPDATE、四份 `using-sandtable` runtime 接线。
- 验证: `npm --prefix runtime/server run typecheck` 通过；`npm --prefix runtime/server test` 通过；`flutter analyze` 通过；`flutter test` 通过。`flutter build apk --debug` 已尝试，阻塞在本机 Gradle 下载 AndroidX `appcompat:1.4.2` 的 TLS 握手错误，非 Dart/Flutter analyze/test 层代码错误；已中止自动重试。
- 依据/来源: 开发者本回合指令。

## 2026-06-14 12:27 · [重构]
- 背景: 开发者要求当前实现升级为成熟架构：同一 server 可承载多个 agent、多个同/异 agent 会话；手机端可同时管理会话列表、查看状态、进入会话详细沟通；代码模块解耦、便于扩展和 AI 阅读。
- 内容: 服务端新增 `RuntimeSession` / `AgentIdentity` 抽象和持久化 `sessions.json`，新增 `/agent/sessions`、`/sessions`、`/sessions/:id`、`/sessions/:id/events`、`/sessions/:id/documents/:name`、`/sessions/:id/messages` API；旧 feature API 和 mobile-sync API 保持兼容，并把旧配对流程桥接到 session。手机端把 connection 改为 server-level token，新增会话列表工作台和会话详情页，详情页支持文档入口、实时事件、对话、answer/confirmation 快捷发送。
- 验证: `npm --prefix runtime/server run typecheck` 通过；`npm --prefix runtime/server test` 通过，新增多 agent 多会话 HTTP 测试；`flutter analyze` 通过；`flutter test` 通过。
- 依据/来源: 开发者 2026-06-14 对多 agent、多会话、商业化 UI、解耦架构的明确要求。

## 2026-06-15T07:07:47.544Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-review-companion
- 内容: Mobile message
- 内容: 测试一下
- Target: conversation

- 来源: mobile-app:sess_KZxtECWdip0o

## 2026-06-15T07:49:08.785Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-review-companion
- 内容: Mobile message
- 内容: 在吗
- Target: conversation

- 来源: mobile-app:sess_KZxtECWdip0o

## 2026-06-15T08:01:08.030Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-review-companion
- 内容: Mobile message
- 内容: 还在吗
- Target: conversation

- 来源: mobile-app:sess_d1FgN5CFpdPY

## 2026-06-15T08:02:21.340Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-review-companion
- 内容: Mobile message
- 内容: 1、告诉 子 agent 不要做任何事情，只需要等 wait 命令返回就行，不设超时，永久等待
2、人不用手机，直接通过电脑端跟 agent 继续会话时，只要判定 sync server 还在，那么就要在关键和恰当的时机继续同步消息
3、手机上通知做事情，或者电脑端直接跟 agent 会话，只要 sync server 还在，那么就要在做事情的前中后，等重要时机进行信息同步
4、怎么能让在电脑端跟 agent 持续对话过程中也不忘我们以上的规则
- Target: conversation

- 来源: mobile-app:sess_d1FgN5CFpdPY

## 2026-06-15 16:05 · [决策/实现]
- 背景: 手机端提出 4 条规则（见上一条 08:02:21 消息）：①等待子 agent 纯等待、永久阻塞、不设超时；②③只要 sync server 活着，无论指令来自手机还是电脑端直接对话，都要在重要动作前/中/后等关键时机主动同步到手机；④如何在电脑端长对话中不遗忘以上规则。
- 内容: 把规则落成持久方法论资产（外科手术式改动）：
  - `skills/mobile-companion/SKILL.md` 新增「常驻同步义务（sync server 活着即生效）」小节 + 两条 Red Flag（覆盖 ①②③）；英文真源 `locales/en/skills/mobile-companion/SKILL.md` 同步。
  - `AGENTS.md` 与 `.cursor/rules/sandtable.mdc`（始终加载）各加「手机同步常驻义务」段；英文 `locales/en/AGENTS.md` 与 `locales/en/.cursor/rules/sandtable.mdc` 同步（覆盖 ④：放进始终加载的行为基线）。
  - `hooks/session-start`：检测 `.sandtable-runtime/session/mobile-sync.json` 的 `active=true` 时，向 SessionStart 上下文追加常驻同步义务提醒（覆盖 ④：换会话/上下文压缩后自动重新注入）。
  - 运行行为调整：等待子 agent 默认不再传 `SANDTABLE_WAIT_MAX_SECONDS`，改为永久阻塞（仅宿主有硬执行上限时才用兜底，超时即无缝再派）。
- 验证: `bash scripts/sandtable-sync.sh` 镜像到 `plugins/sandtable/skills` 等并 `--check` 全部一致；`hooks/session-start` 在 active/非 active 两种情形均输出合法 JSON，且仅 active 时注入提醒。
- 依据/来源: 手机端开发者 2026-06-15 08:02 的 4 点要求。

## 2026-06-15T08:27:31.532Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-review-companion
- 内容: Mobile message
- 内容: 在吗
- Target: conversation

- 来源: mobile-app:sess_d1FgN5CFpdPY

## 2026-06-15 18:05 · [停止]
- 背景: 开发者在电脑端要求「停止同步/终止同步」。
- 内容: 运行 `scripts/sandtable-mobile-stop.sh`，关闭 mobile-sync 与 runtime server（端口 8767）。
- 验证: `GET http://127.0.0.1:8767/health` 已不可达，确认 server 已下线；手机 App 将显示 Reconnecting/Disconnected。需重新 `/sandtable-mobile-start` 才能再同步。
- 依据/来源: 开发者本回合指令。
