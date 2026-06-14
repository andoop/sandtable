# 记忆日志 · Journal（只增不改）

## 2026-06-13 20:00 · [决策]
- 背景: `/sandtable-start`，原始需求「测试一下手机上监听」。
- 内容: 新建 feature `2026-06-13-mobile-listening-test`，与 `2026-06-13-mobile-review-companion`（phase=VERIFY）关联但独立成需求目录。
- 依据/来源: 开发者原始需求；`features/2026-06-13-mobile-review-companion/state.md`

## 2026-06-13 20:00 · [决策]
- 背景: RECON · gathering-intel。
- 内容: 已确认事实清单（见下）与未知清单；PRD 草案按「补齐并实现手机端事件监听 + 真机验证」方向撰写，待开发者确认是否偏离其本意。
- 依据/来源: 见 RECON 条目

### RECON · 已确认事实（标来源）

1. **Sandtable 运行时文档根**在 `sandtable/docs/sandtable/`，全局 `project.md` / `constraints.md` 已存在。来源: `sandtable/docs/sandtable/project.md`, `constraints.md`
2. **Mobile Review Companion 已集成** server runtime + Flutter App，当前 feature 处于 VERIFY。来源: `features/2026-06-13-mobile-review-companion/state.md:3-33`
3. **Server 已暴露 SSE 事件流** `GET /events`，content-type 为 `text/event-stream`，订阅 `RuntimeEvents.onMessage` 并推送 mailbox 消息。来源: `runtime/server/src/http.ts:39-49`, `runtime/server/src/events.ts:17-19`
4. **Flutter App 当前无事件监听**：`SandtableApi` 仅有文档读取、确认/回答提交、stop；`FeatureScreen` 为静态列表，无 SSE/WebSocket/轮询刷新。来源: `apps/mobile/lib/api.dart:1-62`, `apps/mobile/lib/screens/feature_screen.dart:22-95`
5. **plan 曾规划** `web_socket_channel` 与手机端实时更新（TC2：「手机端在不重启 App 的情况下看到 phase 更新」），但实际 `pubspec.yaml` 未引入该依赖，实现也未落地。来源: `features/2026-06-13-mobile-review-companion/plan.md:736`, `features/2026-06-13-mobile-review-companion/tests.md:17-27`, `apps/mobile/pubspec.yaml:30-38`
6. **iOS 已配置本地网络权限文案**（配对与 debug 工具），用户近期在编辑 iOS 工程文件。来源: `apps/mobile/ios/Runner/Info.plist:7-12`, 用户打开文件 `AppDelegate.swift`
7. **全局 lessons** 提醒多 locale 资产须对照 INSTALL.md；本需求暂不涉及。来源: `docs/sandtable/lessons.md:5-9`

### RECON · 未知 / 待澄清

1. 「监听」指 **手机 App 订阅 server 事件流**，还是 **agent 端 mailbox 轮询子 agent**，还是 **真机 E2E 手工验收**？
2. 目标平台：仅 iOS 真机、Android 真机，还是模拟器也可？
3. 若 App 尚未实现 SSE 客户端，本需求是否包含 **补齐实现**，还是只做 **已有能力的手工测试**？
4. 与 `2026-06-13-mobile-review-companion` VERIFY 的关系：作为其 VERIFY 子项关闭 TC2，还是独立 follow-up feature？

## 2026-06-13 20:05 · [问答]
- 背景: PRD 确认 · AskQuestion。
- 内容: 开发者确认 Q1=A（App 订阅 SSE `/events`）；Q2=iOS 真机；Q3=companion VERIFY 续跑并关闭 TC2。
- 依据/来源: 开发者 AskQuestion 答复；已写回 `prd.md`、`questions.md`

## 2026-06-13 23:05 · [集成]
- 背景: `/sandtable-autopilot` 完整实现手机 SSE 监听。
- 内容: 新增 `sse_parser.dart`、`runtime_event.dart`、`state_summary.dart`、`event_listener.dart`；更新 `feature_screen.dart`；server 增加 `sync/phase`、`sync/document`；`scripts/mobile-listening-e2e.sh`；iOS `NSAllowsLocalNetworking`；server 12/12 + flutter 6/6 单测通过。
- 依据/来源: `apps/mobile/lib/*`, `runtime/server/src/http.ts`
