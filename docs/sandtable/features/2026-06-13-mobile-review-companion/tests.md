# Mobile Review Companion 测试用例

> tests.md = 理解闸门。以下用例用于让开发者审阅 AI 是否理解需求；可执行检查会在 plan.md 中细化。

## TC1 · 启动可选全局 server

**映射:** FR1, 验收标准 1, MUST "必须有 server"

**Given:** 开发者已在一个安装了 Sandtable 的项目中，并选择启用 mobile review companion runtime。

**When:** 开发者开始一次 Sandtable 会话，并按文档启动全局 Sandtable server。

**Then:** 电脑端显示 server 已运行、监听地址、配对入口和停止方式；server 不绑定当前单个 feature 目录，切换 feature 后仍能继续服务；开发者执行停止操作后，手机端连接断开且电脑端不再显示常驻轮询进行中。

**状态:** 待验证

## TC2 · MCP 同步 Sandtable 进度

**映射:** FR2, 验收标准 2

**Given:** server 已运行，支持 MCP 的 agent 已接入 Sandtable MCP 工具，当前 feature 有 `state.md` 与 `prd.md`。

**When:** agent 完成 RECON、写入 PRD 草案，并通过 MCP 同步当前阶段、PRD 摘要和待确认事项。

**Then:** server 事件流中出现同一 feature id 的阶段更新、PRD 文档快照和待确认问题；手机端在不重启 App 的情况下看到 phase 从 RECON/OBJECTIVES 更新为最新状态，并能打开 PRD 内容。

**状态:** 已实现（Flutter SSE 客户端 + sync 端点）；待 iOS 真机确认 — 见 `features/2026-06-13-mobile-listening-test`

## TC3 · 无 MCP agent 使用文件信箱协议

**映射:** FR5, 验收标准 3, MUST NOT "不得要求所有 agent 都必须支持 MCP"

**Given:** 一个通用 coding agent 不支持 MCP，但能读写项目文件；server 已运行并监听 Sandtable 文件信箱。

**When:** agent 按协议写入一条包含 feature id、phase、message type 和 payload 的文件信箱消息。

**Then:** server 读取并标记该消息为已处理，手机端展示相同的阶段/消息内容；agent 不需要调用 MCP 也能完成最低可用的状态同步。

**状态:** 待验证

## TC4 · 手机 App 配对并查看文档

**映射:** FR3, FR4, 验收标准 4

**Given:** server 运行在电脑本机/局域网，手机与电脑在同一网络，Flutter App 已安装在 Android 或 iOS 设备上。

**When:** 开发者用手机 App 扫描电脑端配对码，并进入当前 Sandtable feature。

**Then:** App 显示当前 feature 的 state、prd、tests、plan、journal、questions 入口；打开 PRD/tests/plan 时看到与项目文件一致的内容；未生成的文档显示为"尚未生成"状态而不是空白或错误页面。

**状态:** 待验证

## TC5 · 手机端回答问题并写回记忆

**映射:** FR3, FR4, FR7, 验收标准 5, MUST "必须把手机端答复写回可追溯的 Sandtable 记忆"

**Given:** 当前 feature 的 `questions.md` 中有一个阻塞问题，手机 App 已连接 server。

**When:** 开发者在手机 App 中提交回答，并点击确认发送。

**Then:** server 把回答写回可追溯的 Sandtable 记忆，至少包含问题 id、回答内容、来源为 mobile app、时间戳和 feature id；后续 agent 读取 `state.md` / `journal.md` / `questions.md` 时能判断该阻塞已解除或需要进一步处理。

**状态:** 待验证

## TC6 · 手机端确认 PRD 后通过门禁

**映射:** FR7, 验收标准 5, MUST "必须允许手机端审阅、回答问题、确认 PRD/tests/plan 或阻塞裁决"

**Given:** `prd.md` 已生成但尚无可追溯开发者确认记录，Sandtable PRD 门禁阻止进入 TESTCASES。

**When:** 开发者在手机 App 中确认 PRD 方向认可并提交。

**Then:** `journal.md` 或 `state.md` 出现可追溯 PRD 确认证据，包含开发者确认原文、来源 mobile app、时间戳和 feature id；agent resume 后允许继续写 `tests.md`，不会误判为未确认。

**状态:** 待验证

## TC7 · 常驻低成本轮询唤醒主流程

**映射:** FR6, 验收标准 6

**Given:** 主 agent 已完成一次阶段性工作并进入常驻等待；低成本轮询子 agent 正在监听文件信箱或 server mailbox。

**When:** 手机 App 提交一条新的开发者回答或确认。

**Then:** 轮询子 agent 检测到新消息并通知主 agent；主 agent 处理该消息、更新 Sandtable 记忆，并继续从正确 phase 恢复，而不是结束会话或要求开发者回电脑重复输入。

**状态:** 待验证

## TC8 · 电脑端主动停止常驻会话

**映射:** FR1, FR6, 验收标准 1, MUST "必须提供电脑端主动停止常驻会话的机制"

**Given:** server 和轮询子 agent 都在运行，手机 App 已连接。

**When:** 开发者在电脑端执行停止命令。

**Then:** server 停止接收新连接，轮询子 agent 停止轮询，手机 App 显示已断开/需重新配对；不会继续唤醒主 agent。

**状态:** 待验证

## TC9 · 安装/更新边界不破坏现有战役记忆

**映射:** FR8, 验收标准 7, MUST "必须保护已有 `docs/sandtable/` 数据", MUST NOT "不得让安装/更新脚本默认覆盖或删除用户已有战役记忆"

**Given:** 一个项目已有 `docs/sandtable/features/existing-feature/`，并包含用户历史 PRD、tests、plan、state、journal、questions。

**When:** 开发者安装或更新 Sandtable 方法论资产，并选择不启用 mobile runtime。

**Then:** 现有 `docs/sandtable/` 内容没有被覆盖、删除或迁移；方法论安装/更新脚本仍不要求 Flutter、Node、Dart 或其它 runtime 依赖。

**状态:** 待验证

## TC10 · 手机状态不是唯一事实来源

**映射:** FR7, MUST NOT "不得让手机 App 的状态成为唯一事实来源"

**Given:** 手机 App 曾显示某 feature 的 PRD 确认和问题回答，随后 App 被卸载或本地缓存被清空。

**When:** 开发者在电脑端重新运行 `/sandtable-resume` 或通用 agent 读取 Sandtable 记忆。

**Then:** agent 能仅凭项目内 Sandtable 文件恢复确认记录、问题回答和当前 phase；不会依赖手机 App 本地缓存作为唯一事实来源。

**状态:** 待验证

## TC11 · active runtime 下主 agent 不终止

**映射:** FR6, FR9, 验收标准 6-8, MUST "必须在 active runtime 下阻止主 agent 可控范围内的普通终止"

**Given:** mobile review runtime 处于 active 状态，server 仍在运行，当前 feature 没有 stop event。

**When:** 主 agent 完成一次阶段性动作，例如写完 PRD、tests、plan、推演报告或处理手机端回答。

**Then:** 主 agent 在结束该动作前创建或刷新 continuation lease，记录当前 feature、phase、lease owner、expiresAt/renewAfter、polling worker id 和 resume hint；主 agent 不输出“会话结束/任务完成后不再等待”的终止语义，而是把等待信箱职责交给轮询子 agent。

**状态:** 待验证

## TC12 · 低成本子 agent 队列持续等待信箱

**映射:** FR6, FR9, 验收标准 8, MUST "必须定义低成本/免费子 agent 队列的等待信箱流程"

**Given:** continuation lease 存在，一个或一组低成本/免费等待子 agent 已启动，`.sandtable-runtime/mailbox/outbox/` 当前没有新消息。

**When:** 等待子 agent 按协议空等三轮，期间可以轮询、订阅或使用宿主可用的其它等待操作；随后收到一条 mobile confirmation 消息，再收到 stop event。

**Then:** 空等待只刷新 cursor/heartbeat/lease，不修改 PRD/tests/plan；收到 mobile confirmation 时，负责该消息的子 agent 用通知 payload 唤醒主 agent 或接力给对应职责子 agent，并保留 cursor 去重；收到 stop event 后，所有等待子 agent 标记 lease stopped 并停止等待。

**状态:** 待验证
