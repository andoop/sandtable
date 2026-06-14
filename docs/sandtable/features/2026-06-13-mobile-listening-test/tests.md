# 手机端事件监听 · 测试用例

> 映射 companion TC2；tests.md = 理解闸门。

## TC1 · App 订阅 SSE 并显示 Listening

**Given:** server 以 `--host 0.0.0.0 --public-url http://<lan-ip>:8765` 运行；iOS App 已配对 feature。

**When:** 进入 feature 主页。

**Then:** 状态卡显示 **Listening**（绿点）；若 `state.md` 存在则显示当前 phase/blocked。

**状态:** 已实现 · 待 iOS 真机确认

## TC2 · phase_update 实时刷新（companion TC2）

**Given:** App 在 feature 主页且显示 Listening。

**When:** 电脑执行 `./scripts/mobile-listening-e2e.sh --phase PLAN ...` 或 MCP `syncPhase`。

**Then:** App **无需重启**，phase 卡更新为 `PLAN` 且 summary 可见。

**状态:** 已实现 · 待 iOS 真机确认

## TC3 · document_snapshot 标记文档更新

**Given:** App 在 feature 主页。

**When:** 执行 sync/document 推送 `prd` 更新。

**Then:** 文档列表 `prd` 行显示 **Updated on server** / 新图标；打开后拉取最新内容并清除标记。

**状态:** 已实现 · 待 iOS 真机确认

## TC4 · 断线重连

**Given:** App 正在 Listening。

**When:** 停止 server 数秒后重启。

**Then:** App 显示 Reconnecting…，server 恢复后自动回到 Listening。

**状态:** 已实现 · 待 iOS 真机确认

## TC5 · 不破坏既有能力

**Given:** 已实现 SSE 后。

**When:** 扫码配对、读文档、回答/确认、Disconnect、Stop runtime。

**Then:** 行为与 mobile-review-companion 基线一致。

**状态:** 已实现 · server 单测通过；真机待确认
