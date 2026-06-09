# Redteam 11 Report

**Status:** `BREACH_FOUND`

## Scope

mental-18 闭环后复攻 `plan.md`，重点检查：

- RT10-B42 / A21 修正：PRD 未确认门禁、autopilot 不等待例外、resume/autopilot 文档齐备度、start/refine/resume 已确认续跑。
- 整体计划级破口：TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

2 个红军子 agent 均返回 `BREACH_FOUND`，主 agent 核实后归并为两条同源真实计划破口，已修正 `plan.md`。

## Breaches

### RT11-B43: autopilot 同命令续跑硬门禁压过 PRD 未确认门禁

**复现路径:**

1. `/sandtable-start` 写完 `prd.md` 后停在 PRD 确认点，用户未确认。
2. 用户触发 `/sandtable-autopilot` 续接。
3. T1 已要求停在 PRD 确认点，但 `closing-the-loop` HARD-GATE 5、`autonomous-orchestration` 步骤3.5、`using-sandtable` 的 autopilot 同命令续跑旧条款仍可能要求“不 AskQuestion/同命令继续”。
4. autopilot 模式压过确认门禁，复现 RT10-B42。

**修正:**

- T1 步骤3 显式收窄 `autonomous-orchestration` 步骤3.5 的战报收尾/同命令立即执行下一合法阶段。
- T1 步骤7 改写 `/sandtable-autopilot` 步骤7：续接命中 PRD 未确认门禁时结束命令，停在确认点，不得同命令进入 TESTCASES/PLAN/推演链。
- T7 步骤1 修订 `autonomy.mode=autopilot && blocked=false` 的硬门禁：PRD 未确认门禁优先于 autopilot 同命令续跑。
- T7 步骤5 为 `using-sandtable` 的 autopilot 同命令续跑句加同等例外。
- T7 验证新增搜索 autopilot/same command/without waiting 等旧条款，确认均有 PRD 未确认例外。

### RT11-B44: 三文档齐备续接绕过 PRD 未确认门禁

**复现路径:**

1. `prd.md`、`tests.md`、`plan.md` 都存在，但 PRD 从未获开发者确认。
2. `state.phase=PLAN` 或其他后续阶段。
3. `/sandtable-autopilot` 或 `/sandtable-resume` 续接命中“续接且三文档已存在 → 跳过文档链 → 最低覆盖调度”，进入 mental/redteam/impl。
4. PRD 未确认门禁只在“三文档未齐备”分支生效，打穿 TC14。

**修正:**

- T1 步骤2.5 把 PRD 确认门禁提升为进入 TESTCASES/PLAN/MENTAL/REDTEAM/IMPL 前的全局前置条件；无论三文档是否齐备、`phase` 是否已到 PLAN，只要没有可核实的 PRD 确认，就停在 PRD 确认点。
- T2 步骤3/6 同步：resume 恢复和命令执行均先检查 PRD 确认门禁，再检查文档齐备度。
- T1/T2 验证新增 `phase=PLAN`、三文档已存在但 PRD 未确认的 autopilot/resume 负向场景。

## Held

- PRD-AC、MUST/MNOT、live TODO 键粒度、四路径完整性二次校验仍守住。
- start/refine/resume 已确认续跑、using-sandtable 注入层、T3/T4 真实问题/攻破口径、T8 镜像同步未发现其他计划层破口。
- 冷启动 autopilot 自动跑文档链是设计选择，不属于 `/sandtable-start` PRD 确认边界。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
