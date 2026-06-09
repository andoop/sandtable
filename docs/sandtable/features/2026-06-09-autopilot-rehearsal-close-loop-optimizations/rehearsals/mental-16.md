# Mental Rehearsal 16 Report

**Status:** `LOGIC_CLOSED`

## Scope

redteam-9 修正后复核 `plan.md`，重点确认：

- R9-B41: live TODO 表是否禁止聚合 `MUST/MUST NOT`，改用 `MUST-x` / `MNOT-x` 逐条稳定键。
- 覆盖矩阵与 live TODO 表是否在 FR、PRD-AC、MUST/MNOT、TC、PLAN 键集合上逐项对应。
- 最近几轮破口（PRD-AC、MUST/MNOT、四路径二次校验、resume/start 续跑、using-sandtable 注入层）是否有新的计划矛盾。

## Subagent Results

- `Mental r9 todo`: `LOGIC_CLOSED`。T5 步骤5 已强制逐条键并禁止聚合键；矩阵与 TODO 在全键集合上对应。
- `Mental r9 overall`: `LOGIC_CLOSED`。近期破口均已闭合，未发现新的计划层矛盾。

## Verified Closed

- T5 live TODO `项` 限定为 `PRD FRx`、`PRD-ACx`、`MUST-x`、`MNOT-x`、`TCx`、`PLAN Tx/步骤x`。
- 聚合 `MUST/MUST NOT`、`全部红线` 等摘要键被明确禁止。
- 覆盖矩阵与 live TODO 表在 PRD FR、PRD-AC、MUST/MNOT、TESTS TC 键集合上一一对应；缺键或聚合替代逐条键按 `missing` 处理。
- PLAN 步骤粒度对应规则仍保留，覆盖 `T7/步骤6.6` 等小数编号。
- T1/T2/T5/T6 四路径二次校验仍包含 PRD-AC、MUST/MNOT、TC、PLAN 键集合和正文 hash。

## Residual Notes

- 源文件仍为旧文案，属于 implementation rehearsal 待落地内容；计划层已覆盖。
- 顶部文件地图有重复条目，但任务级清单与 T8 规则约束实现范围，不构成逻辑破口。

## Next

进入 redteam 复攻；若守住，则进入 implementation rehearsal。
