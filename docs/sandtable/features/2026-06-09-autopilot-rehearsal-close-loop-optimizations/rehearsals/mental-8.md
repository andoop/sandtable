# MENTAL_REHEARSAL 轮 8 · redteam-4 修正后重演

**信号:** `ANOMALY_FOUND`

## 范围

redteam-4 修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2/T5/T6：结构化闸门核对基准、部分文档 autopilot 续接、manual→autopilot 首次切换、TC2/TC9-TC11。
- T3/T7：behavior baseline、refine/resume 续跑入口、TC5/TC12/TC13。
- 全局：TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

## 结果

T3/T7 返回 `LOGIC_CLOSED`；T1/T2/T5/T6 与全局检查返回 `ANOMALY_FOUND`。

## 异常与修正

### A13 · B28 未传播到 T2 resume 恢复分支

- 问题：T1 步骤2.5 已要求三文档未齐备时先补文档，但 T2 的 `state-and-memory` 恢复分支和 `/sandtable-resume` 命令仍可能只按 `completed_rounds` 进入 mental/redteam/impl。
- 后果：autopilot 中断后仅有 `prd.md` 时，`/sandtable-resume` 可跳过 `tests.md`/`plan.md` 进入推演，打穿 TC2、TC9-TC11。
- 修正：T2 步骤3/6 加入文档齐备度检查：任何推演/实现调度前先确认 `prd.md`/`tests.md`/`plan.md` 齐备；缺失时从最早缺失阶段补齐。T2 验证新增 `autonomy.mode=autopilot`、仅有 `prd.md`、`/sandtable-resume` 不得进入 mental 的场景。

### A14 · B26 行为基线文件未进入 T3/T8 任务级清单

- 问题：T3 步骤3.6 已要求改 `AGENTS.md` / `.cursor/rules/sandtable.mdc` 等行为基线，但任务级 `**文件:**` 与 T8 最终核对范围必须显式包含这些文件。
- 后果：实现者按任务清单/T8 执行可漏改 alwaysApply 基线，打穿 TC5/TC16/TC18。
- 修正：T3 任务级 `**文件:**` 补入 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/sandtable.mdc`、`locales/en/AGENTS.md`、`locales/en/.cursor/rules/sandtable.mdc`；T8 步骤1 增加行为基线核对范围。

## 已闭环项

- B25 结构化闸门核对基准已闭环。
- B27 refine “等我确认/不得越权”对称改写已闭环。
- B29 manual→autopilot 首次切换已闭环。
- T3/T7 语义层已闭环。

## 下一步

`plan.md` 已修正 A13-A14。需重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
