# MENTAL_REHEARSAL 轮 11 · redteam-5 修正后重演

**信号:** `LOGIC_CLOSED`

## 范围

redteam-5 修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2/T5/T6：正文 hash 结构化基准、历史 `min_rounds` 保留、TC4/TC10/TC11。
- T3/T7/T8：`using-sandtable` session-start 注入层收窄、closing-the-loop AskQuestion 硬门禁例外、TC5/TC13/TC16/TC18。
- 全局：TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

## 结论

三路均返回 `LOGIC_CLOSED`。

## 已核对闭环

- B30 已闭环：闸门核对基准包含 FR/MUST/MUST NOT、TC Given/When/Then、PLAN checkbox 标题和子 bullet 的正文 hash；同 ID 正文变更会触发过期或补审。
- B31 已闭环：续接和 manual→autopilot 首次切换不得覆盖历史 `min_rounds` / `min_agents_per_round`。
- B32 已闭环：`using-sandtable` 四镜像的 session-start 注入层推演铁律/异常修正/Red Flags 纳入 T3 收窄与验证。
- B33 已闭环：closing-the-loop manual 多分支 AskQuestion 硬门禁为“本回合已明确选择路径”加例外。
- TC1-TC20、MUST/MUST NOT 与 T1-T8 映射无新矛盾。

## 下一步

进入 redteam 复攻；若 redteam 返回 `HELD`，再进入 implementation rehearsal。
