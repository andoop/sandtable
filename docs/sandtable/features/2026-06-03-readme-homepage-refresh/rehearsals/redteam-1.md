# REDTEAM 轮 1 · README 首页重塑（计划级对抗）

## 结论
`BREACH_FOUND`

本轮按计划层发起 3 个红军 OPFOR 子 agent，对前两屏优先级/预算、`superpowers` 事实边界、以及试用链路默认路径进行对抗。至少 1 个红军给出了可复现杀招，且主 agent 已核实成立，因此本轮不计入 autopilot 的有效 `redteam` 轮次。

## 已核实破口

1. **`Quickstart` 不是唯一试用落点**
   - 表现：`plan.md` 的骨架、逐段映射与任务步骤同时保留了 `Quickstart`、`命令入口`、旧“安装 / 接入”映射，执行者可能把安装/接入放在一处、第一条命令放在另一处。
   - 后果：读者按“顺读 + 一次跳转”仍拿不到同一落点内的三件套，击穿 `TC6 / TC8 / FR6`。
   - 处置：已把 `Quickstart` 收紧为唯一试用落点，前两屏短锚点只能跳向 `Quickstart`，不再保留与之竞争的独立“安装 / 接入”主 section。

2. **section 预算总和先天超出 160 行**
   - 表现：原预算上限求和已超过 PRD 写死的 `160` 行硬门槛。
   - 后果：执行者即使严格按预算施工，也会天然超线；若临时砍行数，则又会压掉关键入口或事实锚点。
   - 处置：已重算 `plan.md` 预算，把总额压回硬门槛之下，并同步调整优先删减顺序。

3. **`superpowers` 比较作用域可被 `Why` 等 section 侧门绕开**
   - 表现：两句制与第三句禁令原本只强约束正式对比区块，没有明确禁止在 `Why`、自举证明、Quickstart 等其它 section 再夹带新的比较句。
   - 后果：执行者可能让正式对比区块合规，却在其它 section 偷塞带锚点的越界比较，仍然绕开红线。
   - 处置：已把 README 中所有涉及 `superpowers` 的比较句收紧到两处合法位置：前两屏那 1 条微对比，或正式对比区块；其它 section 一律不得新增比较句。

4. **Cursor 默认路径缺“重载窗口”关键接线动作**
   - 表现：README 级护栏此前只要求 `Quickstart` 给出“安装/接入/第一条命令”，但没有把 Cursor 默认路径真正生效所需的“重载窗口/重开工作区，使 `alwaysApply` 生效”写成强制接入动作。
   - 后果：README 看起来满足三件套，但用户实际走完默认路径后规则仍未生效，击穿 `TC6 / TC8 / FR6`。
   - 处置：已把这一步前置进 `prd.md/tests.md/plan.md` 的 `Quickstart` 要求，禁止把它只藏在 `INSTALL.md` 里。

## 主 agent 裁决
- 本轮红军成功攻破计划护栏，需回退到 `MENTAL_REHEARSAL` 重新验证修订后的文档。
- `state.md` 已更新为 `redteam.runs=1`、`last=breach`，并把 autopilot 的 `completed_rounds` 归零，避免恢复时错误跳过重演。
- 下一步：对修订后的 `prd.md/tests.md/plan.md` 重新发起 mental 预演，确认红军打出的 4 处破口已全部收口。
