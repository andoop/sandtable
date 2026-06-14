# Mental Rehearsal 1

## 结果

ANOMALY_FOUND

## 派发视角

- 协议 / 跨 agent 通用性: ANOMALY_FOUND
- Server runtime / MCP / HTTP / Sandtable 写回: ANOMALY_FOUND
- Flutter App / 手机审阅体验: ANOMALY_FOUND
- 安装 / 更新 / skill 接线边界: LOGIC_CLOSED

## P1 异常

### A1 · 文件信箱最低可用链路不闭环

- 偏差/问题: 计划原 T3 只把 inbox 消息移动到 processed，没有把 agent-origin 消息桥接到 server event 或 outbox，TC3 中无 MCP agent 的最低可用路径无法让手机端看到同步内容。
- 位置: `plan.md` 原 T3/T5/T11；`tests.md` TC3；`prd.md` FR5。
- 为什么是问题: PRD 要求不支持 MCP 的 agent 也有最低可用路径；原计划只能证明文件被处理，不能证明手机端或轮询 worker 可见。
- 分级: P1。高概率触发，核心通用性受损，开发者会明显感知。
- 回修: 已在 plan 中新增 `events.ts`、`polling.ts`、`processInboxOnce`、outbox 桥接和 TC3/TC7 验证断言。

### A2 · 常驻低成本轮询协议不足

- 偏差/问题: 原 T9 只写“worker reports new mobile messages”，未定义游标、去重、stop event、通知 payload、主 agent resume 读取点。
- 位置: `plan.md` 原 T9/T11；`tests.md` TC7；`prd.md` FR6。
- 为什么是问题: 常驻会话是本需求核心能力；协议不明确会让不同 agent 无法通用实现。
- 分级: P1。高概率触发，核心工作流无法闭环。
- 回修: 已在 plan 中定义 `.sandtable-runtime/mailbox/cursors/<worker-id>.json`、`toMainAgentNotification` 和 runtime 文档中的 polling worker 协议。

### A3 · 首版扫码配对未落实

- 偏差/问题: PRD/tests 已确认“手机扫码配对”，但原 T8 写成手动输入 server URL/token，二维码扫描后续接入。
- 位置: `plan.md` 原 T8；`prd.md` 已确认问题 Q2；`tests.md` TC4。
- 为什么是问题: 直接违反已确认验收路径。
- 分级: P1。必现，用户首次配对路径不符合需求。
- 回修: 已把 T6 `/pairing` 改为返回 `sandtable://pair?...` 的 `qrPayload`，T8 改为首版必须用 `mobile_scanner` 扫码，手动输入只保留调试入口。

### A4 · `POST /stop` 声明但未实现

- 偏差/问题: 原 T6 API 列表声明 `POST /stop`，代码片段没有 route 和 stop callback。
- 位置: `plan.md` 原 T6；`tests.md` TC8。
- 为什么是问题: 电脑端主动停止是 MUST，且影响轮询 worker/app 断开。
- 分级: P1。必现，停止链路不可用。
- 回修: 已在 T6 增加 `POST /stop` route、`stop` callback 和 HTTP 测试预期。

### A5 · MCP/document snapshot 不进入事件流

- 偏差/问题: 原 MCP handler 只写 inbox，没有进入 event stream/outbox，手机端无法无重启看到 TC2 要求的 phase/document 更新。
- 位置: `plan.md` 原 T5/T6；`tests.md` TC2；`prd.md` FR2/FR3。
- 为什么是问题: MCP 同步到手机端是主链路。
- 分级: P1。高概率触发，手机实时审阅不可用。
- 回修: 已在 T5 增加 `RuntimeEvents` 和 `enqueueOutbox`，MCP phase/document 同步必须发布事件和 outbox。

### A6 · 手机问题回答写回不足以解除阻塞

- 偏差/问题: 原计划只 append journal，没有更新 `questions.md` 或 `state.md`，也缺 feature id / resolved marker。
- 位置: `plan.md` 原 T4/T6；`tests.md` TC5；`prd.md` FR7。
- 为什么是问题: resume 后无法可靠判断阻塞已解除，违反可追溯记忆。
- 分级: P1。高概率触发，阻塞解除/PRD 门禁会错判。
- 回修: 已在 T4/T6 增加 `recordQuestionAnswer`、`setBlocked`、feature id、source、resolved marker 和对应测试断言。

## LOGIC_CLOSED 视角

安装 / 更新 / skill 接线边界闭环:

- 默认安装/更新仍只处理方法论资产，不把 Node/Flutter/Dart runtime 接入默认流程。
- T9 覆盖根 skill、Codex plugin skill、英文 skill、英文 Codex plugin skill 四份副本。
- T10 只更新 README/INSTALL/UPDATE 文档边界，不改安装脚本依赖。
- 残余风险 P2/P3: T9 的 `rg` 验证偏人工；T10 示例文本中英混排，发布前可统一文风。

## 主 agent 核实

已亲自核对 P1 指向的 plan/tests/prd 片段，并确认这些问题影响 FR5/FR6/FR7/FR2/FR3/FR4/TC2/TC3/TC4/TC5/TC7/TC8 的闭环。已回修 `plan.md`，下一步必须重跑 mental。
