# Mental Rehearsal 15 Report

**Status:** `LOGIC_CLOSED`

## Scope

redteam-8 修正后复核 `plan.md`，重点确认：

- R8-B39: MUST/MUST NOT 是否拥有稳定键并进入结构化基准、覆盖矩阵、live TODO、T1/T2/T5/T6 四路径二次校验和验证场景。
- R8-B40: `/sandtable-resume` 在 `phase=OBJECTIVES` 且 PRD 已确认时是否明确直接写 `tests.md`，不重进 `writing-prd`。

## Subagent Results

- `Mental r8 must`: `LOGIC_CLOSED`。`MUST-*` / `MNOT-*` 已纳入结构化基准、覆盖矩阵、TODO 规则、四路径二次校验与验证场景。
- `Mental r8 resume`: `LOGIC_CLOSED`。T7 步骤6.6 明确 `phase=OBJECTIVES` + PRD 确认时直接 `writing-tests`；验证覆盖 resume 场景。

## Verified Closed

- T5 结构化核对基准定义了 `MUST-1...MUST-n`、`MNOT-1...MNOT-n` 稳定键和正文 hash。
- T5 覆盖矩阵新增 `PRD 红线覆盖`，不得由 FR、PRD-AC 或 TC 间接替代。
- T1/T2/T5/T6 四路径二次校验包含 MUST/MUST NOT 键集合和正文 hash。
- T5/T6 验证覆盖基准一致但缺 `MUST-2` 或 `MNOT-1` 的拦截场景。
- T7 resume 语义补齐：`phase=OBJECTIVES`、`prd.md` 已存在、用户确认 PRD 并要求写 tests 时，续跑目标视为 TESTCASES，直接加载 `writing-tests`。

## Residual Notes

- 源文件仍为旧文案，属于 implementation rehearsal 待落地内容；计划层已覆盖。

## Next

进入 redteam 复攻；若守住，则进入 implementation rehearsal。
