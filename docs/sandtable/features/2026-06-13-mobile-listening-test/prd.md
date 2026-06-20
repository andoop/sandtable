# 手机端事件监听测试 PRD

> 对应 project.md 北极星 / 继承 constraints.md 红线（可选 runtime 子系统例外已在前序 feature 确认）。实现细节见 plan.md（PRD 确认后编写）。

## 1. 目标

在真实手机设备上验证 Sandtable Mobile Review Companion 的**监听链路**：当电脑端 runtime/agent 产生阶段或文档更新时，手机 App 能持续连接 server 并收到更新，无需重启 App 或手动刷新列表。

与北极星关系：补齐 mobile-review-companion 中「手机端实时看到 AI 进度」的产品闭环，把 VERIFY 阶段悬而未决的 TC2 变成可验收能力。

## 2. 背景与现状

- Mobile Review Companion 已实现 server（MCP + HTTP + SSE `/events`）与 Flutter App（扫码配对、读文档、回答/确认）。来源: `features/2026-06-13-mobile-review-companion/state.md`, `runtime/server/src/http.ts`
- **缺口（已确认）**：server 有 SSE 事件总线（`GET /events`），但 Flutter `SandtableApi` / `FeatureScreen` **未订阅任何事件流**，用户打开 feature 主页后 UI 静态，无法自动反映 agent 同步的 phase/document 更新。来源: `apps/mobile/lib/api.dart:12-57`, `apps/mobile/lib/screens/feature_screen.dart:69-94`, `runtime/server/src/http.ts:39-49`
- mobile-review-companion 的 TC2 要求：「手机端在不重启 App 的情况下看到 phase 从 RECON/OBJECTIVES 更新为最新状态」。来源: `features/2026-06-13-mobile-review-companion/tests.md:17-27`，**状态：待验证**
- plan 曾规划 App 侧 WebSocket/SSE 与 `web_socket_channel` 依赖，实际 `pubspec.yaml` 未引入，代码未实现。来源: `features/2026-06-13-mobile-review-companion/plan.md:736-771`, `apps/mobile/pubspec.yaml:30-38`
- 开发者原始需求：「测试一下手机上监听」。**已确认（2026-06-13）**：手机 App 订阅 server `/events` SSE；iOS 真机验收；作为 `2026-06-13-mobile-review-companion` VERIFY 续跑并关闭 TC2。见 `questions.md` Q1–Q3。

## 3. 方案探索

### 方案 A · 推荐：Flutter 订阅 server SSE `/events`，真机 E2E 验收

- 做法：在 App 连接 feature 后建立 SSE 客户端（可用 `http` 流式读取或专用 SSE 包），解析 `phase_update` / `document_update` 等事件；更新 feature 主页展示的 phase/blocked 摘要，并在收到文档事件时使文档列表可提示「有更新」或自动 invalidate 缓存。
- 优点：与现有 server API 一致，无需改 server；直接闭合 TC2；延迟低。
- 代价：需处理 iOS 后台/断线重连、App 生命周期；需新增 Flutter 代码与 widget 测试。

### 方案 B：App 端定时轮询 `state` 文档

- 做法：`FeatureScreen` 每 N 秒 `GET /features/:feature/documents/state`，比较 phase/blocked 变化后刷新 UI。
- 优点：实现简单，不依赖 SSE 解析。
- 代价：非实时；与 plan 中「WebSocket/SSE 事件通道」设计不一致；浪费流量；**不能算作「监听」的完整验收**。

### 方案 C：仅手工 E2E，不补代码

- 做法：启动 server，真机配对，用 MCP/curl 触发事件，观察 App（预期：看不到自动更新，TC2 仍失败）。
- 优点：零代码改动，可快速确认当前缺口。
- 代价：**无法满足** TC2 与开发者「监听」诉求；只适合作为 recon 步骤，不适合作为本需求终点。

**已确认采用方案 A**：补齐 Flutter SSE 客户端，在 **iOS 真机**上演练 agent/runtime 发事件 → 手机 UI 更新的完整链路，并作为 companion VERIFY 关闭 TC2。

## 4. 用户故事 / 场景

- 作为开发者，我希望手机 App 在配对后**持续监听**电脑端 Sandtable runtime 的事件，以便离开电脑时仍能看到 agent 推进到 PRD / TESTCASES 等新阶段。
- 作为开发者，我希望在 iOS（或 Android）真机上**跑通一次可重复的测试**，以便确认 local network 权限、局域网 URL 与 SSE 长连接在真实环境下可用。
- 作为维护者，我希望这次测试的结论写回 Sandtable 记忆（journal / companion VERIFY），以便后续 agent resume 知道 TC2 是否已通过。

## 5. 功能需求

- FR1: 手机 App 在已配对并进入 feature 主页后，必须建立对 server `GET /events` 的订阅（SSE），并在连接断开时可感知（显示 disconnected / 尝试重连）。〔已确认: Q1=A〕
- FR2: 收到 `phase_update`（或等价类型）事件时，feature 主页必须更新可见的 phase / blocked 摘要，无需用户手动刷新或重启 App。〔已确认: TC2 + `tests.md:25`〕
- FR3: 收到文档相关事件时，App 必须让用户知晓文档可能已更新（至少：标记 stale 或在再次打开时拉取最新内容）。具体 UI 细节留 plan。〔已确认: 随 TC2 一并验收〕
- FR4: 提供一份**可重复的 iOS 真机测试步骤**（手工或脚本触发 server 事件），使开发者能在本机复现「发事件 → 手机收到」。〔已确认: Q2=iOS 真机〕
- FR5: 测试结论必须写回 Sandtable 记忆，并同步更新 `2026-06-13-mobile-review-companion` 的 TC2 验证状态。〔已确认: Q3=VERIFY 续跑〕

## 6. 验收标准（成功定义 · 抽象层）

- [ ] 真机上的 App 在配对后保持对 server 事件流的订阅，agent/runtime 推送 phase 更新时，用户在 App 内**无需重启**即可看到 phase 变化。
- [ ] 测试步骤可被另一名开发者按文档复现，且结果一致（非一次性 demo）。
- [ ] 不断线场景下，至少一次文档更新事件能反映到 App（打开对应文档时为最新内容或明确提示需刷新）。
- [ ] 测试记录与 pass/fail 结论可追溯写入 Sandtable 文件记忆。
- [ ] 不破坏 mobile-review-companion 已有配对、读文档、回答/确认、stop 能力。

## 7. MUST（绝对要做）

- 必须在 **iOS 真机**上完成监听链路验证。
- 必须覆盖 server 已有 SSE `/events` 协议，不得另造仅 App 本地 mock 的「假监听」冒充验收。
- 必须把测试步骤与结果写入 `journal.md`（及 companion VERIFY 若 Q3=A）。
- 必须继承 mobile-review-companion 的可选 runtime 边界：不把 Node/Flutter 依赖塞进方法论安装脚本。

## 8. MUST NOT（绝对不能做）

- 不得把仅轮询 state 文档冒充 SSE「监听」验收（除非开发者明确选择方案 B 并修改 FR1/验收标准）。
- 不得修改 server 事件协议语义而不更新 protocol 文档。
- 不得破坏 `docs/sandtable/` 既有战役记忆。
- 不做未被要求的兜底逻辑 / 不节外生枝（例如首版不做推送通知、不做后台保活策略除非测试证明必需）。

## 9. 非目标 / 暂不做（YAGNI）

- 首版不要求 App 在后台长期保活 SSE（仅 foreground 监听即可，除非真机测试证明必须）。
- 首版不实现 agent 端 polling worker 队列的全链路自动化测试（TC7/TC12），除非 Q1 选 B。
- 首版不做公网中继、推送 SDK 或商店发布。

## 10. 已确认问题

- Q1: 手机 App 订阅 server `/events` SSE（方案 A）。
- Q2: iOS 真机验收。
- Q3: 作为 `2026-06-13-mobile-review-companion` VERIFY 续跑，关闭 TC2。

见 `questions.md`。
