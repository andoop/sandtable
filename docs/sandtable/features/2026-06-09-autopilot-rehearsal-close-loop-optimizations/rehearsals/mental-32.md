# Mental 32 Report

**Status:** `ANOMALY_FOUND`

## Scope

复核 mental-31 / RT20-B66 修正后的 `prd.md`、`tests.md`、`plan.md`、`journal.md`、`state.md`。

重点：

- T1/T2 autopilot/resume 编排层是否已把本回合 PRD 确认绑定到证据持久化。
- 手动 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live`、`/sandtable-rehearse`、`/sandtable-debrief` 是否也承接同条确认落盘。

## Result

2 个只读 mental 子 agent 返回分歧：一路 `LOGIC_CLOSED`，一路 `ANOMALY_FOUND`。主 agent 核实后确认 anomaly 成立。

## Anomaly

### M32-A1: 手动推演/live 入口未绑定同条 PRD 确认落盘责任

**问题:**

T1/T2 已要求 autopilot/resume 同条 PRD 确认先/同时落盘，但 T3/T4/T6 手动入口只写了“无可核实记录则停”，没有写“本回合消息同时确认 PRD 时，先/同时持久化证据再派发 mental/redteam/live/rehearse/debrief”。

**影响:**

实现者可能在 `/sandtable-mental PRD 已确认，请开始推演` 等同条消息场景中，要么把口头确认当作可核实直接派发但不落盘，导致下回合缺证据；要么严格因无历史记录而误杀已确认续跑。该问题打穿 FR7/MUST 在手动推演入口的承接。

**修正:**

- T3 步骤5.5：`/sandtable-mental` 同条 PRD 确认时，派发前或同时写入 `state.md` 或 `journal.md`，并新增验证场景。
- T4 步骤5.5：`/sandtable-redteam` 同条 PRD 确认时，派发前或同时写入 `state.md` 或 `journal.md`，并新增验证场景。
- T6 步骤1/2/3：`/sandtable-live`、`/sandtable-rehearse`、`/sandtable-debrief` 同条 PRD 确认时，进入实现/推演/评分前或同时写入 `state.md` 或 `journal.md`，并新增验证场景。

## Held

- T1/T2 本回合确认落盘责任已闭环。
- PRD/tests/T7 close-loop 证据链、T7/T8 镜像、RT16 完整性闸门未发现新 anomaly。

## Next

已修正 `plan.md`。重新运行 mental；闭环后再运行 redteam。
