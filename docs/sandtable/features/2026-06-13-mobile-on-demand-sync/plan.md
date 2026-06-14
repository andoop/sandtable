# 按需 Mobile 同步 改动计划

**目标:** 开发者按需开启/关闭手机同步，4 位 PIN 配对，inbox 唤醒主 agent，电脑 Sandtable 流程不变。

**架构:** runtime server 提供 `mobile-sync/*` 与 `mailbox/inbox` API；shell 脚本 + slash 命令封装 start/stop/status/wait；Flutter App PIN 配对 UI；主 agent 通过 Task 子 agent 轮询 inbox，处理消息后 ack 并重启 wait。

**对应 PRD:** `prd.md`  
**预演要求:** mental×3 / redteam×3 / impl×2 已完成（见 `state.md`）

---

## 文件地图

- 创建 `runtime/server/src/mobile-sync.ts` — 4 位 PIN session 读写
- 修改 `runtime/server/src/http.ts` — `/mobile-sync/start|stop|status|push-state`、`/mailbox/inbox`、`/agent/sessions/:id/messages`
- 创建 `scripts/sandtable-mobile-start.sh` — 启动 server、POST start、输出配对码
- 创建 `scripts/sandtable-mobile-stop.sh` — stop API + kill server
- 创建 `scripts/sandtable-mobile-status.sh` — 三步进度查询
- 创建 `scripts/sandtable-mobile-wait.sh` — inbox 轮询（5s），有消息即退出
- 创建 `commands/sandtable-mobile-{start,stop,status,wait}.md` — slash 命令说明
- 修改 `apps/mobile/lib/ui/screens/pairing_screen.dart` — Server URL + 4 位码或 QR 扫描
- 修改 `apps/mobile/lib/data/sandtable_api.dart` — `pairByCode()` → `POST /pair/by-code`
- 修改 `apps/mobile/lib/app.dart` — 配对后进入跨 session 列表（device-level token）
- 测试 `runtime/server/test/http.test.ts`、`conversation.test.ts` — API 与对话持久化

---

### 任务 T1: 4 位 PIN 配对与 mobile-sync API

**文件:**
- 创建: `runtime/server/src/mobile-sync.ts`
- 修改: `runtime/server/src/http.ts`（`/mobile-sync/start`, `/mobile-sync/pair`, `/mobile-sync/status`）

- [x] 步骤1: `POST /mobile-sync/start` 生成 4 位 code + token + session 文件（PIN TTL 10 分钟）
- [x] 步骤2: 手机 `POST /pair/by-code` 校验 code，设 `paired: true`，token 写入 `devices` 持久化
- [x] 步骤3: `GET /mobile-sync/status` 返回 `steps.server` / `phonePaired` / `agentSynced`
- [x] 验证: **TC1, TC2** — start 输出码；配对后 status paired

### 任务 T2: slash 命令与 start/stop/status/wait 脚本

**文件:**
- 创建: `scripts/sandtable-mobile-{start,stop,status,wait}.sh`
- 创建: `commands/sandtable-mobile-{start,stop,status,wait}.md`

- [x] 步骤1: start 脚本检测 repo 根、拉起 server、POST start、轮询配对（90s）
- [x] 步骤2: stop 脚本 POST stop + kill PID
- [x] 步骤3: wait 脚本仅轮询 `GET /mailbox/inbox?feature=…`，禁止查 status
- [x] 验证: **TC3, TC4, TC8, TC9, TC10**

### 任务 T3: Flutter PIN 配对 UI

**文件:**
- 修改: `apps/mobile/lib/ui/screens/pairing_screen.dart`
- 修改: `apps/mobile/lib/data/sandtable_api.dart`

- [x] 步骤1: 配对页输入 Server URL + 4 位码
- [x] 步骤2: 连接成功后进入 session 列表 / 详情
- [x] 验证: **TC2** — iOS 真机已验证

### 任务 T4: 手机消息 inbox + worker 轮询

**文件:**
- 修改: `runtime/server/src/http.ts`（`/sessions/:id/messages`, `/mailbox/inbox`, `/mailbox/inbox/ack`）
- 修改: `commands/sandtable-mobile-start.md`（主 agent ack + 重启 wait 流程）

- [x] 步骤1: 手机 chat/answer/confirmation → enqueueInbox + appendMobileJournal
- [x] 步骤2: 主 agent Task 子 agent 跑 wait.sh → 处理 → POST ack → 重启 wait
- [x] 步骤3: 主 agent `POST /agent/sessions/:id/messages` 回复手机
- [x] 验证: **TC5** — chat 全流程已验证；**TC6** 待 answer/confirmation 补测

### 任务 T5: phase 推送与单测

**文件:**
- 修改: `runtime/server/src/http.ts`（`POST /mobile-sync/push-state`）
- 测试: `runtime/server/test/http.test.ts`, `conversation.test.ts`

- [x] 步骤1: push-state 读 `state.md` phase 推送到 session
- [x] 步骤2: 单测覆盖 session/messages/conversation
- [ ] 验证: **TC7** — 手机 phase 卡片更新待真机确认

---

## VERIFY 清单

| TC | 状态 | 验证方式 |
|----|------|----------|
| TC1–TC5, TC8–TC10 | 已验证 | 本次手机联调 + 脚本 |
| TC6 | 待验证 | 手机提交 answer/confirmation |
| TC7 | 待验证 | push-state 后观察 App phase 卡片 |
