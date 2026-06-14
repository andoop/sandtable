---
feature: 2026-06-13-mobile-review-companion
phase: VERIFY
blocked: false
updated: 2026-06-14T12:27:00+08:00
tasks:
  - { id: T1, title: 固化协议与运行时边界, status: integrated }
  - { id: T2, title: 建立 server runtime 工程, status: integrated }
  - { id: T3, title: 实现文件信箱, status: integrated }
  - { id: T4, title: 实现 Sandtable 文件读取与写回, status: integrated }
  - { id: T5, title: 暴露 MCP 工具, status: integrated }
  - { id: T6, title: 实现局域网 HTTP 配对与事件流, status: integrated }
  - { id: T7, title: 建立 Flutter App 工程与模型, status: integrated }
  - { id: T8, title: 实现 Flutter App 审阅界面, status: integrated }
  - { id: T9, title: 增加 agent 同步纪律和常驻轮询说明, status: integrated }
  - { id: T10, title: 更新 README INSTALL UPDATE 边界, status: integrated }
  - { id: T11, title: 端到端验收脚本与手工验证清单, status: integrated }
  - { id: T12, title: 最终一致性检查, status: integrated }
  - { id: T13, title: 多 agent 多会话架构与手机工作台重构, status: integrated }
rehearsals:
  mental:  { runs: 1, last: anomaly }
  redteam: { runs: 0, last: none }
  impl:    { runs: 0, last: none }
autonomy:
  mode: manual
  min_rounds: { mental: 1, redteam: 1, impl: 1 }
  min_agents_per_round: { mental: 1, redteam: 1, impl: 1 }
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none
selected_impl: none
---

## 当前进展
开发者显式要求跳过 live/实现预演并直接实现。已落地 server runtime、Flutter Android/iOS App、协议/运行时文档、README/INSTALL/UPDATE 边界和 using-sandtable 接线；当前进入 VERIFY。

## 关键决策（最近）
- 2026-06-13 12:16: 需求范围不应只绑定 Codex；必须抽象为 Cursor / Claude Code / Codex / 通用 agent 都可使用的协议与运行时。
- 2026-06-13 12:16: PRD 草案可先写，但 TESTCASES / PLAN / 推演必须等 PRD 与约束例外得到开发者确认。
- 2026-06-13 17:45: 开发者回复"继续"，按上一轮推荐默认项执行：允许可选 runtime 子系统，首版本机/局域网扫码配对，采用文件信箱 + MCP 工具协议。
- 2026-06-13 17:56: 开发者要求"下一步要干什么，写详细的plan 吧"，记录为 tests.md 方向确认；已写 plan.md 并进入 MENTAL_REHEARSAL。
- 2026-06-13 18:13: mental-1 返回 ANOMALY_FOUND；已修 plan.md 中事件桥、轮询协议、扫码配对、stop、MCP 事件流、questions/state 写回问题。
- 2026-06-13 18:28: 开发者指出关键缺口：agent 不能终止，以及子 agent 等待信箱过程。已补 FR9、TC11、TC12 和 continuation lease / polling worker 计划。
- 2026-06-13 18:51: 开发者确认产品方向：相信未来 agent 是持续工作态，分主 agent 与一组不同功能子 agent，未明确 stop 就一直存活；等待方式不局限于单个子 agent 或 wait/轮询。已把 worker 队列、mixed wait mode 和接力规则写入 PRD/tests/plan。
- 2026-06-13 19:06: 开发者显式要求"直接实现吧，所有完整代码，不用 live了"。已跳过 live/实现预演，直接集成代码并进入 VERIFY。
- 2026-06-14 12:27: 开发者要求重构为多 agent / 多会话手机管理工作台。已新增 runtime session 抽象、session API、手机会话列表和会话详情对话界面，并通过验证。
