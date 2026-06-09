# Mental Rehearsal 20 Report

**Status:** `LOGIC_CLOSED`

## Scope

redteam-12 修正后复核 `plan.md`，重点确认：

- RT12-B45: `phase>=TESTCASES` 不再作为 PRD 已确认代理。
- RT12-B46: agent 自写 journal/`autonomy.last_decision` 不算 PRD 确认，PRD 确认必须有开发者来源。
- PRD 确认证据链、PRD 未确认门禁、已确认续跑、journal/state 恢复、autopilot/resume/start/refine/closing-the-loop 优先级是否无新冲突。

## Subagent Results

- `Mental r12 evidence`: `LOGIC_CLOSED`。T1/T2/T7 统一规定可核实 PRD 确认只能来自开发者输入；T2 步骤3.5 为 journal 信任规则加 PRD 确认硬例外。
- `Mental r12 overall`: `LOGIC_CLOSED`。redteam-12 两条破口在计划层已闭合，RT11 门禁未被削弱。

## Verified Closed

- `phase>=TESTCASES`、agent 自写 journal、`autonomy.last_decision` 均不得单独算作 PRD 已确认。
- 可核实 PRD 确认必须包含开发者来源：AskQuestion answer id、用户确认原话、确认时间，或等价 `prd_confirmed` / `confirmed_by: developer` 字段。
- `state-and-memory` 的 “journal 记过就按记的来” 原则为 PRD 确认加硬例外。
- `writing-prd` 收到确认时必须写入可核实证据。
- 负向验证覆盖：仅有 agent 自写 journal “PRD 已确认” 时，resume/autopilot 仍停 PRD 确认点。

## Next

进入 redteam 复攻；若守住，则进入 implementation rehearsal。
