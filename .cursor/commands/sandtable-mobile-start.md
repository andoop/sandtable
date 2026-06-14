---
description: 按需开启手机同步：启动 runtime、生成 4 位配对码、拉起监听子 agent
---

按需开启 Sandtable 手机同步；读取 `docs/mobile-review-companion/runtime.md` § On-demand sync。

**用户体验要点（必须向用户说明）：**
- **电脑**：只需本命令 + 照常 Sandtable；Agent **不需要**再单独「连接」什么。
- **手机**：只需 Server URL + 4 位码；连上后**等待 Agent 自动同步**即可。
- **成功标志**：手机 App 显示「已就绪 / Agent 已同步」；电脑 `/sandtable-mobile-status` 三步均为 ✓。

执行（主 agent 尽量轻；等待与重活交子 agent / 脚本，主 agent 无消息时保持空闲）：
1. 运行 `scripts/sandtable-mobile-start.sh [feature-id]`（脚本秒回、不阻塞），把输出的**配对码 + Server URL** 原样展示给我。
2. **立即**执行 `/sandtable-mobile-wait` 拉起**单职责** inbox 等待子 agent；主 agent 自己不轮询、不反复查 status/health。
3. 仅当等待子 agent 交回手机消息时，主 agent 才动作（端口取自 `.sandtable-runtime/session/server.port`）：上报 `agent-state main=working` → 处理该消息 → `POST /mailbox/inbox/ack` → 上报 `agent-state main=idle` → 再 `/sandtable-mobile-wait` 拉下一个等待子 agent。出错则上报 `main=error`。
4. 主 agent 更新了 Sandtable 文档、且 sync active 时，才 `POST /mobile-sync/push-state`；阶段性动作在 `journal.md` 记一条。

不要询问是否继续。
