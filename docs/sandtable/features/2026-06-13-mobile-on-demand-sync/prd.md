# 按需 Mobile 同步 PRD

## 1. 目标

开发者通过 slash 命令按需开启/关闭手机同步；电脑端 Sandtable 流程不变；手机用 4 位 PIN 配对；子 agent 监听手机回写并通知主 agent。

## 2. 功能需求

- FR1: `/sandtable-mobile-start` 启动 runtime、生成 4 位 PIN、写 session、提示启动 wait worker
- FR2: 手机 App 输入 Server URL + 4 位码完成配对
- FR3: `/sandtable-mobile-stop` 终止同步并停止 server
- FR4: `/sandtable-mobile-status` 查看配对状态
- FR5: 手机回答/确认进入 outbox，worker 可轮询并唤醒主 agent
- FR6: Agent 发往手机的可见消息必须遵循格式契约：`status/phase` 为单行纯文本；包含多个事实、决策、测试结果、阻塞或待确认事项时，使用 `chat/question` 多行 Markdown；禁止裸 JSON、终端噪声和无结构长段落

## 3. 验收标准

- [ ] start 输出 4 位码；手机配对后 status 显示 paired
- [ ] stop 后 health 不可用或 session inactive
- [ ] 主 agent 推 phase 后手机 Listening UI 更新（依赖既有 SSE）
- [ ] Agent 的开始/进展/完成/问题/错误消息按统一 Markdown 模板显示；多行 Markdown 可通过统一 notify 脚本发送并保持原文
