# 待开发者澄清 · Questions

> 本需求 PRD 草案已写，但下列问题会显著影响范围与验收；请在确认 PRD 时一并答复。

## Q1（状态：已答复）
- 问题：「测试一下手机上监听」具体指哪一种监听？
- 为什么阻塞：三种解读对应完全不同的工作量——(A) Flutter App 订阅 server `/events` SSE；(B) 验证 agent 端 mailbox 轮询 worker（TC7/TC12）；(C) 仅手工跑一遍配对+看文档，不涉及实时推送。
- 我已尝试的确认途径：读 `apps/mobile/lib/api.dart`、`feature_screen.dart`、`runtime/server/src/http.ts`、mobile-review-companion 的 `tests.md` TC2/TC7、`plan.md` 事件流章节。
- 可选项：
  - **A.** 手机 App 实时监听 server 事件（推荐，与 TC2 / plan 一致）✓
  - **B.** 验证 agent 轮询 worker 收到手机端写回后的通知链路
  - **C.** 仅真机 E2E：配对、读文档、提交回答（不要求实时推送）
  - **D.** A + C：先补齐 App 监听，再在真机上验收
- 开发者答复：**A** — 手机 App 订阅 server `/events` SSE，实时看 phase/文档更新。
- 已写回：`prd.md` §3 方案 A、`prd.md` §4–§5、`journal.md` 2026-06-13 20:05

## Q2（状态：已答复）
- 问题：真机测试的目标平台？
- 为什么阻塞：iOS 需 Xcode/签名/本地网络权限；Android 需 adb/局域网；验收步骤不同。
- 我已尝试的确认途径：用户当前打开 `AppDelegate.swift` 与 iOS Podfile，推测优先 iOS，但未确认。
- 可选项：**A.** iOS 真机 ✓ **B.** Android 真机 **C.** 两者 **D.** 模拟器即可
- 开发者答复：**iOS 真机**
- 已写回：`prd.md` §7 MUST、`journal.md` 2026-06-13 20:05

## Q3（状态：已答复）
- 问题：本需求与 `2026-06-13-mobile-review-companion`（VERIFY）如何挂钩？
- 为什么阻塞：决定 tests/plan 是引用既有 TC2 还是新建独立用例，以及是否在 VERIFY 清单上勾选。
- 我已尝试的确认途径：读 `features/2026-06-13-mobile-review-companion/state.md`、`tests.md` TC2（状态：待验证）。
- 可选项：
  - **A.** 作为 mobile-review-companion 的 VERIFY 续跑，关闭 TC2（及关联 TC）✓
  - **B.** 独立 feature，不回头改 companion 的 VERIFY 状态
- 开发者答复：**作为 companion VERIFY 续跑，关闭 TC2**
- 已写回：`prd.md` §1/§5 FR5、`journal.md` 2026-06-13 20:05
