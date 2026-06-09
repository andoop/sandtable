# Mental Rehearsal 17 Report

**Status:** `ANOMALY_FOUND`

## Scope

redteam-10 修正后复核 `plan.md`，重点确认：

- RT10-B42: PRD 未确认门禁是否优先于 T1/T2 文档齐备度。
- 已确认续跑、文档齐备度补齐、resume/autopilot、start/refine/closing-the-loop 是否无新冲突。

## Subagent Results

- `Mental r10 confirm`: `ANOMALY_FOUND`。T1/T2 已写清 PRD 确认门禁，但 T1 未明确改写 `/sandtable-autopilot` 命令步骤7 中“各阶段之间不等待用户确认；同一命令内继续执行”的旧 blanket 条款。
- `Mental r10 overall`: `LOGIC_CLOSED`。除上述命令步骤7旧条款外，PRD 未确认门禁、已确认续跑、文档齐备度和 close loop 之间逻辑一致。

## Anomaly

### A21: autopilot “不等待/同命令继续”旧条款未为 PRD 未确认门禁加例外

**问题:**

T1/T2 已要求 `phase=OBJECTIVES`、`prd.md` 已存在但 PRD 未确认时，resume/autopilot 必须停在 PRD 确认点。但 `/sandtable-autopilot` 旧命令步骤仍有“各阶段之间不等待用户确认；同一命令内继续执行”的 blanket 表述，若不显式改写，会压过 PRD 未确认门禁并复现 RT10-B42。

**修正:**

- T1 步骤3 补充：收窄自动编排中“不等待开发者确认/同一命令继续”的 blanket 表述；冷启动文档链可自动推进，但续接命中 PRD 未确认门禁时必须停在确认点。
- T1 步骤7 补充：六份 `/sandtable-autopilot` 命令必须改写步骤7 的旧条款；续接当前 feature 且 PRD 未确认时结束本命令并等待确认，本回合已确认 PRD 时才可继续 TESTCASES。

## Closed Items

- T1/T2 文档齐备度已区分 PRD 未确认与已确认。
- T7 start/refine/resume 已确认续跑规则仍闭环。
- T5/T6 完整性闸门与近期 PRD-AC、MUST/MNOT、TODO 键粒度修正未受影响。

## Next

重新运行 mental；闭环后再运行 redteam。
