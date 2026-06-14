# Mobile Review Companion PRD

> 对应 project.md 北极星 / 继承 constraints.md 红线。实现细节见 plan.md。

## 1. 目标

让 Sandtable 在保持跨 agent 通用性的前提下，提供一个可选的全局协作运行时：AI 在推进 PRD、tests、plan、推演、阻塞问题和状态变化时同步到本机 server；Android/iOS Flutter App 可实时查看、审阅和回答；主 agent 完成本轮工作后仍通过低成本轮询子 agent 监听手机端反馈，直到开发者在电脑上主动停止。

## 2. 背景与现状

- Sandtable 的北极星是给 coding agent 用的方法论插件，目标是让 AI 把简单需求做成逻辑闭环、细节完美的功能。来源: `docs/sandtable/project.md:5-6`
- 运行时状态目前落在目标项目的 `docs/sandtable/`，包括 `project.md`、`constraints.md`、`features/<date-slug>/{prd,tests,plan,state,journal,questions}.md` 和 `rehearsals/`。来源: `docs/sandtable/project.md:8-10`, `README.md:149-158`
- 当前跨工具入口覆盖 Cursor / Claude Code / Codex / Kiro / 通用 agent，通用 agent 可把 Sandtable 命令作为普通消息执行。来源: `README.md:10-20`, `README.md:74-80`
- Codex plugin manifest 目前只声明 skills 与交互/写能力，没有声明 MCP server 或移动端运行时。来源: `plugins/sandtable/.codex-plugin/plugin.json:10-26`
- SessionStart hook 当前只注入 `using-sandtable` skill 上下文，不启动 server。来源: `hooks/session-start:1-33`
- 安装/更新流程当前只复制方法论资产、hooks 与插件 manifest；更新还明确不触碰 `docs/sandtable/` 战役记忆。来源: `INSTALL.md:60-100`, `UPDATE.md:30-38`
- 全局约束当前要求配套脚本零运行时依赖，并禁止引入新的第三方依赖。来源: `docs/sandtable/constraints.md:5-18`

## 3. 方案探索

### 方案 A · 推荐: 文件信箱为核心，MCP/server/app 是适配层

- 做法: 定义一个通用 mailbox/state sync 文件协议，所有 agent 都能通过读写文件参与；MCP server 读取这些文件并向手机 App 同步。支持 MCP 的 agent 可直接调用 MCP 工具，不支持 MCP 的 agent 仍按文件协议工作。
- 优点: 最大化跨 agent 通用性；延续 Sandtable 现有 `docs/sandtable/` 可续接设计；不会把能力锁死在 Codex 或 Claude。
- 代价: 需要非常清晰的文件协议、冲突规则和轮询纪律。

### 方案 B · MCP 优先，文件为辅助

- 做法: 所有同步都通过 MCP 工具完成，server 维护事件和手机 App 状态；文件只作为 Sandtable 原有产物存储。
- 优点: 实时性和接口体验更统一。
- 代价: 不支持 MCP 或 MCP 接线弱的 agent 会退化严重，违反"所有 agent 都可以使用"的核心诉求。

### 方案 C · 先做手机 Web UI，Flutter App 后置

- 做法: server 提供本机 Web UI/PWA，手机浏览器访问；Flutter App 后续再做。
- 优点: 依赖和发布成本较低。
- 代价: 不满足开发者明确提出的 Flutter App、Android/iOS 安装要求。

开发者已确认选择方案 A：把 Flutter/server 作为可选 runtime 子系统；现有方法论安装/更新脚本继续保持零依赖和不触碰战役记忆。

## 4. 用户故事 / 场景

- 作为正在使用 Cursor / Claude Code / Codex / 通用 agent 的开发者，我希望启动 Sandtable skill 后自动拥有一个本机协作 server，以便手机能看到 AI 当前进度和需要我确认的问题。
- 作为开发者，我希望在 Android/iOS App 上审阅 PRD、tests、plan、state、journal、questions，并能回答问题或确认文档，以便不用一直守在电脑前。
- 作为主 agent，我希望在完成本轮工作后不直接结束，而是把工作交给一个或一组低成本/免费子 agent 持续监听信箱，以便手机端反馈能被流水线中的 agent 接住并重新交回主流程处理。
- 作为维护者，我希望这个能力不绑定任何单一 AI 工具，以便 Cursor / Claude Code / Codex / 通用 agent 都能按同一协议使用。

## 5. 功能需求

- FR1: 启动 Sandtable 会话时，提供一种可选方式启动全局 Sandtable server；server 生命周期不绑定单个 feature，开发者可在电脑上主动停止。〔已确认: 开发者原始需求 + 2026-06-13 "继续"确认推荐默认项〕
- FR2: server 必须提供 MCP 接口，允许 AI 在恰当进度同步 state、prd、tests、plan、journal、questions、rehearsal 摘要和待确认事项。〔已确认: 开发者原始需求〕
- FR3: server 必须把 MCP/文件信箱中的事件转发到手机 App，并接收 App 的审阅、回答、确认和操作反馈。〔已确认: 开发者原始需求〕
- FR4: Flutter App 必须支持 Android 与 iOS，能够查看 PRD、plan、testcases、状态、问题，并提交回答/确认。〔已确认: 开发者原始需求；发布方式待后续计划细化〕
- FR5: 方案必须完全通用，不得只依赖 Codex、Cursor 或 Claude Code 的私有能力；不支持 MCP 的 agent 也要有最低可用路径。〔已确认: 开发者原始需求 + 2026-06-13 "继续"确认采用文件信箱协议〕
- FR6: 主 agent 每次完成阶段性工作后，不应直接结束会话；应进入常驻循环，由低成本轮询子 agent 监听信箱，有消息或状态变化时通知主 agent 处理，直到开发者在电脑上主动停止。〔已确认: 开发者原始需求 + 2026-06-13 "继续"确认采用文件信箱 + MCP 工具〕
- FR7: 手机端回答必须可追溯写回 Sandtable 记忆，尤其是 PRD 确认、问题回答、阻塞解除和开发者裁决，供后续 PRD 门禁、推演和 resume 使用。〔已确认: 由现有 state/journal 规则推导；来源 `skills/state-and-memory/SKILL.md`〕
- FR8: 安装/更新边界必须保护现有 `docs/sandtable/` 战役记忆；新增运行时不得让更新脚本覆盖用户历史。〔已确认: 继承 `UPDATE.md:30-38`〕
- FR9: 当 mobile review runtime 处于 active 状态时，Sandtable agent 流水线必须保持工作态：主 agent 在其可控行为范围内不得把 Sandtable 会话作为已完成而终止；每次阶段性动作结束前，必须创建或刷新 continuation lease，并把等待手机信箱的职责交给一个或一组低成本/免费子 agent。子 agent 可以轮询、订阅、等待事件或使用其它宿主可用操作，但必须按同一信箱/lease 协议维持等待，直到电脑端显式 stop、stop mailbox event 或开发者明确要求停止。〔已确认: 开发者 2026-06-13 指出关键缺口并确认 agent 长驻流水线方向〕

## 6. 验收标准（成功定义 · 抽象层）

- [ ] 开发者可以在支持的环境中启动 Sandtable server，并在电脑上主动停止。
- [ ] 支持 MCP 的 agent 可以通过 MCP 同步 Sandtable 阶段进展、文档快照、待确认事项和手机端答复。
- [ ] 不支持 MCP 的 agent 仍可通过通用文件信箱协议参与同一流程。
- [ ] Android/iOS Flutter App 可以连接 server，展示 PRD / tests / plan / state / journal / questions，并提交回答或确认。
- [ ] 手机端提交的确认/回答会被持久化到 Sandtable 记忆，后续 agent resume 时能恢复并继续。
- [ ] 主 agent 完成阶段性工作后有明确常驻轮询机制，收到手机端新消息后能重新进入处理流程。
- [ ] active runtime 下，主 agent 阶段性动作结束前会留下 continuation lease 和 polling handoff；没有 stop 信号时不会输出“会话结束/任务完成后不再等待”的终止语义。
- [ ] 一个或一组低成本/免费子 agent 能按协议持续等待信箱，使用 cursor/lease 去重和续租；收到 mobile/stop 事件后按职责通知主 agent或接力给对应子 agent；stop 之外的空等待不会修改 Sandtable 文档。
- [ ] 现有安装/更新方法论资产的零依赖和不破坏 `docs/sandtable/` 红线没有被破坏；新增依赖只存在于已确认的可选 runtime 子系统内。

## 7. MUST（绝对要做）

- 必须支持 Android 与 iOS 的 Flutter App。
- 必须有 server，并提供 MCP 接口。
- 必须能把 AI 进度和 Sandtable 文档同步到手机端。
- 必须允许手机端审阅、回答问题、确认 PRD/tests/plan 或阻塞裁决。
- 必须支持 Cursor / Claude Code / Codex / 通用 agent 的最低共同协议。
- 必须把手机端答复写回可追溯的 Sandtable 记忆。
- 必须提供电脑端主动停止常驻会话的机制。
- 必须在 active runtime 下阻止主 agent 可控范围内的普通终止，改为 continuation lease + polling handoff。
- 必须定义低成本/免费子 agent 队列的等待信箱流程、cursor、lease/heartbeat、通知 payload、接力规则、stop 条件和禁止写入范围。
- 必须保护已有 `docs/sandtable/` 数据。

## 8. MUST NOT（绝对不能做）

- 不得把方案绑定为 Codex-only、Cursor-only 或 Claude-only。
- 不得要求所有 agent 都必须支持 MCP 才能使用最低能力。
- 不得让手机 App 的状态成为唯一事实来源；Sandtable 文件记忆仍必须可恢复。
- 不得在现有方法论安装/更新脚本中默认引入新的第三方依赖或运行时包；新增依赖只能属于显式启用的可选 runtime 子系统。
- 不得让安装/更新脚本默认覆盖或删除用户已有战役记忆。
- 不得在 active runtime 且无 stop 信号时把主 agent 回复为最终结束状态。
- 低成本/免费等待子 agent 不得自行修改 PRD/tests/plan 或替主 agent 做产品裁决；除非被明确分配对应职责，否则只能等待、去重、通知、续租或停止。
- 不做未被要求的兜底逻辑 / 不节外生枝。

## 9. 非目标 / 暂不做（YAGNI）

- 首版不默认做公网账号系统、云中继或商店发布流程；通信边界为本机/局域网 server + 手机扫码配对。
- 首版不承诺替代各 agent 自身的 UI、权限模型或进程管理。
- 首版不把手机端做成 Sandtable 文档唯一编辑器；它是审阅/回答/确认与状态查看入口。
- 首版不自动迁移或改写既有 feature 文档结构，除非 plan 明确列出兼容迁移步骤并通过推演。

## 10. 已确认问题

- Q1: 允许新增可选 runtime 子系统；现有安装/更新方法论资产仍保持零依赖。
- Q2: 首版只做本机/局域网 server + 手机扫码配对。
- Q3: 采用"文件信箱 + MCP 工具"的通用协议。

见 `questions.md`。
