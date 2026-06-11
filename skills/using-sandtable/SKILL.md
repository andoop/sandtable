---
name: using-sandtable
description: Use when starting any work that builds or changes a feature, writes requirements/PRD, makes a plan, or whenever the user mentions 沙盘/预演/推演/rehearsal/dry-run. The overview skill that explains the Sandtable loop and which sub-skill to load.
---

<SUBAGENT-STOP>
若你是被派发来执行某个具体任务（头脑预演 / 红蓝对抗 / 实现预演 / 评审）的子 agent，跳过本技能，直接执行你收到的任务 prompt。
</SUBAGENT-STOP>

# Sandtable · 沙盘推演驱动开发

把一句简单描述或一份粗糙需求，做成开发者**真正想要**的功能——逻辑闭环、产品闭环、细节完美。手段是一个不断加固的循环：**计划 → 推演 → 发现问题 → 修正计划 → 再推演**。

> **术语**：本文"推演"是统称，包含三类——**头脑预演**（只读推逻辑）、**红蓝对抗**（红军专攻找破绽）、**实现预演**（隔离 worktree 真改代码）。

<EXTREMELY-IMPORTANT>
只要有 1% 的可能某个 sub-skill 适用于你当前的动作，你就必须读取并遵循它。你无法用"这次很简单""我先看看代码""这只是个问题"把自己合理化出流程之外。违反规则的字面，就是违反规则的精神。
</EXTREMELY-IMPORTANT>

## 优先级

1. **用户的显式指令**（本条最高）——用户说"跳过流程/直接改"，照做，但提醒风险。
2. **Sandtable 方法论**——覆盖默认行为。
3. **默认系统行为**——最低。

## 核心闭环（状态机）

```dot
digraph sandtable {
  rankdir=LR;
  INTAKE [shape=box label="INTAKE\n受领任务"];
  RECON [shape=box label="RECON\n战场侦察"];
  OBJ [shape=box label="OBJECTIVES\n目标+红线"];
  TESTS [shape=box label="TESTCASES\n标定靶标"];
  PLAN [shape=box label="PLAN\n作战计划"];
  MENTAL [shape=box label="头脑预演"];
  RED [shape=box label="红蓝对抗(可选)"];
  IMPL [shape=box label="实现预演"];
  EVAL [shape=diamond label="全部顺利?"];
  INTEGRATE [shape=box label="INTEGRATE\n落地"];
  VERIFY [shape=box];
  DONE [shape=doublecircle];
  FEEDBACK [shape=box label="FEEDBACK\n落地后闭环(可重入)"];
  FIX [shape=box label="亲自核实→问开发者→修正目标/计划"];

  INTAKE -> RECON -> OBJ -> TESTS -> PLAN -> MENTAL -> RED -> IMPL -> EVAL;
  MENTAL -> FIX [label="ANOMALY"];
  RED -> FIX [label="BREACH"];
  IMPL -> FIX [label="ANOMALY"];
  EVAL -> FIX [label="否"];
  EVAL -> INTEGRATE [label="是, 复盘择优"];
  FIX -> OBJ [label="重走"];
  INTEGRATE -> VERIFY -> DONE;
  DONE -> FEEDBACK [label="用户验收反馈"];
  FEEDBACK -> FIX [label="缺陷→根因/重演"];
}
```

| 阶段(phase) | 军事隐喻 | 做什么 | 加载的 skill | 命令 |
|------|------|--------|-------------|------|
| INTAKE | 受领任务 | 捕获原始需求（一句话/产品文档），建目录 | `state-and-memory` | `/sandtable-start` |
| RECON | 战场侦察 | 主动收集代码/文档情报，列未知，提问 | `gathering-intel` | `/sandtable-recon` |
| OBJECTIVES | 指挥官意图 | 定目标、MUST/MUST-NOT、红线、验收 | `writing-prd` | `/sandtable-objectives` |
| TESTCASES | 标定靶标 | 把成功定义具体化为黑盒用例,检验理解 | `writing-tests` | （并入 /objectives, /refine 迭代）|
| PLAN | 作战计划 | 写细到可执行的改动计划 | `writing-plan` | `/sandtable-plan` |
| （任意阶段）| 调整部署 | 据反馈反复修改/重制目标/用例或计划 | `writing-prd`/`writing-tests`/`writing-plan` | `/sandtable-refine` |
| MENTAL_REHEARSAL | 图上作业 | 只读子 agent 推演逻辑闭环 | `mental-rehearsal` | `/sandtable-mental` |
| REDTEAM | 红蓝对抗 | 红军子 agent 专攻找破绽（可选，强烈推荐）| `red-team-wargame` | `/sandtable-redteam` |
| IMPL_REHEARSAL | 实兵演习 | 子 agent 在隔离 worktree 真改代码 | `implementation-rehearsal` | `/sandtable-live` |
| EVALUATE | 战损复盘 | 全部顺利则打分择优 | `evaluating-rehearsals` | `/sandtable-debrief` |
| INTEGRATE | 落地 | 把选定实现落到主分支 | — | — |
| VERIFY | 战果确认 | 跑测试/验收，确认成功标准 | `being-truthful` | — |
| FEEDBACK | 战后讲评 | 受理验收反馈,分诊,缺陷转 bugfix 根因(日志100%),回归+教训沉淀 | `triaging-feedback` / `bugfix-with-evidence` | `/sandtable-bug` `/sandtable-bugfix` |
| （随时）| 战报/接防 | 看状态 / 新 AI 重获记忆继续 | `state-and-memory` | `/sandtable-status` `/sandtable-resume` |

每个阶段都有独立命令，可单独触发、反复迭代，无需一次跑完。`/sandtable-start` 负责前五步，`/sandtable-rehearse` 只负责推演与复盘，不是需求入口；若开发者要求 AI 自主连续推进，使用 `/sandtable-autopilot`。

补充说明：
- `/sandtable-start`：只负责 `INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN`。
- `/sandtable-rehearse`：只负责 `MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE`。
- `/sandtable-autopilot`：在当前回合显式启用自动模式，覆盖从需求输入到复盘择优的无人值守推进。
- **落地后闭环（FEEDBACK）**：DONE 后用户验收反馈进入，由 `/sandtable-bug`（受理分诊）与 `/sandtable-bugfix`（证据驱动根因，**必靠日志100%**）手动推进；缺陷修复后产出回归用例 + 根因/预防/教训三件套，教训累积进全局 `lessons.md` 反哺未来 RECON/红军/PRD。**FEEDBACK 人在环，autopilot 不驱动**（autopilot 范围止于 EVALUATE/DONE）。

## 三类推演各问一个问题

- **头脑预演**：逻辑通不通？（只读推演整条链路是否闭环）
- **红蓝对抗**：能不能被打破？（红军寻找真实可复现破口，验证方案是否能被打破）
- **实现预演**：做出来对不对？（隔离 worktree 真打一遍）

## 推演铁律（两条，三类推演通用）

1. **任一推演只要发现与计划不符、意料之外、或之前没注意到的事，立即终止并上报。** 禁止"顺手改一下继续跑"。这种发现恰恰是流程的价值所在。
2. **推演在隔离子 agent 中进行，可并行多个。** 其中实现预演必须各自独立 git worktree/分支。

## 异常 → 修正 → 重演（系统的心脏）

只要任何推演返回 `ANOMALY_FOUND` / `BREACH_FOUND`（或复盘发现意料之外）：
1. 主 agent **亲自核实**（读相关代码/文档，不轻信子 agent），用客观逻辑判断。
2. 给出**合理方案**；若仍不确定或属于产品决策，**向开发者提问/索要补充**，记入 `questions.md`。
3. 把澄清结论写回 `prd.md` / `tests.md` / `plan.md`，并在 `journal.md` 追加决策记录。
4. **重新推演**，循环直到全部顺利。之后用 `evaluating-rehearsals` 给各实现预演打分，选最高的落地。

## 回合收尾（Sandtable 工作步结束时）

仅当本回合为 **Sandtable 工作步**（正触发见 `closing-the-loop` FR8）时，加载 `skills/closing-the-loop/SKILL.md` 并输出收尾。非 Sandtable 任务（如修 typo）**禁止**收尾，即使读过 `docs/sandtable/`。手动多分支用 AskQuestion；autopilot 非阻塞用战报收尾并同命令续跑。

## 触发规则（Red Flags = 你正在合理化）

| 念头 | 现实 |
|------|------|
| "这个需求太简单，不用走流程" | 简单需求流程可以很短，但必须走。 |
| "我先直接改代码看看" | 先写/确认 PRD 与计划，再推演，再改。 |
| "这个细节我猜应该是…" | 不猜。读代码/文档/问开发者，见 `being-truthful`。 |
| "推演发现点小问题，我顺手修了继续" | 立即终止上报。小问题常是逻辑漏洞的征兆。 |
| "在一个工作区跑多个实现预演更快" | 会互相污染。每个实现预演独立 worktree。 |
| "我记得这套流程，不用读 skill" | skill 会演进，按需读当前版本。 |
| "加个兜底/灵活性更稳" | 不做未要求的兜底，不节外生枝（外科手术式改动）。 |

## 与既有方法论的关系

Sandtable 吸收了 Karpathy 的四原则（不猜测、极简、外科手术式、目标驱动）与 superpowers 的子 agent 编排思想，新增了**三类推演（头脑预演/红蓝对抗/实现预演）+ 持久状态机 + 异常驱动的修正循环**。若项目已装 superpowers，可在 INTEGRATE/VERIFY 阶段复用其 `test-driven-development`、`requesting-code-review`、`finishing-a-development-branch`。

## 问题分级与克制 · P0–P3（推演的共同裁决口径）

推演（头脑预演 / 红蓝对抗）发现的问题，必须**站在用户使用角度分级**，不是为了"逻辑完美"凑数。先判级，再决定是否驱动修正循环。

判级看四个维度：

- **触发概率**：必现 / 大概率 / 小概率 / 仅理论可达
- **功能影响**：核心不可用·数据损坏·违反红线 / 重要功能受损 / 体验瑕疵
- **可恢复性**：用户无法绕过 / 用户重试可救回 / 系统自动救回
- **用户感知**：明显 / 轻微 / 基本无感

| 级别 | 典型组合 | 处置 |
|------|---------|------|
| **P0** | 必现或大概率 + 核心不可用/数据损坏/违反 MUST·MUST-NOT，用户明显感知且无法自救 | 必须作为 `ANOMALY_FOUND`/`BREACH_FOUND` 进修正循环，阻塞落地 |
| **P1** | 大概率影响重要功能，或小概率但后果严重（数据/安全/资金），用户感知、难自救 | 进修正循环修复；确需延后须开发者明确同意 |
| **P2** | 小概率/边缘场景，功能受损但可重试或可自动救回，用户轻微感知 | 记为**残余风险**，向开发者说明，由其拍板本轮是否修 |
| **P3** | 仅理论可达 / 纯瑕疵，用户基本无感或可忽略 | 记录备查，不驱动循环 |

**裁决铁律：只有 P0/P1 驱动修正循环；P2/P3 一律记为残余风险交开发者决定，不得自动拉起重演、不得为追求逻辑完美反复打磨。** 与之配套的真实性口径继续生效：只上报真实、相关、可复现、会影响验收/红线/闭环的问题；不构造无现实触发路径、与本需求无关的偏题场景来凑 `ANOMALY_FOUND`/`BREACH_FOUND`（`being-truthful` 的不猜测原则不变：关键未知不能带着继续）。

**克制与反思**：若一轮推演冒出**大量 P0/P1**，先怀疑**方案本身**（设计过复杂、边界没收敛、需求理解偏差），回到 PLAN/OBJECTIVES 重审，而不是逐条打补丁。问题成堆通常是设计信号，不是补丁清单。

**向开发者解释**：每轮推演结论用人话讲清——发现了什么、定几级、为什么是/不是真问题、对用户的实际影响、建议怎么办。不堆术语、不报"为完美而完美"的伪问题。

## 推演强度分级 · 按风险裁剪（别用牛刀杀鸡）

不是每个需求都要跑满三类推演。先判复杂度/风险，再定强度——简单的流程可以很短，但**判断本身不能跳过**。

| 任务画像 | 建议强度 |
|---------|---------|
| 文案/常量/单行、无逻辑分支、改动可一眼复核 | 可免推演，直接外科手术式改 + 验证；journal 记一句"低风险免推演"及理由 |
| 单一模块、逻辑清晰、影响面可控 | 至少 1 轮**头脑预演**；按需加红蓝对抗 |
| 跨模块/有并发时序/动数据或接口/影响面不清 | 头脑预演 + 红蓝对抗，必要时实现预演 |
| 高风险（红线相关/数据迁移/安全/不可逆） | 三类推演齐上，可多轮 |

选择"跳过/只做其一/组合"必须在 journal 写明理由。**autopilot（无人值守）保留其最低覆盖底线**（见 `autonomous-orchestration`），强度裁剪主要服务手动流程；trivial 改动建议走手动轻量路径或 `/sandtable-bugfix`，不必拉起 autopilot 全流程。

## PRD 确认门禁与已选择路径直接执行

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
