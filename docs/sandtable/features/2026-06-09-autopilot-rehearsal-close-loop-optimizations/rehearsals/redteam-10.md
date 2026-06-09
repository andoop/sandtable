# Redteam 10 Report

**Status:** `BREACH_FOUND`

## Scope

mental-16 闭环后复攻 `plan.md`，重点检查：

- T1/T2/T5/T6: PRD-AC、MUST/MNOT、live TODO 键粒度、覆盖矩阵/TODO/evaluating/rehearse/debrief/autopilot/resume 一致性。
- T3/T4/T7/T8: resume OBJECTIVES→TESTCASES、start 同回合 AskQuestion、refine/resume 确认续跑、using-sandtable 注入层、真实问题/攻破口径、镜像同步。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

1 个红军子 agent 返回 `HELD`，1 个返回 `BREACH_FOUND`。主 agent 核实后确认一条真实计划破口，已修正 `plan.md`。

## Breach

### RT10-B42: 文档齐备度检查绕过 PRD 未确认门禁

**复现路径:**

1. `/sandtable-start` 写完 `prd.md`，`state.phase=OBJECTIVES`，PRD 尚未获开发者确认。
2. 用户不确认 PRD，直接触发 `/sandtable-resume` 或 `/sandtable-autopilot` 续接。
3. T1/T2 原文只看文档齐备度：有 `prd.md` 但缺 `tests.md` → 进入 TESTCASES。
4. PRD 未确认却写 `tests.md`，打穿 TC14 和 PRD 非目标。

**打穿:** TC14、FR7 命令边界、PRD 非目标、`writing-prd` 确认门禁。

**修正:**

- T1 步骤2.5：PRD 确认门禁优先于文档齐备度；`phase=OBJECTIVES` 且 `prd.md` 已存在但本回合未明确确认 PRD 时，停在 PRD 确认点，不得进入 TESTCASES。
- T1 步骤7 `/sandtable-autopilot`：续接但文档未齐备时，若 PRD 未确认必须先停在确认点。
- T1 验证：拆分为“PRD 未确认仅有 `prd.md` → resume/autopilot 停在确认点”和“PRD 已确认仅有 `prd.md` → 补写 `tests.md`”。
- T2 步骤3/6：state 恢复和 `/sandtable-resume` 先检查 PRD 确认门禁，再检查文档齐备度。
- T2 验证：同样拆分 PRD 未确认与已确认场景。

## Held

- T1/T2/T5/T6 的 PRD-AC、MUST/MNOT、live TODO 键粒度和四路径二次校验已守住。
- R9-B41 live TODO 聚合键破口已闭合。
- resume `phase=OBJECTIVES` + PRD 已确认 → TESTCASES 路径已闭合；本轮修的是 PRD 未确认的负向门禁。
- `/sandtable-start` 同回合 AskQuestion 续跑、refine/resume 确认续跑、using-sandtable 注入层、T3/T4 真实口径和 T8 镜像同步未发现新的计划层破口。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
