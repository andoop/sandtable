# Mental 31 Report

**Status:** `ANOMALY_FOUND`

## Scope

复核 redteam-20 / RT20-B66 修正后的 `prd.md`、`tests.md`、`plan.md`、`journal.md`、`state.md`，重点检查 T1/T2 autopilot/resume 编排层是否已把“本回合明确确认”绑定到证据持久化。

## Result

2 个只读 mental 子 agent 返回分歧：一路 `LOGIC_CLOSED`，一路 `ANOMALY_FOUND`。主 agent 核实后确认 anomaly 成立。

## Anomaly

### M31-A1: T1 步骤3 仍保留“本回合明确确认即可继续 TESTCASES”的弱表述

**问题:**

T1 步骤2.5 与步骤7 已要求本回合明确确认必须先/同时持久化到 `state.md` 或 `journal.md`，但 T1 步骤3 中针对 `autonomous-orchestration` 步骤3.5 的改写仍写作“只有本回合已明确确认 PRD 才允许继续 TESTCASES”，未重复绑定持久化责任。

**影响:**

实现者若按步骤3 改 `autonomous-orchestration`，可能再次复现 RT20-B66：autopilot 同条确认后写 `tests.md`，但不落盘证据，下一回合 resume/autopilot 缺可核实确认。

**修正:**

T1 步骤3 改为：本回合已明确确认 PRD 时，必须先/同时把可核实确认证据持久化到 `state.md` 或 `journal.md`，才允许继续 TESTCASES。

## Held

- T1 步骤2.5/7、T2 步骤3/6、TC14 已承接 autopilot/resume 同条确认落盘。
- RT16 完整性闸门、T7/T8、文档链入口、close-loop 已选择即续跑未发现新 anomaly。

## Next

已修正 `plan.md`。重新运行 mental；闭环后再运行 redteam。
