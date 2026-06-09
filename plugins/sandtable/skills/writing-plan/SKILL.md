---
name: writing-plan
description: Use when you have an approved PRD and test cases and need a concrete change plan before any code or rehearsal. Maps files to touch and breaks work into small, verifiable, ordered tasks with exact paths, code, and checks. Produces docs/sandtable/features/{id}/plan.md.
---

# 写改动计划 · 细到可被预演

计划写给"一个有能力但完全不懂本项目、品味存疑、还不爱写测试"的工程师看。每一步都要有：**确切文件路径、要写的代码、怎么验证。** 计划越具体，预演越能精确地发现偏差。

**开始时声明：** "我在用 writing-plan 制定改动计划。"

## 前置

<HARD-GATE>
计划必须基于已确认的 `prd.md` 与 `tests.md`。计划须同时覆盖 `tests.md` 的每条用例；验证步骤**引用 TC 编号**、不另造预期。计划里出现的每个类型/函数/接口，要么在本项目已存在（标 `file:line`），要么在本计划的某个任务里被定义。不允许引用不存在的东西。不确定的，回到 `being-truthful`。
</HARD-GATE>

## 步骤一：文件地图（先决定改哪些文件）

在拆任务前，先列出**将创建/修改的文件**及各自单一职责。一起变的放一起；按职责拆，不按技术分层拆。文件保持聚焦、不臃肿。

## 步骤二：拆成小步任务

每个任务自包含、可独立验证、有明确顺序。每一步是一个 2–5 分钟的动作：

````markdown
### 任务 T<N>: <组件名>

**文件:**
- 创建: `exact/path/to/file.ts`
- 修改: `exact/path/to/existing.ts:120-140`
- 测试: `tests/path/to/test.ts`

- [ ] 步骤1: 写失败测试
```ts
test("具体行为", () => { expect(fn(input)).toBe(expected) })
```
- [ ] 步骤2: 运行测试确认失败
  运行: `pnpm test path/to/test.ts`  预期: FAIL（fn 未定义）
- [ ] 步骤3: 写最小实现
```ts
export function fn(input) { return expected }
```
- [ ] 步骤4: 运行测试确认通过  预期: PASS
- [ ] 步骤5: 提交  `git commit -m "feat: ..."`
````

## 禁止占位符（这些是计划缺陷）

- "TBD/待定/稍后实现/填充细节"
- "加上合适的错误处理 / 校验 / 边界处理"（不给具体代码）
- "为以上写测试"（不给测试代码）
- "类似任务 N"（要重复写出代码，预演子 agent 可能乱序读）
- 描述要做什么却不给怎么做（改代码的步骤必须给代码）
- 引用任何未在计划中定义、项目中也不存在的类型/函数

## 计划头部

```markdown
# <需求名> 改动计划

**目标:**（一句话）
**架构:**（2-3 句approach）
**对应 PRD:** prd.md
**推演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。
```

## 自查（写完用新眼睛对照 PRD）

| 检查 | 修法 |
|------|------|
| PRD 覆盖：每条需求都有对应任务？ | 缺的补任务 |
| tests.md 覆盖：每条 TC 都有对应任务/被某步骤引用验证？ | 缺的补任务/补验证步骤 |
| 占位符扫描 | 全部补实 |
| 类型一致：前后任务里的函数名/签名/字段名一致？ | 统一 |
| 顺序：有依赖的任务排在被依赖之后？ | 重排 |
| MUST NOT：是否有任务隐含越界？ | 删/改 |

完成后更新 `state.md`（写入 tasks 列表，phase=MENTAL_REHEARSAL），加载 `mental-rehearsal`。

## Red Flags

| 念头 | 现实 |
|------|------|
| "步骤写个大概，实现时随机应变" | 模糊计划=预演无法判定偏差。写实。 |
| "错误处理写'妥善处理'就行" | 给出具体代码，否则就是占位符。 |
| "顺手把这块也重构了" | 外科手术式改动。计划只含服务于本需求的改动。 |

## 本需求补充 · 已选择路径直接执行与 PRD 确认证据

- 优先级：真实阻塞 (`blocked=true`、缺产品意图/权限/登录/外部资源/关键事实) 最高，必须写 `questions.md`、设置 `blocked=true` 并提问；其次是 PRD 未确认门禁；之后才执行用户选择。
- 若用户已经通过 AskQuestion 选择下一步，或自然语言明确表达“确认并继续 / 按 X 继续 / 就选 X”，且没有真实阻塞，agent 必须在同一回合执行该选择对应动作。不得再次 AskQuestion，也不得只输出同一动作的复制命令要求用户重复输入。
- 若该选择本身构成 PRD 确认，执行 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL/rehearse/live/debrief 前或同时，必须把可核实 PRD 确认证据写入 `state.md` 或 `journal.md`：AskQuestion 记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间；自然语言记录用户原话摘录 + 确认时间 + 用户消息来源。
- `/sandtable-start` 写完 PRD 且未获确认时仍停在 PRD 确认点；但同回合 AskQuestion 或自然语言已经确认 PRD 并要求继续时，应先落盘证据再直接进入 TESTCASES 写 `tests.md`，旧“本命令在此结束”边界不得压过已选择即续跑。
- `/sandtable-objectives`、`/sandtable-refine`、`/sandtable-resume` 收到“PRD 已确认，请继续写 tests.md”时，先记录自然语言确认三元组，再直接加载 `writing-tests`；`phase=OBJECTIVES` 且 `prd.md` 已存在时不得重新进入 `writing-prd`。
- `/sandtable-plan`、`writing-tests`、`writing-plan` 开始前必须检查 PRD 确认门禁；同条 PRD 确认触发写 tests/plan 时，必须在写入前或同时落盘证据。缺 `tests.md` 但 PRD 已确认时回 TESTCASES；PRD 未确认时停在确认点。
- 修改 PRD 的 refine 反馈仍按 refine 修改；修改 tests/plan 或继续推演必须先满足 PRD 确认门禁。`blocked=true` 且用户同时说继续时，阻塞优先，不执行选择。
- 完整收尾分两类：未选择路径时可给推荐和复制模板；已选择且已执行时只报告执行结果、当前 phase、下一建议，复制模板只能指向下一阶段，不能重复当前已执行选择。
