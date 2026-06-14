# 记忆日志 · Journal（只增不改）

## 2026-06-13 23:20 · [集成]
- 背景: `/sandtable-mobile-start`
- 内容: mobile sync 已开启；配对码 5686；Server http://192.168.5.198:8765；feature=2026-06-13-mobile-on-demand-sync；已启动 background wait worker 子 agent 监听 outbox。
- 依据/来源: `scripts/sandtable-mobile-start.sh`

- 依据/来源: `scripts/sandtable-mobile-start.sh`

## 2026-06-14 11:20 · [集成]
- 背景: `/sandtable-mobile-start`
- 内容: 配对码 8237；Server http://192.168.5.198:8765；检测到手机已配对、Agent 已同步 VERIFY；inbox wait 子 agent 已启动。
- 依据/来源: `scripts/sandtable-mobile-start.sh`

## 2026-06-14 · [集成]
- 背景: `/sandtable-mobile-start`
- 内容: 配对码 9760；Server http://192.168.5.198:8765；feature=2026-06-13-mobile-on-demand-sync；手机已配对、Agent 已同步 VERIFY；inbox wait 子 agent 已启动。
- 依据/来源: `scripts/sandtable-mobile-start.sh`

## 2026-06-14 · [集成]
- 背景: `/sandtable-mobile-start`
- 内容: 配对码 4126；Server http://192.168.5.198:8765；feature=2026-06-13-mobile-on-demand-sync；手机已配对、Agent 已同步 VERIFY；inbox wait 子 agent 已启动。
- 依据/来源: `scripts/sandtable-mobile-start.sh`

## 2026-06-14 · [集成]
- 背景: `/sandtable-mobile-stop`
- 内容: mobile sync 已停止；runtime server 已关闭；feature=2026-06-13-mobile-on-demand-sync。
- 依据/来源: `scripts/sandtable-mobile-stop.sh`

## 2026-06-14 · [集成]
- 背景: `/sandtable-mobile-start`
- 内容: 配对码 6656；Server http://192.168.5.198:8765；feature=2026-06-13-mobile-on-demand-sync；手机已配对、Agent 已同步 VERIFY；inbox wait 子 agent 已启动。
- 依据/来源: `scripts/sandtable-mobile-start.sh`

## 2026-06-14T07:31:31.161Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 测试一下
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理手机消息「测试一下」
- 内容: 已回复「收到了，手机同步通道正常。」；inbox 6 条消息已 ack；新 wait 子 agent 已启动。
- 依据/来源: `POST /agent/sessions/sess_lOuzQMt00pj8/messages`

## 2026-06-14T07:33:35.184Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 测试一下整个流程
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理手机消息「测试一下整个流程」
- 内容: 已回复全流程测试通过；inbox 已 ack；新 wait 子 agent 已启动。
- 依据/来源: `POST /agent/sessions/sess_lOuzQMt00pj8/messages`

## 2026-06-14T07:34:50.584Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 测试回答问题等流程 确认审核等
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理手机消息「测试回答问题等流程 确认审核等」
- 内容: 已回复问答/确认审核流程说明；inbox 已 ack；新 wait 子 agent 已启动。
- 依据/来源: `POST /agent/sessions/sess_lOuzQMt00pj8/messages`

## 2026-06-14T07:37:14.088Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 生成测试用例吧
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [TESTCASES]
- 背景: 主 agent 处理手机消息「生成测试用例吧」
- 内容: 已生成 `tests.md`（TC1–TC10）；已 push-state；已回复手机；inbox 已 ack。
- 依据/来源: 手机 inbox + `docs/sandtable/features/2026-06-13-mobile-on-demand-sync/tests.md`

## 2026-06-14T07:40:34.233Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: plan 也没生成呢
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [PLAN]
- 背景: 主 agent 处理手机消息「plan 也没生成呢」
- 内容: 已生成 `plan.md`（T1–T5 + VERIFY 清单）；已 push-state；已回复手机；inbox 已 ack。
- 依据/来源: 手机 inbox + `docs/sandtable/features/2026-06-13-mobile-on-demand-sync/plan.md`

## 2026-06-14T07:42:30.588Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 分享当前项目
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [状态]
- 背景: 主 agent 处理手机消息「分享当前项目」
- 内容: 已 push-state；已发送 status 消息（Sandtable 北极星 + 当前 feature VERIFY 概览）；inbox 已 ack。
- 依据/来源: `docs/sandtable/project.md` + `POST /agent/sessions/sess_lOuzQMt00pj8/messages`

## 2026-06-14T07:48:06.678Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 你有结合最新代码去看吗
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [修正]
- 背景: 主 agent 处理手机消息「你有结合最新代码去看吗」
- 内容: 承认 tests/plan 初稿未逐行对照代码；已读 `http.ts`/`pairing.ts`/Flutter pairing API 并修正 plan/tests（/pair/by-code、PIN TTL、steps 字段名等）；已 push-state 并回复手机。
- 依据/来源: `runtime/server/src/http.ts`, `apps/mobile/lib/data/sandtable_api.dart`

## 2026-06-14T07:58:36.871Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 服务器怎么支持的多agent
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理手机消息「服务器怎么支持的多agent」
- 内容: 已基于 sessions.json / AgentIdentity / device-level pairing 回复多 agent 架构说明；inbox 已 ack。
- 依据/来源: `runtime/server/src/sessions.ts`, `docs/mobile-review-companion/protocol.md`

## 2026-06-14T08:01:03.484Z · [问答]
- 背景: 手机 inbox
- 内容: 不同的agent 客户端 用的都是同一份服务器实例吗
- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理上述消息
- 内容: 已确认同一 repo 共享单 runtime 实例（--repo + 8765）；各 agent 注册独立 session；手机一次配对看全部；不同 repo 需另起 server。
- 依据/来源: `runtime/server/src/index.ts`

## 2026-06-14T08:01:03.480Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 不同的agent 客户端 用的都是同一份服务器实例吗
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14T08:03:45.431Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 那手机端可以同时处理多仓库所服务端吗
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理「多仓库服务端并行」
- 内容: 当前 App 仅单 active connection（ConnectionStore）；不可并行多 repo；可断开切换，ServerHistory 记 URL；已回复手机。
- 依据/来源: `apps/mobile/lib/data/connection_store.dart`, `apps/mobile/lib/app.dart`

## 2026-06-14T08:07:42.360Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 当前子agent 轮训原理 耗token吗
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [问答]
- 背景: 主 agent 处理 wait 子 agent 轮询与 token 问题
- 内容: 已说明 bash 5s 轮询 inbox、等待期几乎不耗 token、消息到达后主 agent 才消耗；已回复手机。
- 依据/来源: `scripts/sandtable-mobile-wait.sh`, `commands/sandtable-mobile-wait.md`

## 2026-06-14 · [集成]
- 背景: `/sandtable-mobile-stop`
- 内容: mobile sync 已停止；8765 不可达；feature=2026-06-13-mobile-on-demand-sync。
- 依据/来源: `scripts/sandtable-mobile-stop.sh`（stop 脚本 curl 无超时曾挂起，已强制确认 server 关闭）

## 2026-06-14T09:18:30.292Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 在吗
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14T09:23:36.310Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 怎么没有反应
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14T09:25Z · [手机同步]
- 背景: 执行 /sandtable-mobile-start。最初只跑了脚本(起服务/出码/二维码),漏了规范第 3 步「拉起 inbox 等待子 agent」,导致手机配对后发消息无人处理。
- 修正: 补派单职责 inbox 等待子 agent(scripts/sandtable-mobile-wait.sh),收到手机消息。
- 手机消息: mobile_paired(sess_lOuzQMt00pj8) + 聊天「在吗」「怎么没有反应」。
- 处理: 通过 POST /agent/sessions/<sid>/messages 回复手机;POST /mailbox/inbox/ack 确认 3 条;push-state 同步阶段;重新拉起等待子 agent。
- 教训: slash 命令先读规范再执行,逐步核对(尤其子 agent 派发这类隐性步骤)。
- 来源: main-agent

## 2026-06-14T09:26:45.016Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: app 进入会话 没有自动滚动到底部呀
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14 · [修复]
- 背景: 主 agent 处理会话页未自动滚到底部
- 内容: 修 `session_detail_screen.dart`：conversation loaded 后双帧 jumpTo；已回复手机待 hot restart 验证。
- 依据/来源: `apps/mobile/lib/ui/screens/session_detail_screen.dart`

## 2026-06-14T09:38:23.217Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 手机上回话列表上做一下未读消息吧，明显一些，方便我很快了解
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8
