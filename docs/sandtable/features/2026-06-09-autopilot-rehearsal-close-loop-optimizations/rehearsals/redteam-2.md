# REDTEAM 轮 2 · redteam-1 修正后复攻

**信号:** `BREACH_FOUND`

## 范围

mental-3 返回 `LOGIC_CLOSED` 后，重新并行派发 3 个只读红军子 agent，分别攻击：

- T1/T2：自动模式、autopilot 冷启动/续接、resume、state bundles。
- T3/T4/T7：mental/redteam 真实问题口径、close loop 已选择即执行。
- T5/T6/T8：impl 完整性闸门、live TODO 表、debrief、镜像验证。

口径：只认可真实、可复现、与 PRD/tests/plan/code reality 相关的破口；空泛风险、纯猜测、无现实触发路径、偏题极端情况不算 `BREACH_FOUND`。

## 攻破结果

### B12 · autopilot 续接仍可能重跑 RECON → PLAN

- 复现：feature 已有 `state.md`、`phase=REDTEAM`、`completed_rounds={ mental:1, redteam:0, impl:0 }`、三文档已存在；用户再次触发 `/sandtable-autopilot`。
- 破口：计划只要求续接不清空 `completed_rounds` / 不把 `phase` 改回 `RECON`，但没有要求 `RECON → OBJECTIVES → TESTCASES → PLAN` 文档链只在冷启动执行。
- 后果：`/sandtable-autopilot` 与 `/sandtable-resume` 对同一 state 分叉，打穿 TC2 与 T1 自证场景。
- 修正：`plan.md` T1 新增步骤2.5，明确冷启动才跑文档链；续接已有 feature 且三文档存在时跳过文档链，直接补最低覆盖或自主裁决。T1 步骤7 与验证同步补充。

### B13 · mental 旧 blanket 规则仍可制造偏题 anomaly

- 复现：mental 子 agent 遇到与验收无关、不会影响决策的“计划没覆盖”边缘疑问。
- 破口：T3 原计划只清理“不确定本身就是 anomaly”等表述，未明确收敛“计划没覆盖的情况一律是 ANOMALY”；同时未说明 mental 新口径如何与 `being-truthful` 的泛化预演条款衔接。
- 后果：仍可能把无关边缘疑问升级成 `ANOMALY_FOUND`，打穿 TC5。
- 修正：`plan.md` T3 补步骤3 与步骤3.5：计划没覆盖且影响闭环/验收/实现/关键决策才报 anomaly；mental 语境以本 skill 的真实问题口径判定 anomaly，同时保留不猜测原则。

### B14 · close loop 漏掉 refine/resume 续跑入口

- 复现 A：用户通过 `/sandtable-refine PRD 已确认，请继续写 tests.md` 表达确认。
- 复现 B：换会话后 `/sandtable-resume` 恢复手动状态，用户自然语言确认并要求继续。
- 破口：T7 原计划覆盖 start/objectives/writing-prd/closing-the-loop，但未覆盖 `/sandtable-refine` 与 `/sandtable-resume` 六份命令。
- 后果：仍可能只输出摘要或复制模板，不直接写 `tests.md`，打穿 TC12/TC13。
- 修正：`plan.md` T7 文件列表加入 refine/resume 六镜像，新增步骤6.5/6.6 与验证场景。

### B15 · 文档变更后 impl 闸门过期规则未接入 autopilot/rehearse

- 复现：impl 闸门通过后，`plan.md` 被 mental/redteam 修正；autopilot 看到旧闸门通过并进入 `EVALUATE`。
- 破口：T5/T6 原计划只在 evaluating/debrief 侧写过期规则，T1 autopilot impl 计轮和 T6 rehearse 路径未显式接入。
- 后果：过期实现候选可进入评估，打穿 TC10/TC11。
- 修正：`plan.md` T1 步骤5/7 与 T6 步骤2/验证同步加入文档更新时间晚于 impl 报告/闸门结论时必须重跑闸门或重新 live。

### B16 · evaluating-rehearsals 缺 dot 图/HARD-GATE 强制同步

- 复现：实现者只在 evaluating 正文加一句“闸门通过才评分”，但保留旧 dot 图和 HARD-GATE 的 `全部 DONE -> 抽查/打分` 直边。
- 破口：T5 原计划只强制 implementation skill 改 dot 图/Red Flags，未对 evaluating skill 做同级要求。
- 后果：候选缺矩阵、缺 TODO 或闸门过期仍可能被评分，打穿 TC9-TC11。
- 修正：`plan.md` T5 步骤7 明确要求 evaluating skill 同步修改 HARD-GATE、dot 图和 Red Flags。

### B17 · 覆盖矩阵 PLAN 粒度不足

- 复现：impl 候选覆盖矩阵只写 `PLAN 覆盖: T1 ... T8`，但 `plan.md` 内有大量步骤级 checkbox；某步骤漏做但 T5 汇总写“完成”。
- 破口：T5 原矩阵格式只到任务级，未满足 TC9 “逐项列出 plan.md 中的必做项”。
- 后果：部分实现可形式通过完整性闸门。
- 修正：`plan.md` T5 步骤4/5/验证改为 `PLAN Tx/步骤x` 步骤级覆盖，覆盖矩阵与 live TODO 表必须逐步对应。

### B18 · `not-applicable` 无准入条件可洗白漏项

- 复现：候选未实现 close loop，却把 FR7/FR8 或 PLAN T7 标成 `not-applicable`。
- 破口：T5 原计划只禁止 `missing`/`blocked`，没有定义 N/A 准入条件。
- 后果：in-scope 需求可被 N/A 洗白，打穿 TC10。
- 修正：`plan.md` T5 步骤5/7/验证新增 N/A 规则：必须引用 PRD 非目标、plan 明确排除项或主 agent 授权子范围；无依据 N/A 按 `missing` 处理。

## 未攻破项

- B2 英文 state bundle 同步：T2 步骤4 已要求同步恢复语义全文。
- B4 redteam 真实攻破口径：T4 已覆盖 skill、prompt、命令与 using-sandtable 镜像。
- B6 阻塞优先：T7 步骤1 已明确排在 `blocked=true` 后。
- B9/B10/B11：闸门结论落盘、矩阵/TODO 冲突裁决、T8 全任务文件列表镜像验证在计划层面可守住；B17/B18 是粒度和 N/A 准入的新破口，不是这些修正本身失效。

## 下一步

`plan.md` 已修正 B12-B18。由于计划再次变化，必须重新运行 mental，再运行 redteam。两者闭环后才能进入 implementation rehearsal。
