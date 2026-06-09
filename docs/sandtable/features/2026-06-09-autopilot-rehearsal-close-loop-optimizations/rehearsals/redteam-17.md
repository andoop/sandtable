# Redteam 17 Report

**Status:** `BREACH_FOUND`

## Scope

mental-25 闭环后整体复攻当前 `prd.md`、`tests.md`、`plan.md`，重点：

- PRD 未确认门禁与证据防伪。
- 文档链 `/sandtable-plan` / refine / `writing-tests` / `writing-plan`。
- T7/T8 镜像同步。
- live 完整性闸门。
- 已确认续跑。

只接受真实可复现、会影响最终实现或验收的破口。

## Result

2 个红军子 agent 返回分歧：一路 `HELD`，一路 `BREACH_FOUND`。主 agent 核实后确认 `BREACH_FOUND` 成立，问题落在 PRD 确认证据格式。

## Breach

### RT17-B63: AskQuestion 确认证据格式不闭合，弱表述与严格表述冲突

**复现路径:**

1. `/sandtable-start` 写完 `prd.md` 后，开发者尚未确认。
2. agent 自写 journal：时间戳 + “开发者选择认可 PRD” + “来源: AskQuestion 答复”，但没有 AskQuestion answer id 或 source id。
3. 若实现者按 T2 步骤3 的弱表述实现，“确认时间”或“AskQuestion 答复”可能被当作有效确认，TC14 被绕过。
4. 若实现者按 T1/T7 的严格表述实现，则当前 feature 早期旧记录“AskQuestion 答复”会被拒绝，可能误杀真实 PRD 已确认后的合法续接。

**修正:**

- PRD FR7、验收标准、MUST 统一证据标准：
  - AskQuestion 确认必须记录 answer id 或 `source: askquestion:<id>`。
  - 自然语言确认必须记录用户原话摘录、确认时间和用户消息来源。
  - 仅写“AskQuestion 答复”、只有确认时间、agent 自写 journal/state 均不得绕过 PRD 确认门禁。
- TC12 正向要求 AskQuestion 选择后记录 answer id 或 `source: askquestion:<id>` + 选项原文/确认时间。
- TC14 负向加入“仅写 AskQuestion 答复但无 id”和“只有确认时间”。
- T1/T2/T7 相关步骤统一为同一证据标准，并删除“确认时间”可单独成立的弱口径。
- 补记当前 feature 的真实 PRD 确认证据：用户在 2026-06-09 11:21 AM (UTC+8) 发送自然语言确认原话，来源为 user-message / transcript line 25。

## Held

- RT16-B57/B58 完整性闸门守住。
- RT15-B56 T7 文件清单守住。
- `/sandtable-plan` / refine / `writing-tests` / `writing-plan` 文档链门禁未发现新破口。
- T7/T8 镜像同步、已确认续跑、冷启动 autopilot 设计边界未发现新破口。

## Next

已修正 `prd.md`、`tests.md`、`plan.md`、`journal.md`。重新运行 mental；闭环后再运行 redteam。
