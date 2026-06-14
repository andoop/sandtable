---
description: 启动 inbox 等待子 agent（单职责：等到一条手机消息即交给主 agent 并退出）
---

**子 agent 只做一件事**：轮询 inbox，有新消息就交给主 agent，然后退出。

执行：
1. 读 `docs/sandtable/features/*/state.md` 或 mobile-sync session 确定 **feature id**（用户可指定）。
2. 用 Task 启动 **background 子 agent**，prompt **仅**包含：
   - 运行 `scripts/sandtable-mobile-wait.sh <feature-id>`（每 5s 查 inbox，**禁止**查 status/health/outbox）
   - 脚本 stdout 出现 JSON 后，**原样**把 `messages` 交给主 agent，然后子 agent **结束**
   - **禁止**读 journal、改 PRD、检查 server 状态、循环重启
3. 主 agent 处理完消息后：
   - `curl -X POST http://127.0.0.1:8765/mailbox/inbox/ack -H 'content-type: application/json' -d '{"ids":["<message-id>"]}'`
   - 再执行 `/sandtable-mobile-wait` 拉起下一个等待子 agent

不要询问是否继续。
