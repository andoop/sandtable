---
description: 按需开启手机同步：启动 runtime、生成 4 位配对码、拉起监听子 agent
---

按需开启 Sandtable 手机同步；读取 `docs/mobile-review-companion/runtime.md` § On-demand sync。

**用户体验要点（必须向用户说明）：**
- **电脑**：只需本命令 + 照常 Sandtable；Agent **不需要**再单独「连接」什么。
- **手机**：只需 Server URL + 4 位码；连上后**等待 Agent 自动同步**即可。
- **成功标志**：手机 App 显示「已就绪 / Agent 已同步」；电脑 `/sandtable-mobile-status` 三步均为 ✓。

执行：
1. 确定 repo 根与 feature；运行 `scripts/sandtable-mobile-start.sh [feature-id]`。
2. 醒目输出 **配对码**、**Server URL**、三步进度说明。
3. 执行 `/sandtable-mobile-wait`（或同等步骤）拉起 **inbox 等待子 agent**：
   - 子 agent **只**运行 `scripts/sandtable-mobile-wait.sh <feature>`，每 5s 查 inbox
   - 收到一条消息后原样交给主 agent，子 agent **立即退出**
   - **禁止**子 agent 查 status/health、读 journal、改文档
4. 主 agent 处理完手机消息后：`POST /mailbox/inbox/ack`，再 `/sandtable-mobile-wait` 开启下一个等待子 agent。
5. 主 agent 更新 Sandtable 文档后，若 sync active：`curl -X POST http://127.0.0.1:8765/mobile-sync/push-state`。
6. 更新 feature `journal.md`。

不要询问是否继续。
