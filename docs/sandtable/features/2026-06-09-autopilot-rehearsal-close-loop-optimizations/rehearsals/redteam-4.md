# REDTEAM 轮 4 · mental-7 闭环后复攻

**信号:** `BREACH_FOUND`

## 范围

mental-7 返回 `LOGIC_CLOSED` 后，重新并行派发 3 个只读红军子 agent，分别攻击：

- T1/T2/T5/T6：`phase=PLAN` 续接、resume/autopilot/rehearse/debrief 闸门核对基准、debrief 补审、TC10/TC11。
- T3/T4/T7：mental 真实问题口径、`being-truthful` 衔接、behavior baseline、refine/resume/start/objectives/writing-prd 续跑入口。
- 全局：TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

口径：只认可真实、可复现、与 PRD/tests/plan/code reality 相关的破口。

## 攻破结果

### B25 · 闸门核对基准允许粗粒度内容摘要

- 复现：impl 闸门通过时报告记录粗摘要（如“T1-T8 已定义”）；之后 `plan.md` 新增 checkbox，但粗摘要不变；旧 impl 覆盖矩阵缺新 checkbox 仍被视为不过期。
- 后果：旧实现可进入 debrief/EVALUATE，打穿 TC10/TC11 与 FR6。
- 修正：T5/T6/T1/T2 统一为“结构化核对基准”，至少包含三文档更新时间、PRD FR/MUST/MUST NOT 标识集合、TESTS TC 集合、PLAN 全部 checkbox 原文键集合（含小数步骤、标题或稳定 hash）。任一 FR/TC/PLAN checkbox 增删改名必须导致基准不同。T6 debrief 前即使未过期，也必须校验矩阵/TODO 键集合与当前基准一致。

### B26 · always-applied 行为基线仍有 blanket 预演铁律

- 复现：T3 只改 mental/being-truthful，但 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/sandtable.mdc` 与英文镜像仍写“意料之外即立即上报”；子 agent 继承 alwaysApply 规则后，无关边缘疑问仍可触发 anomaly。
- 后果：打穿 TC5。
- 修正：T3 文件清单加入 `AGENTS.md`、`CLAUDE.md`、`.cursor/rules/sandtable.mdc`、`locales/en/AGENTS.md`、`locales/en/.cursor/rules/sandtable.mdc`；步骤3.6 要求将行为基线预演铁律同步收窄为“真实影响闭环/验收/决策才上报”，同时保留关键未知必须核实。

### B27 · refine 步骤 6 “等我确认”未对称改写

- 复现：T7 步骤6.5 只要求改 refine “不得越权”条款，不要求改“把修改点摘要给我，等我确认”；用户 `/sandtable-refine PRD 已确认，请继续写 tests.md` 后仍可能停下等待。
- 后果：打穿 TC12/TC13。
- 修正：T7 步骤6.5 明确同步改写 refine 的“等我确认”和“不得越权”两类条款；已确认续跑是命令允许的内联后续，不得再次等待。

### B28 · 部分文档 autopilot 续接死区

- 复现：feature 已有 `prd.md` 但缺 `tests.md`/`plan.md`，用户切 `/sandtable-autopilot`；T1 只定义三文档全无或全有，未定义部分文档。
- 后果：实现者可能重跑整链、跳过缺失文档进入推演，或猜测；打穿 TC2、TC9-TC11。
- 修正：T1 步骤2.5 加第三分支：续接但三文档未齐备时，从最早缺失阶段补齐，不得整链重跑、不得跳过缺失文档进入推演。

### B29 · manual→autopilot 首次切换续接保护过窄

- 复现：手动完成 PLAN，`autonomy.mode=manual`，三文档齐全；首次触发 `/sandtable-autopilot`。旧 T1 续接保护要求 `mode=autopilot` 已为真，导致可能初始化回 RECON。
- 后果：打穿 TC2，并与 `/sandtable-resume` 分叉。
- 修正：T1 步骤2 改为“已有 state 或任一 feature 文档且非显式重来，一律按续接处理”，与 mode 是否此前为 manual 解耦；验证新增 `mode=manual, phase=PLAN, 三文档齐全, 首次 autopilot` 场景。

## 未攻破项

- B19-B24 原路径在当前计划上可守住。
- T4 红蓝真实攻破口径可守住。
- blocked 优先可守住。
- `being-truthful` skill 层衔接可守住，新增破口来自更高优先级 behavior baseline，已修。
- 镜像同步路径仍由 T8 覆盖。

## 下一步

`plan.md` 已修正 B25-B29。需重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
