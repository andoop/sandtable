# MENTAL_REHEARSAL 轮 5 · redteam-3 修正后重演

**信号:** `ANOMALY_FOUND`

## 范围

redteam-3 修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2：`phase=PLAN` 续接死区与 resume 过期 impl 闸门。
- T3/T4/T7：`being-truthful` 衔接、prompt blanket 规则、refine/resume 续跑入口。
- T5/T6/T8：PLAN 原文编号覆盖、闸门核对基准与 mtime 误判。

口径：只把会影响 PRD/tests/plan/code reality 闭环、导致 TC 失败、违反 MUST/MUST NOT，或关键事实无法确认且影响实现决策的问题视作 anomaly。

## 结果

T1/T2 返回 `LOGIC_CLOSED`；T3/T4/T7 与 T5/T6/T8 返回 `ANOMALY_FOUND`。

## 异常与修正

### A6 · T3 任务级文件清单漏 `being-truthful`

- 问题：T3 步骤3.5 已要求最小衔接 `being-truthful`，但 T3 `**文件:**` 清单未列 `being-truthful` 四份镜像；实现者按任务级清单执行会漏改，打穿 TC5。
- 修正：T3 文件清单补入 `skills/being-truthful/SKILL.md`、插件镜像、英文根源、英文插件镜像。

### A7 · mental prompt 旧 blanket 规则未要求删除

- 问题：T3 步骤4 只要求在 prompt “加入”新口径，未明确删除或改写现有“任何无法确认的不确定点”与“不确定本身就是要上报”规则；新旧规则并存会打穿 TC5。
- 修正：T3 步骤4 补充必须删除或改写 prompt 中的 blanket 终止规则。

### A8 · T7 任务级文件清单漏 start/objectives/refine/resume/writing-prd

- 问题：T7 步骤6/6.5/6.6/7 涉及这些命令和 skill，但 T7 `**文件:**` 清单只列 closing-the-loop 与 using-sandtable；实现者可能漏改 refine/resume 旧“等我确认/不得越权”条款，打穿 TC12/TC13。
- 修正：T7 文件清单补齐 start/objectives/refine/resume/writing-prd 全镜像。

### A9 · 闸门过期口径未全局统一到“核对基准”

- 问题：T6 步骤3 已引入“闸门核对基准”，但 T1/T2/T5/T6 其他路径仍残留“文档更新时间晚于 impl 报告/闸门结论”表述；实现者仍可能用 impl 报告 mtime 误判，打穿 TC10/TC11。
- 修正：T1 步骤5/7、T2 步骤3/6、T5 步骤1/7、T6 步骤2 均统一为对比 impl 报告内记录的 `prd.md` / `tests.md` / `plan.md` 核对基准；明确不得只看 impl 报告文件 mtime。

## 已闭环项

- B19：`phase=PLAN` 续接跳过文档链已闭环。
- B20：resume 对过期 impl 闸门的恢复路径已闭环。
- B23：PLAN 原文 checkbox 编号覆盖已闭环。

## 下一步

`plan.md` 已修正 A6-A9。需重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
