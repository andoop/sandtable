# Sandtable · 沙盘推演驱动开发

> 把一句简单描述或一份粗糙需求，做成开发者**真正想要**的功能——逻辑闭环、产品闭环、细节完美。
>
> 手段是一个不断加固的循环：**计划 → 预演 → 发现问题 → 修正计划 → 再预演**，直到所有预演顺利，再择优落地。

Sandtable 是一套给 coding agent 用的开发方法论插件，由一组可组合的 skill + slash 命令 + 持久状态机组成。它吸收了 [Andrej Karpathy 的反 LLM 坏习惯四原则](https://x.com/karpathy/status/2015883857489522876) 与 [superpowers](https://github.com/obra/superpowers) 的子 agent 编排思想，并新增了**三类推演（头脑预演/红蓝对抗/实现预演）+ 持久记忆 + 异常驱动的修正循环**。

## 核心特性

- **实事求是，不猜测、不捏造**：不清楚的事通过读代码、读文档、问开发者弄清，并写回 PRD/计划。
- **目标 / PRD / 计划 / 红线全留痕**：北极星目标、MUST/MUST-NOT 红线、PRD、改动计划。
- **状态机 + 追加式记忆**：过程持久化到 `docs/sandtable/`，**换人、换 AI、异常退出都能用 `/sandtable-resume` 续上**。
- **两种预演**（核心）：
  - **头脑预演** —— 只读，推演整条逻辑链是否闭环、无漏洞、无意料之外的影响，不做兜底、不节外生枝。
  - **实现预演** —— 在隔离 git worktree 里真改代码、完整实现并验证。
- **子 agent 并行 + 异常即停**：每个预演在独立子 agent 里跑，可并行多个；任一发现意料之外立即终止上报。
- **择优落地**：全部预演顺利后，按客观评分表选分数最高的实现集成。

## 闭环

```
INTAKE → CLARIFY → PRD → PLAN → MENTAL_REHEARSAL → IMPL_REHEARSAL → EVALUATE → INTEGRATE → VERIFY → DONE
        ↑___ 任一预演发现异常/意外 → 主 agent 亲自核实 → 问开发者 → 修正 PRD/计划 → 重演 ___↑
```

## 安装 / 接入

### Cursor（推荐）

把本目录的内容并入你的项目（或拷贝相应文件）：

- `.cursor/rules/sandtable.mdc`（`alwaysApply: true`）——方法论自动生效。
- `.cursor/commands/*.md`——提供 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-status`、`/sandtable-resume` 四个命令。
- `skills/`、`templates/`——技能与模板，按需被读取。

最简单：把 `sandtable/` 整个目录放进项目根，或把 `.cursor/`、`skills/`、`templates/` 拷到你的项目根。

快速初始化运行时目录：在目标项目根运行 `bash scripts/sandtable-init.sh <slug> [date]`，从 `templates/` 脚手架出 `docs/sandtable/`（slug 用 kebab-case）。

### Claude Code / Codex / 其他

- 作为插件：本目录含 `.claude-plugin/plugin.json`、`hooks/`（会话启动注入 `using-sandtable`）、`commands/`、`skills/`。
- 通用：把 `AGENTS.md`（`CLAUDE.md` 指向它）并入你的指令文件即可获得行为基线。

## 用法 · 命令即战术动作

每个命令是一个独立的战术动作，可单独触发、反复迭代，无需一次跑完整条流程。

| 命令 | 军事隐喻 | 作用 |
|------|---------|------|
| `/sandtable-start` | 受领任务 | 一键编排：侦察→目标→计划（从一句话或产品文档开始）|
| `/sandtable-recon` | 战场侦察 | 主动收集代码/文档情报、列未知、自主提问 |
| `/sandtable-objectives` | 指挥官意图 | 定目标、MUST/MUST-NOT、红线、验收标准 |
| `/sandtable-plan` | 作战计划 | 制定/重制细到可执行的改动计划 |
| `/sandtable-refine` | 调整部署 | 据我反馈反复修改/重制想法、目标或计划 |
| `/sandtable-mental` | 图上作业 | 头脑预演：只读推演逻辑闭环（不动一兵一卒）|
| `/sandtable-redteam` | 红蓝对抗 | 红军 OPFOR 专攻找破绽（脑洞核心）|
| `/sandtable-live` | 实兵演习 | 实现预演：隔离 worktree 真改代码 |
| `/sandtable-debrief` | 战损复盘 | 多个实现预演打分择优 |
| `/sandtable-rehearse` | 总演习 | 一键串起 图上→红蓝→实兵→复盘 |
| `/sandtable-status` | 战报 SITREP | 查看状态机/任务/推演结果/未决问题 |
| `/sandtable-resume` | 接防换防 | 换人换 AI / 异常退出后恢复记忆继续 |

### 三类推演三位一体

> "推演"是统称，含三类：头脑预演、红蓝对抗、实现预演。

- **头脑预演** 问："逻辑通不通？"——只读推演整条链路是否闭环。
- **红蓝对抗** 问："能不能被打破？"——红军唯一使命是击溃方案，每记可复现的杀招都是一个待修正的 anomaly。
- **实现预演** 问："做出来对不对？"——隔离 worktree 真打一遍，完整实现不留细节。

任一暴露异常，都走同一条 **核实 → 问开发者 → 修正计划 → 重演** 循环，直到全线通过再复盘择优落地。

## 目录结构

```
sandtable/
  README.md
  AGENTS.md / CLAUDE.md           # 行为基线（四底线 + 闭环 + 预演铁律）
  .claude-plugin/plugin.json      # Claude Code 插件清单
  .cursor-plugin/plugin.json      # Cursor 插件清单
  .cursor/rules/sandtable.mdc     # Cursor alwaysApply 规则
  .cursor/commands/*.md           # Cursor slash 命令
  commands/*.md                   # 插件 slash 命令（Claude/通用）
  hooks/                          # 会话启动注入 using-sandtable
  skills/
    using-sandtable/              # 总入口：理念、状态机、触发规则
    being-truthful/               # 实事求是 / 不猜测的硬门禁
    state-and-memory/             # 状态机 + 持久记忆（换人换AI可续）
    gathering-intel/              # 战场侦察：主动收集情报、列未知
    writing-prd/                  # 目标、PRD、红线
    writing-plan/                 # 细到可执行的改动计划
    mental-rehearsal/             # 头脑预演（图上作业）+ 子agent prompt
    red-team-wargame/             # 红蓝对抗 OPFOR + opfor prompt
    implementation-rehearsal/     # 实现预演（实兵演习）+ 子agent prompt
    evaluating-rehearsals/        # 战损复盘：评分与择优
  templates/                      # project/constraints/prd/plan/state/journal/questions 模板
```

运行时在目标项目生成的工作目录：

```
docs/sandtable/
  project.md            # 北极星目标
  constraints.md        # 全局红线 MUST/MUST-NOT
  features/<日期-slug>/
    prd.md  plan.md  state.md  journal.md  questions.md
    rehearsals/         # 各次头脑/实现预演报告 + 评分
```

## 四条不可违背的底线

1. **不猜测、不捏造，实事求是。**
2. **先思考再动手**（显式假设、多解都摆、有更简单方案就说）。
3. **外科手术式改动**（不兜底、不节外生枝、每行可追溯）。
4. **目标驱动**（可验证成功标准，循环到通过）。

> 违反规则的字面，就是违反规则的精神。"太简单不用走流程"是最危险的合理化。

## License

MIT
