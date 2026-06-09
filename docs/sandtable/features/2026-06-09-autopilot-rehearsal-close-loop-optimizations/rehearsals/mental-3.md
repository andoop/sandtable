# MENTAL_REHEARSAL 轮 3 · redteam-1 修正后重演

**信号:** `LOGIC_CLOSED`

## 范围

redteam-1 攻破并修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2：自动模式最低覆盖、autopilot 冷启动/续接、状态模板、resume 恢复语义。
- T3/T4/T7：mental/redteam 真实问题口径、close loop 已选择即执行。
- T5/T6/T8：实现预演完整性闸门、live TODO 表、debrief 前置、镜像验证。

口径：只把会影响 PRD/plan/code reality 闭环、导致 TC 失败、违反 MUST/MUST NOT，或关键事实无法确认且影响实现决策的问题视作 anomaly。

## 结论

三路均返回 `LOGIC_CLOSED`。

## 已核对闭环

- T1/T2：redteam-1 B1/B2 已修正。`/sandtable-autopilot` 冷启动与续接分开；续接不清空 `completed_rounds`、不强回 `RECON`。英文 state bundle 必须同步 FEEDBACK/DONE 分支和最低覆盖后的自主裁决。
- T3/T4/T7：redteam-1 B3-B6 已修正。mental 旧“不确定即 anomaly”相关文本和 Red Flags 有计划清理点；redteam 全文旧“唯一使命/往死里打”口径有计划清理点；close loop 已选择即执行覆盖回合初确认入口，且 `blocked=true` / 真实阻塞优先。
- T5/T6/T8：redteam-1 B7-B11 已修正。PRD/tests/plan 变更后旧 impl 闸门失效；implementation dot 图和 Red Flags 必须同步；闸门结论统一写入 `rehearsals/impl-*.md`；覆盖矩阵与 live TODO 表冲突时，以更细粒度 `missing` / `blocked` 为准；T8 以所有任务文件列表核对镜像。

## 残余风险（不构成 anomaly）

- manual → autopilot 首次切换语义需实现时小心区分冷启动和续接。
- T5 的文档变更失效规则主要落在 evaluating/debrief 路径，实现时建议同步让 autopilot 的 impl 计轮也感知“闸门结论过期”。
- `being-truthful` 的通用不确定性规则与 mental 新口径存在张力，但本轮需求只要求调整推演/redteam 的发现口径，不阻塞计划。

## 下一步

mental 已再次闭环，可继续 redteam 重演。redteam 必须只接受真实可复现破口；空泛风险和偏题极端场景不算 `BREACH_FOUND`。
