# Redteam 15 Report

**Status:** `BREACH_FOUND`

## Scope

mental-23 后复攻 RT14-B55 修正，重点攻击：

- `/sandtable-plan`、refine、`writing-tests`、`writing-plan` 是否真的进入 T7 任务文件清单和镜像核对范围。
- PRD 未确认门禁、防伪、manual/live/autopilot/resume、完整性闸门是否仍可绕过。

只接受真实可复现破口；措辞偏好和无实际执行路径的风险不计入 breach。

## Result

2 个红军子 agent 返回分歧：一路 `BREACH_FOUND`，一路 `HELD`。主 agent 亲自核实后确认 breach 成立：此前修正补进了顶部文件地图与 T7 步骤，但未补进 T7 自身 `文件:` 清单；由于 T8 明确以任务级文件列表为准，这会导致实现阶段漏改文档链入口。

## Breach

### RT15-B56: T7 任务文件清单未列 `/sandtable-plan` 与 `writing-tests` / `writing-plan`

**复现路径:**

1. PRD 未确认，用户直接触发 `/sandtable-plan` 或通过 refine 要求修改 tests/plan。
2. 计划步骤6.7 要求为这些入口补 PRD 门禁，但 T7 `文件:` 清单未列对应 14 个镜像文件。
3. 实现 agent 按任务级文件清单施工，漏改 `/sandtable-plan` 六镜像、`writing-tests` 四镜像、`writing-plan` 四镜像。
4. 未确认 PRD 仍可写入 `tests.md` / `plan.md`，TC14 被打穿。

**修正:**

- 将 `/sandtable-plan` 六镜像、`writing-tests` 四镜像、`writing-plan` 四镜像补入 T7 `文件:` 清单。
- 同步更新顶部 `close loop 已选择即续跑` 文件地图，避免实现者只看顶部概览时漏掉这些文件。

## Held

- PRD 确认证据防伪规则没有接受 agent 自写 journal/state 作为确认。
- autopilot/resume/manual 推演/live/debrief 的 PRD 未确认门禁未发现新破口。
- T5/T6 完整性闸门的 PRD-AC、MUST/MNOT、TC、PLAN 键集合与 hash 校验未发现新破口。

## Next

已修正 `plan.md`。重新运行 mental，再运行 redteam；守住后进入 implementation rehearsal。
