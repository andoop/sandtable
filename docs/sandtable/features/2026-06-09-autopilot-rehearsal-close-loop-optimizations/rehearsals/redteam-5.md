# REDTEAM 轮 5 · mental-10 闭环后复攻

**信号:** `BREACH_FOUND`

## 范围

mental-10 返回 `LOGIC_CLOSED` 后，重新并行派发 3 个只读红军子 agent，分别攻击：

- T1/T2/T5/T6：结构化闸门核对基准、部分文档 autopilot/resume、manual→autopilot、live/rehearse/debrief 完整性闸门。
- T3/T4/T7/T8：behavior baseline、using-sandtable 会话注入层、mental/redteam 真实问题口径、refine/resume/closing-the-loop 已确认续跑、镜像同步。
- 全局：TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

口径：只认可真实、可复现、与 PRD/tests/plan/code reality 相关的破口。

## 攻破结果

### B30 · 结构化核对基准只跟踪标识，不跟踪正文变更

- 复现：impl 闸门通过后，`prd.md` FR7/FR8、`tests.md` TC12/TC13 或 `plan.md` 某 checkbox 的子 bullet 被修改，但标识集合不变；旧 impl 报告键集合仍匹配，进入 debrief。
- 后果：打穿 TC10/TC11/FR6。
- 修正：T5/T6 的结构化核对基准扩展为记录 FR/MUST/MUST NOT 正文/验收 hash、TC Given/When/Then 正文 hash、PLAN checkbox 标题和子 bullet 正文 hash；同一标识下正文变化也必须导致基准不同。T6 验证新增同 ID 正文变更场景。

### B31 · 历史 `min_rounds` 续接可能被覆盖为 1/1/1

- 复现：历史 feature 保留 `min_rounds={ mental:3, redteam:3, impl:2 }`，`completed_rounds.mental=2`；新 autopilot 续接时若写入 1/1/1，会跳过原本第 3 轮 mental。
- 后果：打穿 TC4 与“不迁移历史 feature 状态”非目标。
- 修正：T1 步骤2/7 明确仅冷启动初始化 `min_rounds` / `min_agents_per_round`；续接或 manual→autopilot 首次切换不得覆盖既有 `min_rounds` / `min_agents_per_round`。T1 验证新增历史 3/3/2 + mental=2 场景。

### B32 · `using-sandtable` 会话注入层仍保留 blanket 推演铁律

- 复现：session-start 全量注入 `skills/using-sandtable/SKILL.md`；T3 只改 behavior baseline 五文件，不改 using-sandtable “推演铁律/异常修正/Red Flags”；无关边缘疑问仍被上升为 anomaly。
- 后果：打穿 TC5/FR4。
- 修正：T3 文件清单加入 `using-sandtable` 四份镜像；步骤3.6 要求同步收窄 using-sandtable 的“推演铁律”“异常 → 修正 → 重演”与相关 Red Flags；验证搜索词加入 `顺手修` 并覆盖 using-sandtable 四镜像。

### B33 · closing-the-loop HARD-GATE #4 仍可能再次 AskQuestion

- 复现：用户自然语言“PRD 已确认，请继续写 tests.md”；T7 新增“已选择路径优先”，但未修订 manual 多分支必须 AskQuestion 的硬门禁；agent 再次 AskQuestion 或输出模板。
- 后果：打穿 TC13/FR7/FR8。
- 修正：T7 步骤1 明确修订 manual 多分支 AskQuestion 硬门禁：本回合已通过 AskQuestion 或自然语言明确选择路径时，不得再次 AskQuestion，必须先执行选择再收尾。T7 验证新增相关搜索。

## 未攻破项

- B25 粗摘要/mtime、B27 refine 等待/越权、B28 部分文档、B29 manual→autopilot、B19-B24 原路径均可守住。
- T4 红蓝真实攻破口径可守住。
- 镜像路径整体仍由 T8 覆盖。

## 下一步

`plan.md` 已修正 B30-B33。需重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
