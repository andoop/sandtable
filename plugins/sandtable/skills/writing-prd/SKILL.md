---
name: writing-prd
description: Use after the request is clarified and before writing test cases and the plan, to capture goals, requirements, acceptance criteria, and the MUST / MUST-NOT redlines for a feature. Produces docs/sandtable/features/{id}/prd.md.
---

# 写 PRD · 目标、需求、验收、红线

PRD 是这个需求的"事实地基"。它要回答：**为什么做、做成什么样算成功、绝对要做什么、绝对不能做什么。** 实现细节留给计划，不在这里。

**开始时声明：** "我在用 writing-prd 把需求固化为 PRD。"

## 硬门禁

<HARD-GATE>
PRD 写之前，必须先经过侦察（RECON，见 `gathering-intel`）。任何"不确定/缺失"的需求点，按 `being-truthful` 去读代码/文档/问开发者，不允许在 PRD 里发明需求。PRD 完成后必须请开发者确认才能进入 TESTCASES。
</HARD-GATE>

## 流程

```dot
digraph prd {
  "读 project.md + constraints.md + lessons.md(若存在)" [shape=box];
  "一次一个问题澄清意图" [shape=box];
  "提出 2-3 个方案 + 推荐" [shape=box];
  "写 PRD 各节" [shape=box];
  "自查: 占位/矛盾/歧义/范围" [shape=box];
  "开发者确认?" [shape=diamond];
  "进入 writing-tests" [shape=doublecircle];

  "读 project.md + constraints.md + lessons.md(若存在)" -> "一次一个问题澄清意图" -> "提出 2-3 个方案 + 推荐" -> "写 PRD 各节" -> "自查: 占位/矛盾/歧义/范围" -> "开发者确认?";
  "开发者确认?" -> "写 PRD 各节" [label="要改"];
  "开发者确认?" -> "进入 writing-tests" [label="通过"];
}
```

## PRD 必含小节

1. **目标**：一句话说清这个需求要为用户达成什么；与 `project.md` 北极星的关系。
2. **背景与现状**：相关代码/模块的事实，标 `file:line`。
3. **用户故事 / 使用场景**：谁、在什么场景、做什么、期望什么结果。
4. **功能需求**：逐条列出，可编号。每条标来源（已确认/待开发者确认）。
5. **验收标准（成功定义）**：§5 只写**抽象成功定义**；具体可演练场景下沉 `tests.md`（见 writing-tests，用例是 AI 理解的具体表现，不强求可执行）。审阅指引：tests.md=理解闸门（先读）、§5=完成闸门（VERIFY 勾选）。
6. **MUST（这个需求绝对要做的）**：硬性要求。
7. **MUST NOT（绝对不能做的）**：边界与红线（含"不做兜底、不节外生枝"），继承 `constraints.md`。
8. **非目标 / 暂不做**：YAGNI，明确砍掉的东西。
9. **未决问题**：指向 `questions.md`。

## 方案探索

在写功能需求前，提出 **2-3 个不同方案**，列权衡，给出推荐项和理由，让开发者选。不要默默选一个。

## 自查（写完后用新眼睛看一遍）

| 检查 | 修法 |
|------|------|
| 占位符（TBD/待定/大概） | 去澄清后补实，或移入 questions.md |
| 内部矛盾（两节冲突） | 改到一致 |
| 歧义（一句话两种解读） | 选一种并写明，必要时问开发者 |
| 范围过大（含多个独立子系统） | 拆成多个需求，各自走流程 |
| 验收不可验证（"做好""能用"） | 改成可测条件 |

## Red Flags

| 念头 | 现实 |
|------|------|
| "需求很清楚，直接写计划" | 没有 PRD 与验收标准，预演无从判定对错。 |
| "PRD 没说的我按常理补" | 不发明需求。缺失要问。 |
| "MUST NOT 是多余的" | 红线缺失，预演就无法识别"越界"这类异常。 |

完成并经开发者确认后，更新 `state.md` 的 phase 为 TESTCASES，加载 `writing-tests`。

## 本需求补充 · 已选择路径直接执行与 PRD 确认证据

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
