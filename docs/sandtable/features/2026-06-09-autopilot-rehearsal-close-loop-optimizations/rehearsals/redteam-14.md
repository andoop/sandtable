# Redteam 14 Report

**Status:** `BREACH_FOUND`

## Scope

mental-22 闭环后复攻 `prd.md`、`tests.md`、`plan.md`，重点检查：

- PRD 确认证据链、防伪、手动入口 PRD 门禁。
- 已确认续跑、autopilot/resume/start/refine/closing-the-loop/using-sandtable 优先级。
- TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

2 个红军子 agent 均返回 `BREACH_FOUND`。主 agent 核实后归并为一条真实计划破口，已修正 `tests.md` 与 `plan.md`。

## Breach

### RT14-B55: 文档链手动入口 `/sandtable-plan` 与 refine 改 tests/plan 绕过 PRD 未确认门禁

**复现路径:**

1. `/sandtable-start` 写完 `prd.md`，PRD 尚未获开发者确认。
2. 用户直接触发 `/sandtable-plan`，或通过 `/sandtable-refine` 要求“修改 tests/plan”。
3. T7 已拦 mental/redteam/live/rehearse/debrief 等推演入口，但 `/sandtable-plan`、`writing-tests`、`writing-plan` 和 refine 的文档编辑分支没有同等 PRD 门禁。
4. 未确认 PRD 仍写入 `tests.md` / `plan.md`，打穿 TC14。

**修正:**

- TC14 扩展：resume/autopilot/manual 推演入口、`/sandtable-plan`、refine 修改 tests/plan 续接时，只有可追溯开发者确认才算 PRD 已确认。
- T7 文件清单补入 `/sandtable-plan` 六镜像、`writing-tests` 四镜像、`writing-plan` 四镜像。
- T7 步骤6.5：refine 修改 tests/plan 前必须先满足 PRD 确认门禁；未确认不得加载 `writing-tests` 或 `writing-plan`。
- T7 步骤6.7：`/sandtable-plan` 与 `writing-tests` / `writing-plan` 必须检查 PRD 可核实确认；未确认不得写 `tests.md` / `plan.md`。
- T7 验证新增 PRD 未确认时 `/sandtable-plan` 和 refine 修改 tests/plan 的负向场景。

## Held

- RT13-B50 手动推演/live 门禁已守住。
- RT13-B47/B48 确认证据防伪已守住。
- PRD-AC、MUST/MNOT、live TODO 键粒度、四路径二次校验与完整性闸门未被攻破。
- 镜像同步和 T3/T4 真实问题/攻破口径未发现其他计划层破口。

## Next

已修正 `tests.md` 与 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
