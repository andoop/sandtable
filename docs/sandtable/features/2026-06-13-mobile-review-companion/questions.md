# 待澄清问题

## 2026-06-13 17:45 · 已解除阻塞

开发者回复"继续"，按上一轮推荐默认项执行:
- Q1: 允许新增可选 runtime 子系统；现有安装/更新方法论资产仍保持零依赖。
- Q2: 首版只做本机/局域网 server + 手机扫码配对。
- Q3: 采用"文件信箱 + MCP 工具"的通用协议。

## Q1 · 是否允许本需求引入新的运行时和第三方依赖？

状态: 已确认，允许新增可选 runtime 子系统；现有安装/更新方法论资产仍保持零依赖。

- 为什么阻塞: 当前全局约束写明禁止引入新的第三方依赖，但 Flutter App、MCP server、移动端通信、后台轮询/推送通常都需要新的依赖与运行时。
- 已尝试确认: 已读取 `docs/sandtable/constraints.md`、`INSTALL.md`、`UPDATE.md`，未发现针对 server/mobile runtime 的例外。
- 推荐选项: 允许本需求新增一个可选 runtime 子系统；方法论安装/更新脚本仍保持零依赖，server/app 包作为显式启用的独立组件。
- 备选项: 不引入 Flutter/server 代码，只先设计协议和文档；实际 app/server 另开仓库或后续需求实现。

## Q2 · 手机端通信边界是什么？

状态: 已确认，首版只做本机/局域网 server + 手机扫码配对。

- 为什么阻塞: App 到 server 的交互方式决定架构、安全、配对和离线能力。
- 已尝试确认: 仓库现有 hook 只做 SessionStart 上下文注入，没有网络通信或认证模型。
- 推荐选项: 首版只支持本机/局域网 server + 手机扫码配对 + WebSocket/SSE 实时同步；不做公网账号体系和推送通知。
- 备选项: 支持公网中继/云推送；这会显著扩大安全、运维和发布范围。

## Q3 · 常驻会话的通用 agent 协议是否以"信箱文件 + MCP 工具"为核心？

状态: 已确认，采用"文件信箱 + MCP 工具"的通用协议。

- 为什么阻塞: Cursor / Claude Code / Codex 对子 agent、低级模型和后台任务的支持差异很大，需要一个所有 agent 都能遵守的最低共同协议。
- 已尝试确认: 现有 Sandtable 已依赖文件状态机 `docs/sandtable/` 做跨 AI 可续；没有现成信箱协议。
- 推荐选项: 定义 host-agnostic mailbox 文件协议作为权威通道，MCP server 只是读写/通知适配层；支持 MCP 的 agent 用 MCP，不支持 MCP 的 agent 直接读写文件协议。
- 备选项: 只依赖 MCP；这会排除没有 MCP 能力或 MCP 接线不同的 agent。
