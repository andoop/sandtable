# Redteam 13 Report

**Status:** `BREACH_FOUND`

## Scope

mental-20 闭环后复攻 `plan.md`，重点检查：

- PRD 确认证据链、`phase` 不作为确认代理、agent 自写 journal 不算确认。
- state/journal 恢复、autopilot/resume/start/refine/closing-the-loop 优先级。
- TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

2 个红军子 agent 均返回 `BREACH_FOUND`。主 agent 核实后归并为两类真实计划破口，已修正 `plan.md`。

## Breaches

### RT13-B50: 手动推演/live 入口绕过 PRD 未确认门禁

**复现路径:**

1. 三文档已存在，但 PRD 没有可核实开发者确认。
2. 用户手动触发 `/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live`，或在 `/sandtable-refine` 中说“plan 已确认，继续推演”。
3. T1/T2 已拦 autopilot/resume，但 T3/T4/T6/T7 手动入口没有同等 PRD 门禁。
4. 未确认 PRD 仍进入 MENTAL/REDTEAM/IMPL，打穿 TC14。

**修正:**

- T3 `/sandtable-mental` 六镜像、T4 `/sandtable-redteam` 六镜像新增 PRD 确认门禁。
- T6 `/sandtable-live`、`/sandtable-rehearse`、`/sandtable-debrief` 六镜像新增 PRD 确认门禁。
- T7 已选择路径优先规则排在 PRD 未确认门禁之后；手动选择推演/live 不能跳过 PRD 确认，除非该选择本身就是 PRD 明确确认。
- T7 refine 阶段续跑补充：tests/plan 已确认继续前必须先满足 PRD 确认门禁。
- 验证新增三文档存在但 PRD 未确认时，手动推演/live/refine 续推演均不得进入后续阶段。

### RT13-B47/B48: PRD 确认证据可被 agent 伪造

**复现路径:**

1. 用户从未确认 PRD。
2. agent 在 `journal.md` 写伪造“用户确认原话摘录”，或在 `state.md` 自设 `prd_confirmed: true` / `confirmed_by: developer`。
3. resume/autopilot 读取这些字段后误判 PRD 已确认。

**修正:**

- 可核实确认必须来自可追溯开发者输入事件：AskQuestion answer id，或真实用户消息的确认原话 + 确认时间 + 来源消息。
- `state.md` 的 `prd_confirmed` / `confirmed_by: developer` 只能在同一回合收到真实确认时写入，并必须引用该来源。
- agent 无对应用户输入时伪造原话、自设确认字段，按未确认处理。
- T1/T2/T7 验证新增伪造 journal、agent 自设 state 确认字段的负向场景。

## Held

- RT12-B45/B46 的基础门禁在 autopilot/resume 路径上守住。
- PRD-AC、MUST/MNOT、live TODO 键粒度、四路径二次校验与完整性闸门未被攻破。
- 镜像同步、T3/T4 真实问题/攻破口径未发现其他计划层破口。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
