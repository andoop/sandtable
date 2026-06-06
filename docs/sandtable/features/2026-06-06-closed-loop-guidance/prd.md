# PRD · 回合收尾与下一步引导（闭环感知）

> 对应 project.md 北极星 / 继承 constraints.md 红线。实现细节见 plan.md，具体场景见 tests.md。

## 目标

让使用 Sandtable 的开发者在**每一次 Sandtable 工作回合结束**时，都能明确感知「沙盘进行到哪、下一步该做什么」，并拿到**可直接复制发送**的下一条指令模版；在手动模式下优先用 **AskQuestion** 做选择，在 **autopilot** 下由主 agent **自行续跑**而不打断。

## 背景与现状

- Sandtable 状态机与 `autonomy.mode` 已写在 `skills/state-and-memory/SKILL.md`，但用户在日常多轮对话中往往**感受不到**自己在流程的哪一站（开发者原话）。
- `/sandtable-start` 仅在命令末尾用一段自然语言提示后续 slash（`commands/sandtable-start.md:14`），**没有**统一的回合收尾格式与可复制模版。
- `/sandtable-status` 会建议下一步，但是只读汇报（`commands/sandtable-status.md:13`），无标准模版。
- `autonomous-orchestration` 要求 autopilot 下不要逐步问用户（`skills/autonomous-orchestration/SKILL.md:75`），与本需求的「自动模式自己选择」一致。
- 当前仓库**没有**专门描述「回合如何收尾」的 skill。

## 用户故事 / 使用场景

- 作为一个**手动模式**开发者，我在 `/sandtable-start` 跑完前五步后，希望 AI 告诉我「当前在 PLAN、建议进入推演」，并给出可复制的 `/sandtable-rehearse` 或 `/sandtable-autopilot` 整段提示词；若 AI 能弹出选择题，我点选即可继续。
- 作为一个**连续对话**的开发者，我在没打 slash 的情况下让 AI 写 plan，结束时仍希望看到「Sandtable 战况 + 下一步模版」，而不是像普通 coding 一样戛然而止。
- 作为一个 **autopilot** 用户，我触发 `/sandtable-autopilot` 后，不希望每阶段都被问「要不要继续」；AI 应读 `state.md` 自行推进，只在真阻塞时提问。

## 方案探索

| 方案 | 做法 | 优点 | 缺点 |
|------|------|------|------|
| A. 只改各 command 尾部 | 13 个命令各写一段「下一步」 | 改动面直观 | 13 处易漂移；phase 与命令映射重复 |
| **B. 独立 `closing-the-loop` skill（推荐）** | 单一 skill 维护 phase/block/autonomy→下一步表 + 收尾纪律；`using-sandtable`/rules/commands 引用 | 单一事实来源；可本地化；与 state.md 对齐 | 需同步多镜像路径 |
| C. 写入用户 `state.md` 模板 | 每个 feature 的 state 里嵌下一步文案 | 用户项目可见 | 污染用户 docs；与「插件内方法论」边界冲突 |

**推荐 B**：与 `constraints.md`「模板/内容单一事实来源」精神一致，且不把噪音写入用户项目的 `docs/sandtable/features/*/state.md`。

## 功能需求

- **FR1（收尾强约束）**：凡完成一个 Sandtable **阶段动作**（写完 prd、跑完一轮 mental、执行 `/sandtable-status` 等），主 agent 必须在回复**末尾**增加固定结构的「回合收尾」区块（见 FR2）。〔已确认：开发者要求「强约束」「输出内容后提示」〕
- **FR2（收尾区块结构）**：定义两种 profile。（**完整收尾**）至少四部分：战况 / 推荐 / 可复制模版 / 其他路径。（**战报收尾**）用于 autopilot 或链式命令中间切换：战况 + `autonomy.last_decision` + 续跑声明；省略 AskQuestion 与完整模版。〔已确认：mental-1 推演收口〕
- **FR3（AskQuestion 集成）**：当 `autonomy.mode=manual` 且存在 **≥2 条合理下一步**（例如 PLAN 后「只推演」vs「autopilot 全流程」），主 agent **必须**调用 AskQuestion 让用户选；仅 1 条主路径时可省略 AskQuestion，但仍须给可复制模版。〔已确认：开发者「能调用问题工具就调用」〕
- **FR4（autopilot 纪律）**：当 `autonomy.mode=autopilot` 且 `blocked=false`，主 agent **不得**用 AskQuestion 问「是否继续」；应依据 `state.md` 与 `autonomous-orchestration` 配额闭包**直接执行**下一合法动作；回合末仅报告「已自动续跑至 \<phase\>」及 `autonomy.last_decision`。〔已确认：开发者「自动模式，自己选择」〕
- **FR5（blocked 分支）**：`blocked=true` 时，收尾区块必须指向 `questions.md` 中的阻塞项；AskQuestion 选项围绕「已答复可续跑 / 修改需求 / 查看战报」；可复制模版以 `/sandtable-resume` 或澄清答复为主。〔已确认〕
- **FR6（phase 映射表）**：`closing-the-loop` skill 内维护 **phase → 默认下一步命令 → 模版正文** 映射，覆盖 `state-and-memory` 全部 phase 及「异常回退」情形；映射须与 `using-sandtable` 状态机表一致。〔已确认〕
- **FR7（接入点）**：至少更新：`skills/closing-the-loop/SKILL.md`（新建）、`skills/using-sandtable/SKILL.md`、`skills/autonomous-orchestration/SKILL.md`（交叉引用收尾纪律）、`.cursor/rules/sandtable.mdc`、`AGENTS.md`、全部 `commands/sandtable-*.md` 的「完成后」步骤、英文 `locales/en/` 镜像。〔已确认：多路径安装面〕
- **FR8（适用范围）**：**正触发**：本回合已读写 `docs/sandtable/`，且 Sandtable 工作步结束需确认/选下一步，或 autopilot/链式命令阶段切换（战报 profile）。**负触发**：与 Sandtable 无关 → 禁止收尾（无论是否读过 `docs/sandtable/`）。**第三态**：已读写 `docs/sandtable/` 但本回合非 Sandtable 工作步（如顺手查 state）→ 仍禁止完整收尾。rules 层须内嵌负触发，不得写裸「每回合收尾」。典型正触发：slash 命令边界结束、OBJECTIVES 待确认 PRD、`/sandtable-start` 在步骤4 结束、推演命令结束、autopilot 终局。链内中间阶段仅战报收尾，**禁止省略**。〔redteam-1 收口〕

## 验收标准（抽象成功定义）

- [ ] 手动模式下，完成任一 Sandtable 阶段后，用户**无需回忆** slash 名称即可从收尾区块复制下一条消息继续。
- [ ] autopilot 模式下，用户**不会**被「要不要继续」类 AskQuestion 打断；推进依据 `state.md`。
- [ ] `blocked=true` 时，用户能从收尾区块知道阻塞内容与恢复路径。
- [ ] 新增 skill 与 phase 映射表可被 `/sandtable-status`、各 command 与 rules **一致引用**，无相互矛盾的下一步建议。

## MUST

- 必须新建 `skills/closing-the-loop/SKILL.md` 作为回合收尾的**单一事实来源**。
- 必须在手动模式、多分支时用 AskQuestion（工具可用时）。
- 必须在 autopilot、非阻塞时自动续跑，不弹「是否继续」。
- 必须给出**完整可复制**的下一条用户消息模版（非仅 slash 名称）。
- 必须同步 `plugins/sandtable/` 与 `locales/en/` 镜像路径。

## MUST NOT

- 禁止在 autopilot 非阻塞路径用 AskQuestion 打断自动推进（与 `autonomous-orchestration` 一致）。
- 禁止把下一步模版正文硬编码进 `hooks/session-start` 或用户项目 `templates/`（方法论留在插件 skills）。
- 禁止为「普通 coding 对话」强加 Sandtable 收尾（见 FR8 边界）。
- 禁止改动无关 skill 的 Red Flags / 硬门禁表正文（仅允许追加交叉引用或本需求授权的新 skill）。

## 非目标 / 暂不做

- 不做 UI 插件或 Cursor 扩展；仅 agent 行为 + markdown skill。
- 不做基于 `state.md` 的自动生成脚本（零运行时依赖约束下不新增 node/python 工具）。
- 不改造 `AskQuestion` 工具本身；仅定义调用纪律。
- 不在用户项目 `docs/sandtable/` 写入「下一步模版」副本。

## 未决问题

见 `questions.md`。（FR8 已按开发者答复收口。）
