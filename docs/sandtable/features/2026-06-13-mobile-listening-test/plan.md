# 手机端事件监听 · 作战计划

## 架构

Flutter `FeatureEventListener` 订阅 server `GET /events`（SSE），按 feature id 过滤 `phase_update` / `document_snapshot` / `stop`。`FeatureScreen` 展示连接状态、phase 摘要、文档 stale 标记。Server 增加 pairing 认证的 `sync/phase` 与 `sync/document` 供 E2E 脚本触发事件。

## 任务

- [x] T1: `sse_parser.dart` — SSE 帧解析
- [x] T2: `runtime_event.dart` + `state_summary.dart` — 事件与 state  frontmatter 模型
- [x] T3: `event_listener.dart` — 连接、过滤、重连、notify
- [x] T4: `feature_screen.dart` — Listening UI、phase 卡、stale  badge
- [x] T5: `http.ts` — `sync/phase`、`sync/document` 测试端点
- [x] T6: `scripts/mobile-listening-e2e.sh` + `runtime.md` iOS 步骤
- [x] T7: `Info.plist` — `NSAllowsLocalNetworking`
- [x] T8: 单测 — `test/sse_test.dart`、`runtime/server/test/http.test.ts`
- [ ] T9: iOS 真机验收 — 开发者按 `runtime.md` 执行并确认 TC2

## iOS 真机验收步骤

见 `docs/mobile-review-companion/runtime.md` § iOS Real-Device Listening Test。

## 验证命令

```bash
npm --prefix runtime/server test
cd apps/mobile && flutter test
```
