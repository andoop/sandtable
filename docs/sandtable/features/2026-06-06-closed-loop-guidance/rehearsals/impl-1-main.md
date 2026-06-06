# IMPL_REHEARSAL · 主工作区落地（autopilot 单候选）

**信号：`DONE`**（主 agent 抽查）

**说明**：本回合 autopilot 在配额未完全闭包前将实现直接落于 `sandtable/` 主工作区（未建独立 worktree）。作为唯一候选择优。

## 已实现

| 任务 | 文件 |
|------|------|
| T1 | `skills/closing-the-loop/SKILL.md` + `plugins/sandtable/skills/closing-the-loop/` |
| T2 | `using-sandtable`、`state-and-memory`、`sandtable.mdc`、`AGENTS.md` |
| T3 | 13×`commands/` + `.cursor/commands/` + `plugins/sandtable/commands/`；start/rehearse/autopilot/status 专项 |
| T4 | `locales/en/skills/closing-the-loop/`、en rules/AGENTS、39 en commands 收尾 |

## 抽查

- `commands/` 与 `plugins/sandtable/commands/` diff 无差异
- 中文 13 commands 均含 `closing-the-loop`
- en `closing-the-loop` skill 含 Full close / Status bulletin 结构

## 残余

- autopilot 硬配额（mental×3、redteam×3、impl×2 worktree）本回合未完全闭包
- en commands 除 start 外正文仍为历史英文+追加尾注（未全文翻译 start 以外专项句）
