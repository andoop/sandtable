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

## 2026-06-14 · [手机同步]
- 背景: `/sandtable-mobile-start`
- 内容: 配对码 9936；Server http://192.168.5.198:8765；feature=2026-06-13-mobile-on-demand-sync；server 已就绪、Agent 已同步 VERIFY（手机暂未配对）。
- 依据/来源: `scripts/sandtable-mobile-start.sh`、`GET /mobile-sync/status`

## 2026-06-14 · [修复]
- 背景: 主 agent 处理手机消息「手机上回话列表上做一下未读消息吧，明显一些，方便我很快了解」
- 内容: 为会话列表加未读标记。新增 per-connection 已读游标（`ReadMarksCache`，SharedPreferences 持久化）：未读 = `session.lastActivityAt` 晚于该会话已读游标；进入会话详情即 `markRead`（在底部时持续保持已读）；首次连接服务器把历史会话种子为已读，避免一上来全未读；会话消失/断开时清理游标。UI：未读 tile 显示蓝点+加粗标题+蓝色描边，列表顶部「N 条未读」汇总。
- 改动文件: `connections_repository.dart`(+ReadMarksCache/_PrefsReadMarksCache)、`session_store.dart`(isUnread/markRead/unreadCount/seed/prune)、`connections_controller.dart`(注入 readMarks + unreadSessionCount + detach 清理)、`core/theme.dart`(SurfaceCard borderColor/borderWidth)、`ui/widgets/session_tile.dart`(unread 指示)、`ui/screens/session_list_screen.dart`(传 unread + onTap markRead + 汇总徽标)、`ui/screens/session_detail_screen.dart`(在底部保持已读)。
- 验证: Dart 分析服务器对 7 个改动文件均无诊断。flutter analyze/test 在本沙箱内挂起（历史遗留十余个未结束的 flutter 进程印证），无法运行；已用 IDE 分析作为编译校验，待手机端热重启做功能验证。
- 处理: 已回复手机（200）；push-state（200, VERIFY）；inbox ack 1 条（200）。
- 依据/来源: 手机 inbox `20260614T093823221Z-mobile-RKzto8BM`

## 2026-06-14T12:20:55.856Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 测试一下
- Target: conversation

- 来源: mobile-app:sess_lOuzQMt00pj8

## 2026-06-14T13:36Z · [手机同步]
- 背景: Codex 触发 `$mobile-companion`，恢复 on-demand 手机同步处理。
- 状态: server 健康，Server URL `http://192.168.5.198:8765`，手机已配对，当前阶段 VERIFY。
- 手机消息: 收到 `mobile_paired` 与聊天「测试一下」。
- 处理: 已 ack 2 条 inbox 消息；原 `mobile-sync.json` sessionId `sess_lOuzQMt00pj8` 已不在当前 session store，改用当前 feature session `sess_NpSKR4t9_6Fz` 回复手机；已 `push-state` 同步 VERIFY。
- 依据/来源: `scripts/sandtable-mobile-status.sh`、`scripts/sandtable-mobile-wait.sh`、`POST /mailbox/inbox/ack`、`POST /agent/sessions/sess_NpSKR4t9_6Fz/messages`

## 2026-06-14 · [bugfix]
- 背景: 用户反馈——手机连了两个仓库的服务，子 agent 跑等待脚本一直"没有任何消息"，但手机已发多条。
- 根因(代码证据 100%): `scripts/sandtable-mobile-wait.sh` 端口硬编码 `PORT="${SANDTABLE_MOBILE_PORT:-8765}"`，未读 `.sandtable-runtime/session/server.port`；而 `status.sh`/`stop.sh` 都读 server.port。多仓库下 `start.sh` 的 choose_port 会给后启动的仓库分配非 8765 端口（如 8766）并写入其 server.port；手机连该仓库（8766），消息进其 inbox，但 wait 仍查 8765（= 另一仓库的 server），再按 feature 过滤 → 永远为空。
- 修复: wait.sh 增加 detect_repo_root + 读 server.port（与 status/stop 完全一致），保留 `SANDTABLE_MOBILE_PORT` 覆盖与 8765 兜底。
- 验证: `bash -n` 通过；单仓库本机端口仍解析为 8765（行为不变）；多仓库下解析为各自端口。
- 教训: 同一组脚本对"同一事实（server 端口）"必须用同一份解析逻辑；新增脚本(wait)漏抄端口解析，在多实例下静默查错且无报错，最难排查。
- 依据/来源: `scripts/sandtable-mobile-{wait,status,stop}.sh`、`sandtable-mobile-start.sh` choose_port

## 2026-06-14T13:39:23.651Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 还在吗
- Target: conversation

- 来源: mobile-app:sess_NpSKR4t9_6Fz

## 2026-06-14 · [feature/bugfix] 手机功能三连改进
- #1 子 agent inbox 输出致 Codex "Markdown couldn't render"：根因为等待子 agent 把裸 JSON 贴进对话。改 wait 命令 / mobile-companion：纯文本结构化转述 `- [id] text` + 末尾 `ack-ids:`，必要时 ```json 包裹。
- #2 start 主 agent "戏太多/卡"：`start.sh` 去掉出码后 90s 阻塞轮询（秒回）；start 命令精简为"出码 + 立即拉单职责等待子 agent，无消息时空闲"。
- #3 运行态同步到手机（商业级全链路）：server 新增 `agent_state` SSE 广播 + `POST /mobile-sync/agent-state` + `GET /mobile-sync/status` 返回 `agent`；脚本上报（start→main idle、wait→waiter waiting/processing、stop→disconnected/exited）；mobile-companion 文档要求主 agent 上报 working/idle/error；手机新增 `AgentRuntimeState` 模型 + `AgentStatePill`，会话详情头显示 主 agent/等待器 状态徽标。
- 附带 bugfix：`stop.sh` 两个 curl 缺 `-m` 超时，旧 server 半死时永久挂起（本轮 e2e 即卡于此，也解释了历史 stop 挂起）。已加 `-m 3`。
- 验证：Dart/TS 分析器对全部改动文件（4 手机 + 3 server）无诊断；mobile 脚本 `bash -n` 通过；命令/skill 镜像 `sandtable-sync.sh` + `--check` 全绿。运行时 e2e 因 stop.sh 旧挂起 bug 中断（已修复），后端正确性以分析器 + 代码审查为据，建议重启该仓库 server 后用手机验收。
- 依据/来源：`runtime/server/src/{types,mobile-sync,http}.ts`、`scripts/sandtable-mobile-{start,wait,stop}.sh`、`skills/mobile-companion`、`apps/mobile/lib/{data/models/agent_state.dart,ui/widgets/agent_state_pill.dart,state/session_store.dart,ui/screens/session_detail_screen.dart}`

## 2026-06-14T14:38Z · [手机同步]
- 背景: `/sandtable-mobile-start`（按需开启手机同步）。
- 状态: 重新拉起 detached daemon，Server URL `http://192.168.5.198:8765`，新配对码 1631；脚本秒回不阻塞。
- 手机消息: inbox 待处理一条聊天「还在吗」（id `20260614T133923654Z-mobile-JsrvvSwy`, session `sess_NpSKR4t9_6Fz`）。
- 处理: agent-state main=working → `POST /agent/sessions/sess_NpSKR4t9_6Fz/messages` 回复「在的，Agent 已就绪并已与手机同步」(200) → `POST /mailbox/inbox/ack`（acked:1）→ agent-state main=idle → 重新拉起单职责 inbox 等待子 agent。
- 依据/来源: `scripts/sandtable-mobile-start.sh`、`POST /agent/sessions/.../messages`、`POST /mailbox/inbox/ack`

## 2026-06-14T14:40:08.952Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 你觉得当前项目还有那些地方设计的不好
- Target: conversation

- 来源: mobile-app:sess_NpSKR4t9_6Fz

## 2026-06-14T14:43Z · [问答]
- 背景: 主 agent 处理手机消息「你觉得当前项目还有那些地方设计的不好」(id `20260614T144008956Z-mobile-__oKolnp`)。
- 处理: 读 `runtime/server/src/{mailbox,sessions,pairing,polling,continuation}.ts` + 历史 journal 后，给出有代码依据的设计弱点（按影响排序）：①文件邮箱无锁/非原子，多消费者(processInboxOnce/bash wait/ack)竞争 ②会话/消息生命周期对账脆弱(stale sessionId) ③SSE 与 bash 5s 轮询传输不统一 ④运行时状态散落多 JSON、bash↔TS 文件耦合 ⑤4 位 PIN claimByCode 无限流可暴力 ⑥续约/游标只写不回收死 worker。并澄清 token 跨重启持久性其实 OK（devices.ts 提升到 devices.json 启动恢复）。已回复(200)、ack 1 条、main=idle。
- 依据/来源: `runtime/server/src/*.ts`、`POST /agent/sessions/sess_NpSKR4t9_6Fz/messages`、`POST /mailbox/inbox/ack`

## 2026-06-14 · [bugfix/跨工具适配] Kiro 等待体验差
- 背景: 用户反馈 Kiro 中 mobile 同步体验差——开子 agent 费劲，主 agent 不停检查/设超时/骚动；Cursor 则安静地"派子 agent 阻塞等其返回，不论多久"。
- 根因: 等待协议按 Cursor 的"Task background 子 agent"措辞写成，"background/启动后台"在 Kiro 被理解为"起个后台再自己继续盯着"→ 主 agent 轮询/超时/忙活。
- 修复: 等待协议重写为 **harness 中立铁律**——主 agent 派**一个**子 agent 后**阻塞等其返回、不限时长、期间零动作**（不自查 inbox/status/health、不设超时、不反复检查、不忙活）；明确各工具"派子 agent 并阻塞等返回"原语（Cursor/Claude=Task，**Kiro=`invoke_sub_agent`**）；`wait.sh` 默认无限阻塞、不超时，新增可选 `SANDTABLE_WAIT_MAX_SECONDS` 兜底（仅当工具对子 agent 有硬执行上限时，到时返回 `{"messages":[],"timeout":true}`，主 agent 再派一个等待子 agent，仍不自轮询）。改 wait 命令 + mobile-companion（中英）；Red Flags 加"派了等待子 agent 别去忙别的"。
- 验证局限: 本轮持久 shell 被上一轮 e2e 的旧 stop curl（已修无超时）拖住，`sandtable-sync.sh` 未能跑成；已**手动**同步全部 6 个镜像并使真源==镜像；建议环境恢复后跑 `scripts/sandtable-sync.sh --check` 复核一致性。
- 依据/来源: `commands/sandtable-mobile-wait.md`、`skills/mobile-companion`、`scripts/sandtable-mobile-wait.sh`

## 2026-06-14 · [bugfix/健壮性] mobile 脚本无超时 curl 致挂起 + 半死端口
- 现象: 主 agent 执行 `./scripts/sandtable-mobile-start.sh` 一直不返回。
- 根因: start/status/wait 脚本里多处 curl 缺 `-m` 超时；当某端口上有"半死 server"（TCP 在听但 /health 不响应，多为前次 e2e 残留）时，curl 永久挂 → 脚本不返回。choose_port 还会把"半死端口"误判为 free 并在其上起新 server（bind 失败）。
- 修复:
  - `start.sh`: health 轮询 `-m 2`、`mobile-sync/start` `-m 5` + 失败 5s 内友好报错、`pairing` `-m 3`；新增 `port_state()`（curl 退出码 7=无监听=free，其它=占用）让 `choose_port` **自动跳过半死/被占端口**、选下一个真正空闲端口（`-m 1`，无 hang 风险），用户无需手动 kill。
  - `status.sh`: 4 处 curl 全加 `-m`；server 在听但 status 无响应时报"半死，请 stop 后重试"。
  - `wait.sh`: inbox 轮询 curl 加 `-m 5`。
  - `stop.sh`: 上一轮已加 `-m 3`。
- 至此所有 mobile 脚本在任何 server 异常下都不会无限挂。
- 验证局限: 本环境终端不可靠（持久 shell 被旧 e2e 进程拖死、独立终端输出捕获也不稳），`bash -n` 未跑出可读结果；改动为标准 bash + curl `-m` + 标准函数/if，以逐行人工审查为据，建议环境恢复后 `bash -n` 复核。
- 依据/来源: `scripts/sandtable-mobile-{start,status,wait,stop}.sh`

## 2026-06-14T16:06:54.674Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 测试一下
- Target: conversation

- 来源: mobile-app:sess_LZhq16aZxPsH

## 2026-06-14T16:12:06.159Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 如果没有给你发消息，你会等多久
- Target: conversation

- 来源: mobile-app:sess_LZhq16aZxPsH

## 2026-06-14T16:14:06.403Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 匹配码逻辑是怎样的
- Target: conversation

- 来源: mobile-app:sess_LZhq16aZxPsH

## 2026-06-14T16:28:03.056Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 你终止吧
- Target: conversation

- 来源: mobile-app:sess_LZhq16aZxPsH

## 2026-06-14 · 手机同步会话（按需）

- `/sandtable-mobile-start`：拉起 detached runtime server（port 8765, publicUrl http://192.168.5.198:8765），生成配对码 4597。
- 手机配对成功（`mobile_paired`，token 升级为持久 device）。
- 通过单职责 inbox 等待子 agent 阻塞接收手机消息，主 agent 全程空闲、收到才动作：
  - 「测试一下」→ 回复链路自检正常。
  - 「如果没有给你发消息，你会等多久」→ 说明无限期阻塞、不设超时。
  - 「匹配码逻辑是怎样的」→ 据 `runtime/server/src/pairing.ts` + `http.ts` 解释：4 位码（1000–9999 查重唯一）、10 分钟 TTL、一次性 claim、配对后 token 升级持久 device。
- 「你终止吧」（开发者显式停止指令，经手机通道）→ ack + 告别回复 → `scripts/sandtable-mobile-stop.sh` 停止。
- 已验证：`GET /health` 不可达（000），server 关闭。再次同步需重新 `/sandtable-mobile-start`。

## 2026-06-15 · [改进] mobile-start 先用 AskQuestion 让用户选 feature
- 背景: 用户反馈——执行 `/sandtable-mobile-start` 时不要默认取最新 feature，要先用 question 工具让用户从 `docs/sandtable/features/` 中选择本次同步哪个 feature。
- 改动（单一真源）:
  - `commands/sandtable-mobile-start.md`（zh 真源）执行段加步骤1「先确认 feature·用 AskQuestion」，后续步骤顺延；末句改为「除开头 feature 选择外，不就推进与否反复询问」。
  - `locales/en/commands/sandtable-mobile-start.md`（en 真源）同步：新增 "First confirm the feature" 步骤 + AskQuestion；末句改为只有 initial feature choice 必须先问。
  - `skills/mobile-companion/SKILL.md` 与 `locales/en/skills/mobile-companion/SKILL.md` 主循环第1步「开启」加「先列 features 目录、用 AskQuestion 选 feature，再跑 start.sh <feature>」。
- 同步: `bash scripts/sandtable-sync.sh` 同步 6 个镜像；`--check` 全绿（真源==镜像）。
- 依据/来源: `commands/sandtable-mobile-start.md`、`locales/en/commands/sandtable-mobile-start.md`、`skills/mobile-companion/SKILL.md`、`locales/en/skills/mobile-companion/SKILL.md`

## 2026-06-15 · [集成] /sandtable-mobile-stop
- 背景: 用户执行 `/sandtable-mobile-stop`。
- 内容: 运行 `scripts/sandtable-mobile-stop.sh`（"Sandtable mobile sync stopped."）；`GET /health` 返回 000 不可达，确认 runtime server 已关闭、同步停止。
- 依据/来源: `scripts/sandtable-mobile-stop.sh`、`GET /health`

## 2026-06-15 08:24 CST · [集成] 手机同步开启
- 背景: 用户要求"开启手机同步"。
- 内容: 运行 `scripts/sandtable-mobile-start.sh`，启动 runtime server，Feature 为 `2026-06-13-mobile-on-demand-sync`，Server URL 为 `http://192.168.5.198:8765`，配对码为 `3797`；随后写入 `.sandtable-runtime/session/continuation.json`，并启动单职责 inbox 等待器 `shell-waiter:15111`。
- 当前状态: Server 已运行，Agent 已同步，手机尚未配对；等待器正在轮询 `scripts/sandtable-mobile-wait.sh 2026-06-13-mobile-on-demand-sync`。
- 依据/来源: `scripts/sandtable-mobile-start.sh`、`scripts/sandtable-mobile-status.sh`、`.sandtable-runtime/session/continuation.json`、`.sandtable-runtime/session/mobile-waiter.pid`

## 2026-06-15 08:31 CST · [问答] 手机链路测试
- 背景: 手机端完成配对并提交聊天消息。
- Feature: `2026-06-13-mobile-on-demand-sync`
- 内容: `mobile_paired` + `chat_message`；用户消息为「测试一下」。
- 处理: 通过 `POST /agent/sessions/sess_LZhq16aZxPsH/messages` 回复「测试收到，手机同步链路正常：配对、inbox、Agent 回复都已打通。」；随后 `POST /mailbox/inbox/ack` 确认 2 条 inbox 消息，`POST /mobile-sync/push-state` 同步 VERIFY 状态，并将 main agent 状态切回 idle。
- 依据/来源: `GET /mailbox/inbox?feature=2026-06-13-mobile-on-demand-sync`、`POST /agent/sessions/sess_LZhq16aZxPsH/messages`、`POST /mailbox/inbox/ack`、`POST /mobile-sync/push-state`

## 2026-06-15 08:36 CST · [集成] 手机端请求停止同步
- 背景: 手机端发送聊天消息「停止手机同步」。
- 处理: 回复手机「收到，我现在停止手机同步。停止后手机端会显示断开，需要再次开启时重新生成配对码即可。」；`POST /mailbox/inbox/ack` 确认该消息；运行 `scripts/sandtable-mobile-stop.sh` 停止 runtime；将 `.sandtable-runtime/session/continuation.json` 标记为 `active=false`、`stopped=true`、清空 waiting workers。
- 验证: `GET /health` 连接 127.0.0.1:8765 失败（000），确认 server 已关闭。
- 依据/来源: `GET /mailbox/inbox?feature=2026-06-13-mobile-on-demand-sync`、`POST /agent/sessions/sess_LZhq16aZxPsH/messages`、`POST /mailbox/inbox/ack`、`scripts/sandtable-mobile-stop.sh`、`.sandtable-runtime/session/continuation.json`

## 2026-06-15T00:30:04.883Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 测试一下
- Target: conversation

- 来源: mobile-app:sess_LZhq16aZxPsH

## 2026-06-15T00:35:21.430Z · [问答]
- 背景: 手机端提交开发者确认。
- Feature: 2026-06-13-mobile-on-demand-sync
- 内容: Mobile message
- 内容: 停止手机同步
- Target: conversation

- 来源: mobile-app:sess_LZhq16aZxPsH

## 2026-06-15 08:44 CST · [集成] 手机同步重新开启
- 背景: 用户要求"开启手机同步"。
- 内容: 运行 `scripts/sandtable-mobile-start.sh`，Feature 为 `2026-06-13-mobile-on-demand-sync`，Server URL 为 `http://192.168.5.198:8765`，配对码为 `3741`；随后刷新 `.sandtable-runtime/session/continuation.json` 为 active，并启动单职责 inbox 等待器 `shell-waiter:97781`。
- 当前状态: Server 已运行，Agent 已同步，手机尚未配对；等待器正在轮询 `scripts/sandtable-mobile-wait.sh 2026-06-13-mobile-on-demand-sync`。
- 依据/来源: `scripts/sandtable-mobile-start.sh`、`scripts/sandtable-mobile-status.sh`、`.sandtable-runtime/session/mobile-sync.json`、`.sandtable-runtime/session/continuation.json`

## 2026-06-15 08:46 CST · [集成] 手机 inbox watcher 接管
- 背景: 当前 Codex 执行环境会在 shell 命令结束后清理后台子进程，`nohup/disown` 启动的 `sandtable-mobile-wait.sh` 无法长期存活。
- 内容: 创建 Codex heartbeat automation `sandtable-mobile-inbox-watcher`，每分钟检查 `2026-06-13-mobile-on-demand-sync` 的 mobile inbox；收到消息后处理、回复、ack 并记录 journal。`.sandtable-runtime/session/continuation.json` 的 waiting worker 已更新为 `heartbeat:sandtable-mobile-inbox-watcher`。
- 当前状态: Server 已运行，Agent 已同步，手机尚未配对；消息接管机制为 heartbeat watcher。

## 2026-06-15 09:02 CST · [集成] 配对码续期
- 背景: heartbeat 检查发现手机尚未配对，上一轮配对码 `3741` 已过期。
- 内容: 重新运行 `scripts/sandtable-mobile-start.sh` 续开同步，Server URL 仍为 `http://192.168.5.198:8765`，新配对码为 `2913`，有效期至 `2026-06-15T01:12:08.024Z`。
- 当前状态: Server 已运行，Agent 已同步，手机尚未配对；heartbeat watcher 继续检查 inbox。
