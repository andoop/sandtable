# REDTEAM 轮 3 · redteam-2 修正后复攻

**信号:** `BREACH_FOUND`

## 范围

mental-4 返回 `LOGIC_CLOSED` 后，重新并行派发 3 个只读红军子 agent，分别攻击：

- T1/T2：autopilot / resume / state 侧的 B12、B15。
- T3/T4/T7：mental 口径、`being-truthful` 衔接、refine/resume 续跑入口、blocked 优先。
- T5/T6/T8：impl 闸门过期、evaluating HARD-GATE/dot/Red Flags、PLAN 步骤级覆盖、N/A 准入、镜像验证。

口径：只认可真实、可复现、与 PRD/tests/plan/code reality 相关的破口。

## 攻破结果

### B19 · `phase=PLAN` 续接死区

- 复现：autopilot 冷启动写完三文档后，会话停在 `phase=PLAN`；再次触发 `/sandtable-autopilot`。
- 破口：T1 步骤2.5 原文要求 `phase` 已过 PLAN 才跳过文档链；`phase=PLAN` 且三文档存在时既不应冷启动，也不满足跳过条件。
- 后果：可能重跑 `RECON → PLAN` 或强回 RECON，打穿 TC2。
- 修正：T1 步骤2.5 改为“三文档已存在且未显式重来，一律跳过文档链；即使 `phase=PLAN` 也直接进入最低覆盖调度”。验证新增 `phase=PLAN` 场景。

### B20 · resume 对过期 impl 闸门不敏感

- 复现：`completed_rounds.impl=1` 且旧闸门通过后，`plan.md` 被修正；用户通过 `/sandtable-resume` 续接。
- 破口：T1 autopilot 命令有过期规则，但 T2 state/resume 恢复分支未插入 `impl 完整性闸门仍有效?` 判断；调度仍可能因为 `impl=1` 进入 EVALUATE。
- 后果：旧实现候选可绕过最新文档完整性检查，打穿 TC10/TC11。
- 修正：T1 步骤3 和 T2 步骤3/6/验证都加入闸门有效性判断；过期时视同 impl 未达标，必须重跑闸门或 re-live。

### B21 · `being-truthful` 预演条款仍与 mental 新口径冲突

- 复现：T3 只改 mental skill/prompt，不改 `being-truthful`；子 agent 同时加载全局 truthful 规则，遇到无关边缘未知仍可能按“预演中不确定就是 ANOMALY”上报。
- 破口：仅在 mental skill 内声明优先级不足以消除跨 skill 文档冲突。
- 后果：无关边缘疑问仍触发 anomaly，打穿 TC5。
- 修正：T3 文件列表加入 `being-truthful` 四份镜像；步骤3.5 改为最小衔接 `being-truthful` 的“与预演的关系”条款，只收窄 anomaly 判定，不删除不猜测硬门禁。

### B22 · refine/resume 旧“不得越权/等我确认”条款压过续跑语义

- 复现：用户 `/sandtable-refine PRD 已确认，请继续写 tests.md`，或 `/sandtable-resume` 后自然语言确认继续。
- 破口：T7 原步骤6.5/6.6 追加了续跑语义，但未明确修订 refine/resume 内旧的“不得越权执行本命令未列出的下一阶段”“等我确认”条款；T7 任务级文件列表也未包含这些命令。
- 后果：实现者可按旧禁令停下输出模板，打穿 TC12/TC13。
- 修正：T7 文件列表补齐 start/objectives/refine/resume/writing-prd 全镜像；步骤6.5/6.6 明确改写旧越权/等待条款，把已确认的阶段续跑列为命令允许的内联后续。

### B23 · PLAN 步骤级覆盖可因小数编号被重编号省略

- 复现：impl 报告把 `T1/步骤2.5`、`T3/步骤3.5`、`T6/步骤2.5`、`T7/步骤6.5/6.6` 折叠成整数步骤或相邻步骤。
- 破口：T5 虽要求步骤级覆盖，但未要求行键与 `plan.md` checkbox 原文编号逐字一致。
- 后果：关键小数步骤可被静默省略，打穿 TC9/TC10。
- 修正：T5 步骤4/5/验证要求覆盖矩阵与 live TODO 表使用 `plan.md` checkbox 原文编号和标题，包含小数编号；缺任一原文编号按 `missing`。

### B24 · 补审写回同一 impl 报告会刷新 mtime，误判闸门不过期

- 复现：impl 闸门通过后 `plan.md` 变更；debrief 补审写回同一个 `rehearsals/impl-*.md`，刷新报告 mtime；再次检查时报告 mtime 晚于 plan，误判不过期。
- 破口：过期规则依赖“更新时间晚于 impl 报告/闸门结论”，但未要求记录闸门核对基准，且 debrief 补审可改写同一文件。
- 后果：旧实现可通过补审 mtime 反转进入评分，打穿 TC10/TC11。
- 修正：T6 步骤1/3/验证要求闸门结论记录核对所依据的 `prd.md`/`tests.md`/`plan.md` 更新时间或内容摘要与核对时间；过期判定基于报告内核对基准，不得只看 impl 报告文件 mtime。文档变更影响实现路径时必须重新 live。

## 未攻破项

- B12 原 `phase=REDTEAM` 续接场景可守住。
- B15 autopilot-only 严格加载 T1 步骤5/7 可守住，但 resume 路径此前未闭合，已修。
- T4 红蓝真实攻破口径可守住。
- blocked 优先可守住。
- B16 evaluating HARD-GATE/dot/Red Flags 可守住。
- B18 N/A 准入可守住。
- T8 镜像验证可守住。

## 下一步

`plan.md` 已修正 B19-B24。由于计划再次变化，必须重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
