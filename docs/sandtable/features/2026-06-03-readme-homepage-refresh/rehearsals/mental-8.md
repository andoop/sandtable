# MENTAL_REHEARSAL 轮 8 · README 首页重塑（redteam 回退后第 1 轮复验）

## 结论
`LOGIC_CLOSED`

本轮在 redteam 第 1 轮攻破并回写 4 处计划级 breach 后，重新并行派出 3 个只读子 agent，对修正后的文档护栏进行第 1 轮回退复验。3 个方向全部返回 `LOGIC_CLOSED`，因此本轮计入回退后的有效 `mental` 轮次。

## 审查范围
- `Quickstart` 是否已成为唯一试用落点，前两屏锚点、三件套与版位顺序是否不再允许试用信息分裂。
- section 预算是否真正压回 `160` 行硬门槛之内，并且不会逼执行者删除关键入口或事实锚点。
- `superpowers` 比较是否已被收紧到两处合法位置，`Why` 等侧门是否被显式封死。
- Cursor 默认路径是否已把“重载窗口/重开工作区，使 `alwaysApply` 生效”写成 README 级强制接入动作。

## 结果
1. **首页路径与预算护栏**：通过  
   - `Quickstart` 已成为唯一试用落点；section 预算总额已低于 `160` 行硬门槛，不再存在“按预算施工也天然超线”的失败路径。

2. **对比作用域护栏**：通过  
   - README 中所有 `superpowers` 比较句都已收敛到“前两屏 1 条微对比”或正式对比区块两处合法位置；其它 section 的侧门比较已被显式封死。

3. **Cursor 默认路径护栏**：通过  
   - `Quickstart` 的 Cursor 子块已要求显式写出“重载窗口/重开工作区，使 `alwaysApply` 生效”后再执行第一条命令，不再把该接线动作只留在 `INSTALL.md`。

## 主 agent 裁决
- 这轮 `mental` 满足“至少 3 个只读子 agent，且全部 `LOGIC_CLOSED`”。
- `autonomy.completed_rounds.mental` 已重算为回退后的 `1/3`。
- 下一步：继续补满 redteam 回退后的剩余 2 轮 `mental`，随后重新进入 `REDTEAM`。
