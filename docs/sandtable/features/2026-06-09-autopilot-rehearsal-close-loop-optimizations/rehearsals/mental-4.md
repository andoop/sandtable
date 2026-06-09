# MENTAL_REHEARSAL 轮 4 · redteam-2 修正后重演

**信号:** `LOGIC_CLOSED`

## 范围

redteam-2 攻破并修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2：autopilot 冷启动/续接、resume 一致性、文档变更后 impl 闸门过期。
- T3/T4/T7：mental blanket 规则收敛、`being-truthful` 衔接、refine/resume 续跑入口。
- T5/T6/T8：impl 闸门过期、evaluating HARD-GATE/dot/Red Flags、PLAN 步骤级覆盖、`not-applicable` 准入。

口径：只把会影响 PRD/tests/plan/code reality 闭环、导致 TC 失败、违反 MUST/MUST NOT，或关键事实无法确认且影响实现决策的问题视作 anomaly。

## 结论

三路均返回 `LOGIC_CLOSED`。

## 已核对闭环

- B12 已闭环：`/sandtable-autopilot` 的 `RECON → OBJECTIVES → TESTCASES → PLAN` 被计划限定为冷启动文档链；已有 feature 且三文档存在、phase 已过 PLAN 时，续接必须跳过文档链并按 `completed_rounds` 进入最低覆盖调度或自主裁决。
- B13 已闭环：mental skill/prompt 将收敛“计划没覆盖即 anomaly”等 blanket 规则，并在 mental 语境中明确以本 skill 的真实问题口径判定 anomaly；不修改 `being-truthful` 全局硬门禁。
- B14 已闭环：T7 文件列表和步骤补入 `/sandtable-refine`、`/sandtable-resume` 六镜像；自然语言确认或 AskQuestion 选择后，应按 `state.phase` 直接加载对应 skill。
- B15 已闭环：文档更新时间晚于 impl 报告/闸门结论时，autopilot、rehearse、debrief、evaluating 均必须判定旧闸门过期。
- B16 已闭环：evaluating skill 必须同步 HARD-GATE、dot 图和 Red Flags，禁止 `全部 DONE → 抽查/打分` 直边绕过完整性闸门。
- B17 已闭环：覆盖矩阵的 PLAN 段必须逐项列到 `PLAN Tx/步骤x`，不得只用 T1-T8 汇总。
- B18 已闭环：`not-applicable` 必须有 PRD 非目标、plan 明确排除项或主 agent 授权子范围作为依据；无依据 N/A 按 `missing` 处理。

## 残余风险（不构成 anomaly）

- manual → autopilot 首次切换仍需实现时注意，但不在本轮 TC 的明确触发路径内。
- 文档过期检查的具体技术手段可用 mtime、内容比对或重读报告实现；计划要求了行为，不强制具体机制。
- 当前源文件仍为旧语义，属于待 live 实现对象，不是计划矛盾。

## 下一步

继续执行 redteam 复攻；若无真实可复现破口，再进入 implementation rehearsal。
