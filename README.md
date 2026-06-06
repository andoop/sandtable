# Sandtable · 沙盘推演驱动开发

> 给 coding agent 的方法论插件: 先侦察、定目标、写用例、做推演，再落地实现，把“直接开写”改成“异常先暴露、计划先闭环”。

- **先推演再落地**: 先把逻辑漏洞和实现破口暴露出来，再决定是否进入真实改动。
- **`docs/sandtable/` 持久留痕**: 目标、计划、状态和裁决落盘，换人、换 AI、异常退出都能续上。
- **异常即回修正**: 一旦出现 `ANOMALY_FOUND`、`BREACH_FOUND` 或 `BLOCKED`，就先回写文档、修正计划再重演，绝不带着坏假设硬推。
- **这个仓库正在自举**: Sandtable 自己就用同一套方法打磨 `README`、命令和 skill，每轮推演都回写 `docs/sandtable/`，让方法论随演练一起收紧。

**立刻试用**: 无需手动 clone，把下面两条官方提示词之一**原样**发给你的 AI（Cursor / Claude Code / Codex / Kiro / 其它通用 coding agent 均可）。AI 必须按你贴过去的这条提示词正文选择安装语言，并读取同一个 `INSTALL.md` 完成安装。

中文版：

> 阅读 https://github.com/andoop/sandtable/blob/main/INSTALL.md ，并据此按中文把 Sandtable 安装进当前项目。

English:

> Read https://github.com/andoop/sandtable/blob/main/INSTALL.md and use it to install Sandtable into the current project in English.

安装完成后按你的工具进入 Sandtable 命令：Cursor 使用 `.cursor/commands`，Codex 使用 Sandtable Codex plugin/commands，Claude Code / Kiro / 通用 agent 可直接把命令名作为消息发给 AI 执行。详见 [`Quickstart`](#quickstart)。

```mermaid
flowchart TD
  A[INTAKE] --> B[RECON]
  B --> C[OBJECTIVES]
  C --> D[TESTCASES]
  D --> E[PLAN]
  E --> F[MENTAL_REHEARSAL]
  F --> G[REDTEAM]
  G --> H[IMPL_REHEARSAL]
  H --> I[EVALUATE]
  I --> J[INTEGRATE]
  J --> K[VERIFY]
  K --> L[DONE]
  F -- anomaly / breach / blocked --> M[主 agent 核实]
  G -- anomaly / breach / blocked --> M
  H -- anomaly / breach / blocked --> M
  M --> R[给方案；必要时问开发者]
  R --> N[修正 PRD / 计划]
  N --> F
```

白话说法: 先把需求摸清，再把目标、用例和计划写死，然后用头脑预演、红蓝对抗、实现预演逐层找破口。只要出现异常，就先由主 agent 核实，给出方案；必要时问开发者，再回写 PRD 或计划，然后重新进入预演。

[看与 Superpowers 的对比](#sandtable-vs-superpowers) · [立刻试用](#quickstart)

## Why Sandtable
一个词：**推演**。打仗不会拿真人命去试错，先在沙盘上把仗打几遍；改代码也一样，落地前先把方案推演穿。

Sandtable 让 agent 用三种推演逐层逼出破口，全程落盘可续：

- **头脑预演**：只读推演逻辑，问“这套方案到底通不通”。
- **红蓝对抗**：红军 OPFOR 专攻找**可复现杀招**，问“能不能被打破”。
- **实现预演**：多个隔离 worktree 真改代码，问“做出来对不对”，再复盘择优。

> 三种推演任一发现异常，立即停、回写文档、修正计划、再重演——破口在落地前暴露，而不是上线后炸。

## 自举证明
这个仓库不是“写给别人照做”的文档仓。当前仓库自己就在 `docs/sandtable/` 里记录 feature 目标、测试、计划、推演和回退修正，用同一套方法继续打磨 `README`、命令和 skill。

## Quickstart
1. 无需 clone 本仓库，把下面两条官方提示词之一**原样**发给你的 AI，让它自己去读统一的安装说明并按该提示词语言安装对应本地资产：

   中文：

   > 阅读 https://github.com/andoop/sandtable/blob/main/INSTALL.md ，并据此按中文把 Sandtable 安装进当前项目。

   English:

   > Read https://github.com/andoop/sandtable/blob/main/INSTALL.md and use it to install Sandtable into the current project in English.

2. 按 AI 的安装结果完成最后接线；若它提示重载窗口、重开工作区或启用本地插件以使规则生效，就照做。
3. 按工具选择命令入口：
   - Cursor：通过 `.cursor/commands` 提供 slash 命令，使用 `/sandtable-start` 开始。
   - Codex：通过 `plugins/sandtable` 与 `.agents/plugins/marketplace.json` 提供本地 Sandtable plugin；先用 `codex plugin marketplace add "$PWD"` 和 `codex plugin add sandtable --marketplace sandtable-local` 注册/启用后，优先尝试 `/sandtable:sandtable-start`。Codex 当前版本是否在 `/` 菜单展示本地插件命令取决于客户端能力；不把 Cursor 的裸 slash 自动提示当作 Codex 保证。
   - Claude Code / Kiro / 通用 agent：没有专属 slash 接线时，把 `/sandtable-start` 作为普通消息发给 AI，让它按 `AGENTS.md` 与 `commands/sandtable-start.md` 执行。

手工安装、不同 AI 工具（Cursor / Claude Code / Codex / Kiro 等）的差异、以及本地试用路径，都写在 `INSTALL.md`，README 不再展开。`.cursor/commands` 只服务 Cursor；Codex 的命令入口来自 Sandtable Codex plugin，不承诺自动发现 Cursor 命令。

## 命令入口
- `/sandtable-start`: 从一句话需求进入前五步，收束到侦察、目标、用例和计划。
- `/sandtable-autopilot`: 按配额自动推进 `RECON -> ... -> EVALUATE`，真阻塞才停。
- `/sandtable-mental`: 只读推演逻辑闭环。
- `/sandtable-redteam`: 红军 OPFOR 找可复现破口。
- `/sandtable-live`: 在隔离 worktree 做实现预演。
- `/sandtable-debrief`: 给多个实现预演打分择优。
- `/sandtable-rehearse`: 串联图上作业、红蓝对抗、实现预演和复盘。
- `/sandtable-resume`: 按 `state.md` 与 `journal.md` 恢复现场继续。
- `/sandtable-status`: 查看阶段、任务、推演结果和未决问题。

## Sandtable vs Superpowers
[Superpowers](https://github.com/obra/superpowers) 是一套优秀的、被广泛使用的 agent 方法论，Sandtable 与它同源同宗：都不让 agent“看见需求就开写”，都用自动触发的 skill、都在隔离 worktree 里干活、都把设计落盘。

一句话区别：**Superpowers 的隐喻是“给 agent 装上超能力”，先想清楚、再用 TDD 红绿灯把代码写对；Sandtable 的隐喻是“打仗前先在沙盘上推演”，先把仗在图上打几遍、把破口在落地前逼出来，再择优出兵。** 一个偏“把代码写对”，一个偏“把方案打穿”。

| 维度 | 🦸 Superpowers | 🪖 Sandtable |
| --- | --- | --- |
| **核心隐喻** | 给 agent 装上超能力的技能库 | 落地前的沙盘 / 兵棋推演 |
| **需求收敛** | `brainstorming` 苏格拉底式追问，产出 design doc | `RECON` 侦察 + `OBJECTIVES` 红线（MUST/MUST-NOT）+ `TESTCASES` 黑盒用例，把“AI 以为自己懂了”变成人能核对的闸门 |
| **质量怎么保证** | 事中事后：TDD 红绿重构 + `requesting-code-review` 任务间评审 | 落地前置：头脑预演问逻辑通不通、`REDTEAM` 红军 OPFOR 专攻找**可复现杀招**，破口在写代码前就暴露 |
| **隔离执行** | `using-git-worktrees` + `subagent-driven-development` 单条流水线逐任务推进 | 实现预演在多个隔离 worktree **并行跑同一需求**，再 `/sandtable-debrief` 打分**择优（best-of-N）** |
| **过程留痕** | 设计文档存 `docs/superpowers/specs/` | 整条状态机落盘 `docs/sandtable/`：目标、用例、计划、`state.md`、`journal.md`、`questions.md` |
| **断了能续吗** | 首页未把中断恢复作为核心卖点 | `/sandtable-resume` 按磁盘状态接防，换人、换 AI、异常退出都能续上，不靠翻聊天记录 |
| **异常如何处理** | 评审/测试发现问题再修 | 任一推演喊出 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED` 立即终止，回写文档、修正计划，再重演 |

**怎么选**：想要一套成熟、社区庞大、强 TDD 纪律的通用方法论，选 Superpowers。需求模糊、改动高危、一旦做错代价大、且希望“先把仗在沙盘上打穿、过程可追溯可续接”——Sandtable 的推演闭环正是为此而生。两者并不互斥：Superpowers 把代码写对，Sandtable 把方案打穿。

## 目录结构
```text
sandtable/
  README.md
  AGENTS.md / CLAUDE.md
  .cursor/rules/sandtable.mdc
  .cursor/commands/*.md
  commands/*.md
  .agents/plugins/marketplace.json
  plugins/sandtable/
    .codex-plugin/plugin.json
    commands/*.md
    skills/**
  hooks/
  skills/
    autonomous-orchestration/
    mental-rehearsal/
    red-team-wargame/
    implementation-rehearsal/
    state-and-memory/
    ... more skills
  templates/
```

运行时会在目标项目生成:

```text
docs/sandtable/
  project.md
  constraints.md
  features/<date-slug>/
    prd.md  tests.md  plan.md  state.md  journal.md  questions.md
    rehearsals/
```

## 四条底线
1. **不猜测、不捏造**: 不清楚的事先读代码、读文档、问开发者。
2. **先思考再动手**: 假设要显式写出，多解要摆出来。
3. **外科手术式改动**: 不兜底、不节外生枝、每行都可追溯到需求。
4. **目标驱动**: 每一步都要能映射到可验证的成功标准。

## License
MIT
