---
name: writing-tests
description: Use after the PRD is confirmed and before writing the change plan, to derive concrete, black-box, human-readable test cases that verify whether the AI truly understands the requirement. Each case must map back to a PRD requirement or acceptance criterion. Produces docs/sandtable/features/{id}/tests.md.
---

# 写测试用例 · 检验"AI 真的懂了"的闸门（黑盒、人可读）

测试用例是 PRD 与计划之间的一道**理解对账闸门**。它把抽象的验收标准，具体化成"给定什么→做什么→应当看到什么"的场景；开发者读一眼就能判断 AI 是否真的理解了需求。它也是三类推演的统一**突破点**。

**本质先讲清楚**：测试用例首先是 **AI 对产品需求理解的具体表现，也是给人看的具体细节**。它**不见得都能执行**（不是代码、不保证能跑）。能写成可执行/可判定的形式最好；不能时，它就是供人和推演**参考**理解是否到位的依据。不要为了"可执行"而把它写成代码或塞进未被要求的命令。

**开始时声明：** "我在用 writing-tests 把需求具体化为测试用例。"

## 硬门禁

<HARD-GATE>
1. 测试用例必须基于**已确认的 prd.md**。
2. **映射约束（防重复）：每条用例必须能追溯映射回某条 功能需求(FR) / 验收标准 / MUST / MUST NOT**；写不出映射的用例不要写。
3. 黑盒：用 Given/When/Then + 具体输入→预期输出表达，**技术栈无关、不含任何代码级断言**（代码级落地属于 plan）。
不确定的需求点回到 being-truthful，不在用例里发明需求。
</HARD-GATE>

## 三产物职责（别重复）

| 产物 | 职责 | 形态 |
|------|------|------|
| PRD §5 验收标准 | 抽象的"成功定义" | 高层、二元条件 |
| **tests.md（本技能）** | 把成功定义**具体化为可演练场景**，是 AI 理解的具体表现 + 给人看的细节（**不强求可执行**） | 黑盒 Given-When-Then + 具体输入/预期 |
| plan 的验证步骤 | 代码/命令级落地，**引用本文件 TC 编号**，不另造预期 | 依附任务/语言 |

> 边界：具体的可演练场景写在这里，不要回填进 §5；§5 保持抽象。能执行的检查（如示例输入/可观察结果）写得越具体越好，但**可执行不是硬性要求**——不可执行的用例同样有效，作参考。这样三者不重叠。

## 开发者审阅指引（写给读 tests.md 的人）

- **tests.md = 理解闸门**：开发者**先读本文件**，逐条看 Given/When/Then，判断"AI 是否真的懂我要什么"。
- **PRD §5 = 完成闸门**：留到 VERIFY 阶段勾选"做完没"。

## 一条用例长什么样

- **编号 + 标题**：TC<N> · 一句话场景。
- **映射**：指向 FR / 验收 / MUST / MUST NOT 之一。
- **Given**：前置条件/初始状态。
- **When**：触发操作 + **具体输入**。
- **Then**：**具体的**预期输出/可观察结果（写真实值，禁止"正确/正常/没问题"）。
- **状态**：待验证 / 已验证。

覆盖正常路径 + 关键边界/异常路径（每条仍须可映射）。

## 自查（写完用新眼睛看一遍）

| 检查 | 修法 |
|------|------|
| 有用例映射不回任何 FR/验收/MUST/MUST NOT？ | 删除或先去补 PRD（不发明需求）|
| Then 写成"正确/正常"？ | 改成具体可观察的值 |
| 出现代码/框架名？ | 改成黑盒表达，代码级落地交给 plan |
| 只有正常路径？ | 补关键边界/异常用例（仍须可映射）|
| §5 里塞了具体命令/输入？ | 把具体的下沉到本文件，§5 只留抽象成功定义 |

## Red Flags

| 念头 | 现实 |
|------|------|
| "把验收标准抄过来就是用例" | §5 是抽象条件，这里要具体化成 Given/When/Then 场景。 |
| "这条用例映射不回需求，但挺有用" | 映射不回就不写——否则是发明需求/范围蔓延。 |
| "顺手写两句断言代码更准" | 这里只黑盒；代码级落地是 plan 的事。 |
| "用例必须能执行/能自动跑才算数" | 不必。用例本质是理解的具体表现 + 给人看的细节；能执行最好，不能就作参考。 |
| "这条 case 暂时跑不了，删掉" | 不删。不可执行的用例照样检验理解，标注"参考/人工核对"即可。 |
| "Then 写'结果正确'就行" | 没有具体预期值的用例无法检验理解。写真实值。 |

完成并经开发者确认后，更新 `state.md`（phase=PLAN），加载 `writing-plan`。tests.md 随后作为三类推演的逐条突破点被注入各预演 prompt。

## PRD 确认门禁与已选择路径直接执行

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
