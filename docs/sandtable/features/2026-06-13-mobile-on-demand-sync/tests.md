# 按需 Mobile 同步 测试用例

> tests.md = 理解闸门。以下用例用于让开发者审阅 AI 是否理解需求；可执行检查会在 plan.md 中细化。

## TC1 · start 输出 4 位配对码并拉起 server

- **映射**：FR1 / 验收「start 输出 4 位码」
- **Given**：Sandtable 项目已安装 mobile runtime；当前无 server 监听 8765；存在活跃 feature `2026-06-13-mobile-on-demand-sync`
- **When**：开发者在 Cursor 执行 `/sandtable-mobile-start`
- **Then**：终端醒目输出 4 位数字配对码、LAN Server URL（如 `http://192.168.x.x:8765`）、feature id；`GET http://127.0.0.1:8765/health` 返回 ok；session 文件写入 `.sandtable-runtime/`
- **状态**：已验证

## TC2 · 手机 PIN 配对成功

- **映射**：FR2 / 验收「手机配对后 status 显示 paired」
- **Given**：TC1 已完成；iPhone App 与电脑在同一局域网
- **When**：开发者在 App 输入 Server URL + 4 位配对码并点「连接」（或扫 QR `sandtable://pair?…`）
- **Then**：App 调用 `POST /pair/by-code` 获得 device-level token，进入 session 列表；电脑 `/sandtable-mobile-status` 三步均为 ✓
- **状态**：已验证

## TC3 · stop 终止同步并关闭 server

- **映射**：FR3 / 验收「stop 后 health 不可用或 session inactive」
- **Given**：TC2 已完成，mobile sync active
- **When**：开发者执行 `/sandtable-mobile-stop`
- **Then**：`curl http://127.0.0.1:8765/health` 连接失败；手机 App 显示 Reconnecting/Disconnected；feature `journal.md` 追加 stop 记录
- **状态**：已验证

## TC4 · status 查看三步进度

- **映射**：FR4
- **Given**：server 运行中，sync session 存在
- **When**：开发者执行 `/sandtable-mobile-status` 或 `GET /mobile-sync/status`
- **Then**：返回 `steps.server` / `phonePaired` / `agentSynced` 及当前 phase、feature id
- **状态**：已验证

## TC5 · 手机 chat 消息经 inbox 到达主 agent

- **映射**：FR5 / 验收「手机回答/确认进入 outbox，worker 可轮询并唤醒主 agent」
- **Given**：TC2 已完成；inbox wait 子 agent 已启动
- **When**：开发者在手机 App 发送 chat 消息「测试一下」
- **Then**：wait 脚本在 5s 轮询内返回 inbox JSON；主 agent 收到 `type: chat_message`；回复后手机会话显示 agent 消息；`POST /mailbox/inbox/ack` 成功
- **状态**：已验证

## TC6 · 手机 answer/confirmation 写回 journal

- **映射**：FR5 / MUST「必须把手机端答复写回可追溯的 Sandtable 记忆」
- **Given**：当前 feature 的 `questions.md` 有阻塞问题，或 PRD 待确认；手机已配对
- **When**：开发者在手机 App 提交 answer 或 confirmation
- **Then**：`journal.md` 追加来源为 `mobile-app:<sessionId>` 的记录；answer 时 `questions.md` 同步更新；主 agent 收到 `question_answer` 或 `confirmation` 类型 inbox 消息
- **状态**：待验证

## TC7 · Agent 推 phase 后手机 UI 更新

- **映射**：PRD 验收「主 agent 推 phase 后手机 Listening UI 更新」
- **Given**：手机已配对；主 agent 更新 `state.md` phase
- **When**：主 agent 执行 `POST /mobile-sync/push-state` 或 MCP `sandtable_sync_phase`
- **Then**：手机 App 阶段卡片更新为最新 phase，无需重启 App
- **状态**：待验证

## TC8 · 重复 start 生成新配对码

- **映射**：FR1
- **Given**：server 已在运行，之前已配对
- **When**：开发者再次执行 `/sandtable-mobile-start`
- **Then**：输出新的 4 位配对码；若手机已连接则 status 仍显示 paired；inbox wait 子 agent 可重新拉起
- **状态**：已验证

## TC9 · server 意外退出后可重启

- **映射**：FR1 / 运维场景
- **Given**：之前 start 过但 server 进程已退出（8765 不可达）
- **When**：开发者再次 `/sandtable-mobile-start`
- **Then**：server 重新拉起；输出新配对码；手机需重新连接或自动 Reconnecting 后恢复
- **状态**：已验证

## TC10 · wait 子 agent 单职责不越权

- **映射**：slash 命令约束 / MUST NOT「wait 子 agent 不得查 status、改文档」
- **Given**：inbox wait 子 agent 已启动
- **When**：子 agent 运行 `scripts/sandtable-mobile-wait.sh <feature>`
- **Then**：仅轮询 `GET /mailbox/inbox`；收到消息后原样交给主 agent 并退出；不读 journal、不改 PRD、不查 health
- **状态**：已验证

## TC11 · wait 子 agent 在 loopback 被沙箱禁止时读取 inbox

- **映射**：FR5 / TC5 / Codex 运行环境兼容性
- **Given**：手机消息 JSON 已写入当前仓库 `.sandtable-runtime/mailbox/inbox/`；wait 子 agent 对 `127.0.0.1:<server.port>` 的 curl 返回 `Operation not permitted`
- **When**：子 agent 运行 `scripts/sandtable-mobile-wait.sh <feature>`
- **Then**：脚本从 inbox 文件读取消息，执行与 HTTP endpoint 相同的 `source=mobile`、feature、after 过滤和 id 排序，并立即向主 agent 返回消息；不得把连接失败误判为永久空 inbox
- **状态**：已验证（2026-06-19，强制端口 1 不可达时返回 3 条 inbox 消息，退出码 0）

## TC12 · 关键节点通知自动修正 stale sessionId

- **映射**：手机同步常驻义务 / FB-2026-06-19-02
- **Given**：mobile-sync active；启动时绑定 session A，但配对前 A 被删除，server 为同一 feature 创建 session B
- **When**：手机完成配对，随后 agent 调用 `POST /mobile-sync/notify` 或 `scripts/sandtable-mobile-notify.sh status <消息>`
- **Then**：配对响应与 `mobile-sync.json.sessionId` 均指向 B；关键进展作为可见 conversation message 写入 B；无需等待手机先发消息来发现 B；`agent-state` 仅更新状态灯
- **状态**：已验证（2026-06-19，自动测试 + 真机 live notify）

## TC13 · 主 agent 状态只反映真实处理边界

- **映射**：运行态同步 / FB-2026-06-19-03
- **Given**：mobile-sync active 且 main agent 当前为 idle；waiter 取得一条手机 chat 消息
- **When**：waiter GET inbox 但 main 尚未恢复执行；随后 main 从 wait 返回并开始处理；最后完成 reply/ack/文档/推送
- **Then**：inbox GET 不擅自改变 main 状态；main 真正恢复后的第一动作通过 `sandtable-mobile-main-state.sh working` 显示处理中；全部处理完成的最后动作通过该脚本切回 idle
- **状态**：已验证（2026-06-19，自动测试 + live helper；待开发者手机确认视觉时序）

## TC14 · 手机可见消息遵循 Markdown 格式契约

- **映射**：FR6 / FB-2026-06-20-04
- **Given**：mobile-sync active；agent 需要同步多事实进展或待确认问题
- **When**：agent 通过 `sandtable-mobile-notify.sh chat|question -` 从 stdin 发送多行 Markdown
- **Then**：conversation 原样保留粗体标题、空行、扁平列表和反引号；手机 bubble 以 Markdown 渲染；`status/phase` 多行输入被拒绝；裸 JSON、终端噪声和无结构长段落不发送
- **状态**：已验证（2026-06-20，live script + durable conversation；待开发者手机确认渲染）
