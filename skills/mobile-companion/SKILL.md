---
name: mobile-companion
description: Use when the developer enables Sandtable mobile review / 手机同步 / mobile sync / 配对码 / pairing, or runs any /sandtable-mobile-* action (start/status/stop/wait), or asks to review PRD/tests/plan/state on the phone. Defines the on-demand mobile sync loop, the single-job inbox waiter, and worker discipline.
---

# Mobile Review Companion · 手机审阅同步

**开始时声明：** "我在用 mobile-companion 管理 Sandtable 手机同步。"

把当前 feature 的阶段、文档、待确认事项同步到手机，并接收手机端的聊天/确认/回答。**可选能力**：未显式启用时，不启动 server、不写 mailbox、不改变默认 Sandtable 流程。

> 触发方式：Cursor/Claude/Kiro 用 `/sandtable-mobile-*` 命令；Codex 用 `$mobile-companion`。两者执行同一套流程。

## 何时启用

- 开发者运行 `/sandtable-mobile-start`（或要求"开手机同步/配对手机/在手机上看进度"）。
- 已有 `.sandtable-runtime/session/mobile-sync.json` 且 `active=true`。

依赖：需要仓库内 `runtime/server/` 就位并已 `npm --prefix runtime/server install`（见 `docs/mobile-review-companion/runtime.md`）。

## 四个动作

| 动作 | 命令 | 脚本 | 作用 |
|------|------|------|------|
| 开启 | `/sandtable-mobile-start` | `scripts/sandtable-mobile-start.sh [feature]` | 起 daemon server、出 4 位配对码 + Server URL + 二维码，并拉起 inbox 等待子 agent |
| 查状态 | `/sandtable-mobile-status` | `scripts/sandtable-mobile-status.sh` | 报告 server 是否运行、feature、配对码、paired、expiresAt |
| 停止 | `/sandtable-mobile-stop` | `scripts/sandtable-mobile-stop.sh` | 关 server、停同步；手机将显示 Disconnected |
| 等消息 | `/sandtable-mobile-wait` | `scripts/sandtable-mobile-wait.sh <feature>` | 单职责子 agent：轮询 inbox，收到一条即交主 agent 并退出 |

## On-demand sync 主循环

1. **开启**：运行 `scripts/sandtable-mobile-start.sh [feature-id]`，醒目输出配对码、Server URL、三步进度。电脑无需额外"连接"，手机输 URL + 4 位码（或扫码）即可。
2. **拉起等待子 agent**：执行 `/sandtable-mobile-wait`——子 agent **只**运行 `scripts/sandtable-mobile-wait.sh <feature>`（每 5s 查 inbox），收到一条消息原样交主 agent 后**立即退出**；**禁止**子 agent 查 status/health、读 journal、改文档。
3. **处理手机消息**：主 agent 处理完后：
   - `curl -X POST http://127.0.0.1:8765/mailbox/inbox/ack -H 'content-type: application/json' -d '{"ids":["<message-id>"]}'`
   - 再执行 `/sandtable-mobile-wait` 拉起下一个等待子 agent。
4. **回话 / 推状态**：给手机回话 `POST /agent/sessions/<sid>/messages`（kind: chat/answer/confirmation）；更新 Sandtable 文档后若 sync active：`curl -X POST http://127.0.0.1:8765/mobile-sync/push-state`。
5. **落盘**：在 feature `journal.md` 追加同步/处理记录。

## 长驻 worker 纪律

- 阶段动作结束前，主 agent 必须刷新 `.sandtable-runtime/session/continuation.json`，并把等待信箱职责交给一个或一组低成本/免费 waiting workers。
- waiting workers 只能等待、去重、续租、通知、接力或停止；除非被明确分配，不得改 PRD/tests/plan 或替主 agent 做产品裁决。
- 只有电脑端 stop、stop mailbox event 或开发者明确停止请求，才可把 continuation 标记为 stopped。

## 通道选择

- 支持 MCP 时，优先用 Sandtable MCP handler 同步 phase、文档摘要、待确认与阻塞状态。
- 不支持 MCP 时，按 `docs/mobile-review-companion/protocol.md` 读写 `.sandtable-runtime/mailbox/`。

## Red Flags

| 念头 | 现实 |
|------|------|
| "起了 server 就算开好了" | 还要拉起 inbox 等待子 agent，否则手机消息无人处理。 |
| "等待子 agent 顺便查下状态/读 journal" | 不行。等待子 agent 单职责：只轮询 inbox、交付、退出。 |
| "处理完消息不用 ack" | 必须 ack，否则同一条消息会被反复取出。 |
| "改完文档不用推状态" | sync active 时要 push-state，手机才会更新。 |
| "项目没装 runtime 也能跑" | 需要仓库内 runtime/server + npm 依赖；缺则先按 runtime.md 装。 |

完整协议见 `docs/mobile-review-companion/protocol.md`，启动与真机验证见 `runtime.md` / `verification.md`。
