# Mental Rehearsal 21 Report

**Status:** `ANOMALY_FOUND`

## Scope

redteam-13 修正后复核 `plan.md`，重点确认：

- RT13-B50: 手动推演/live 入口是否接入 PRD 未确认门禁。
- RT13-B47/B48: PRD 确认证据是否绑定真实开发者输入，agent 伪造原话或自设 state 字段是否按未确认处理。

## Subagent Results

- `Mental r13 manual`: `LOGIC_CLOSED`。手动 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live`、`/sandtable-rehearse`、`/sandtable-debrief`、T7 已选路径和 refine 续推演均已接入 PRD 未确认门禁。
- `Mental r13 evidence`: `ANOMALY_FOUND`。规则层基本闭环，但 PRD/tests 黑盒闸门未承接证据绑定与防伪；T1/T7 验证未完全覆盖伪造原话和自设 state 确认字段。

## Anomaly

### A22: PRD/tests 未承接 PRD 确认证据防伪

**问题:**

PRD 没有明确“PRD 确认必须绑定开发者输入，agent 自写 journal/state 不得伪造成确认”；TC14 只覆盖 `/sandtable-start` 未确认停点，没有覆盖 resume/autopilot/manual 续接时的伪造 journal/state 负向场景。

**修正:**

- PRD FR7 增加可核实确认要求：AskQuestion 选择或用户确认原话等开发者来源才算确认；agent 自写 journal、`autonomy.last_decision`、`phase` 变化或无来源 state 字段不算。
- PRD 验收标准与 MUST 增加 PRD 确认证据防伪要求。
- TC14 扩展：resume/autopilot/manual 续接时，只有可追溯到开发者输入的确认记录才算确认；agent 自写 journal、伪造用户原话、`phase` 变化、自设 state 字段都不得绕过确认点。
- T1/T7 验证补齐伪造“用户确认原话摘录”和自设 `state.md prd_confirmed=true` / `confirmed_by: developer` 的负向场景。

## Closed Items

- 手动推演/live 入口 PRD 门禁闭环。
- T2 的 state/journal 恢复信任例外闭环。

## Next

重新运行 mental；闭环后再跑 redteam。
