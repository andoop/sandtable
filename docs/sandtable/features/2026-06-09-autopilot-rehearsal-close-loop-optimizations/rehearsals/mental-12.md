# Mental Rehearsal 12 Report

**Status:** `ANOMALY_FOUND`

## Scope

redteam-6 修正后重新检查 `plan.md`，重点验证：

- R6-B35: `prd.md` 独立验收标准 `PRD-AC` 是否进入结构化基准、覆盖矩阵、live TODO 表和 debrief 过期判定。
- R6-B34: T3 是否真正把 `using-sandtable` 四镜像纳入任务级文件清单，避免 session-start 注入层旧推演铁律逃逸。
- 新增修正是否引入新的计划矛盾。

## Subagent Results

- `Mental r6 baselines`: `LOGIC_CLOSED`。`PRD-AC` 修正已在 T5/T6/T1/T2 形成闭环。
- `Mental r6 using`: `ANOMALY_FOUND`。T3 步骤3.6 要求修改 `using-sandtable` 四镜像，但 T3 `**文件:**` 清单仍缺这四条路径。
- `Mental r6 overall`: `ANOMALY_FOUND`。同样确认 R6-B34 未真正落到 T3 任务级文件清单；其余 PRD-AC 修正无新矛盾。

## Anomaly

### A20: R6-B34 修正落到顶部文件地图，未落到 T3 任务级文件清单

**问题:**

T3 步骤3.6 和验证要求收窄 `using-sandtable` 四镜像中的推演铁律、异常修正与 Red Flags；但 T3 `**文件:**` 清单仍未列出：

- `skills/using-sandtable/SKILL.md`
- `plugins/sandtable/skills/using-sandtable/SKILL.md`
- `locales/en/skills/using-sandtable/SKILL.md`
- `locales/en/plugins/sandtable/skills/using-sandtable/SKILL.md`

实现子 agent 若按任务级文件清单做外科手术式改动，会合法跳过这些文件。`hooks/session-start` 继续注入未收窄的 `using-sandtable` 内容后，无关边缘意外仍可能被升级为 anomaly，打穿 FR4、TC5、TC6、TC20。

**修正:**

已将上述四条路径补入 T3 `**文件:**` 清单。

## Closed Items

- R6-B35 `PRD-AC` 闸门基准修正闭环：T5/T6 已要求记录 `PRD-AC` 稳定键与正文 hash，覆盖矩阵和 live TODO 表逐项追踪，debrief 前校验键集合与 hash。
- T8 搜索短语已补入旧 blanket 铁律关键词。
- T4/T7 与 T3 对 `using-sandtable` 的分工清晰：T3 主责推演铁律/异常修正/Red Flags，T4/T7 只改各自领域的句子。

## Next

已修正 `plan.md`。重新运行 mental，确认 A20 闭环后再跑 redteam。
