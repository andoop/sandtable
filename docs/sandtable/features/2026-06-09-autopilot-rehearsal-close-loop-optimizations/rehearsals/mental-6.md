# MENTAL_REHEARSAL 轮 6 · mental-5 修正后重演

**信号:** `ANOMALY_FOUND`

## 范围

mental-5 修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2：`phase=PLAN` 续接、resume/state 过期 impl 闸门、闸门核对基准措辞。
- T3/T4/T7：`being-truthful` 文件清单、prompt blanket 删除、续跑入口文件清单与旧条款改写。
- T5/T6/T8：PLAN checkbox 原文编号、闸门核对基准、debrief 补审。

## 结果

T1/T2 返回 `LOGIC_CLOSED`；T3/T4/T7 与 T5/T6/T8 返回 `ANOMALY_FOUND`。

## 异常与修正

### A11 · T3/T7 任务级文件清单仍未落地

- 问题：A6/A8 的修正必须出现在对应任务级 `**文件:**` 清单中，否则实现者按任务清单执行会漏改 `being-truthful`、start/objectives/refine/resume/writing-prd，打穿 TC5、TC12、TC13。
- 修正：T3 任务级 `**文件:**` 补入 `being-truthful` 四份镜像；T7 任务级 `**文件:**` 补入 start/objectives/refine/resume/writing-prd 全镜像。

### A12 · debrief 补审后未刷新闸门核对基准

- 问题：T6 步骤3 允许 debrief 补审写回 impl 报告，但未明确补审通过后要刷新报告内最新“闸门核对基准”；后续 resume/autopilot 仍可能用旧基准误判过期，打穿 TC10/TC11。
- 修正：T6 步骤3 明确补审结论是最新完整性闸门结论续记；补审通过时必须同步刷新报告内“闸门核对基准”。验证新增补审后 resume/autopilot 不再误判过期场景。

## 已闭环项

- B19、B20、B23 已闭环。
- A7 prompt blanket 删除已闭环。
- T4 红蓝真实攻破口径仍闭环。

## 下一步

`plan.md` 已修正 A11-A12。需重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
