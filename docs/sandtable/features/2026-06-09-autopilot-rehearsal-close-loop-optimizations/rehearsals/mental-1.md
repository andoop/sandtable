# MENTAL_REHEARSAL 轮 1 · 计划预演

**信号:** `ANOMALY_FOUND`

## 范围

并行 3 个只读子 agent 对 `plan.md` 做头脑预演：

- T1/T2：自动模式最低覆盖、状态模板与恢复语义。
- T3/T4/T7：头脑推演口径、红蓝对抗口径、close loop 已选择即续跑。
- T5/T6/T8：实现预演完整性闸门、live 执行 TODO 表、镜像一致性。

## 发现的异常

### A1 · 英文 plugin 根 bundle 被误归到 autonomous-orchestration

- 偏差: `plan.md` T1 把 `locales/en/plugins/sandtable/skills/SKILL.md` 列为 autonomous-orchestration 目标。
- 核实: 该文件实际 frontmatter 为 `name: state-and-memory`，不是 autonomous-orchestration。
- 影响: 若按 T1 修改会覆盖错误语义；若跳过则英文 state bundle 继续保留旧 3/3/2 和旧恢复逻辑。
- 修正: 已从 T1 移除该文件，并把 `locales/en/skills/SKILL.md` / `locales/en/plugins/sandtable/skills/SKILL.md` 加入 T2。

### A2 · T2 未覆盖英文 state-and-memory bundle 副本

- 偏差: T2 只列 canonical `state-and-memory/SKILL.md`，未列 `locales/en/skills/SKILL.md` 与 `locales/en/plugins/sandtable/skills/SKILL.md`。
- 核实: 这两个 bundle 均包含 `state-and-memory` 内容和旧 3/3/2 默认值。
- 影响: TC4/TC18 的英文镜像一致性与恢复语义可能失败。
- 修正: 已将两个 bundle 显式加入 T2，并要求补齐 FEEDBACK/DONE 特殊恢复分支与最低覆盖自主裁决。

### A3 · state-and-memory 恢复分支未精确覆盖“最低覆盖后自主裁决”

- 偏差: T2 原本只概括“最低覆盖 + 自主裁决”，没有点名修改恢复流程图与自动分支最后的 `else EVALUATE`。
- 核实: 当前 `state-and-memory` 中恢复分支写死三类配额达标后进入 `EVALUATE`。
- 影响: `/sandtable-resume` 的 autopilot 续跑仍可能机械进入 `EVALUATE`，不符合 TC2/TC3。
- 修正: 已在 T2 增加“恢复流程图和自动模式分支”专门步骤。

### A4 · autopilot 路径未接入实现完整性闸门

- 偏差: T5/T6 原本接入 live/rehearse/debrief，但 T1/autopilot 仍可在 impl 自报 `DONE` 后计入完成并进入 `EVALUATE`。
- 核实: 当前 `autonomous-orchestration` 按 impl 全部 `DONE` 计轮，三类达标后进入 `EVALUATE`。
- 影响: TC9-TC11 在 `/sandtable-autopilot` 路径下可能失效。
- 修正: 已在 T1 增加 impl 完整性闸门：自报 `DONE` 后先核对覆盖矩阵、live TODO 表和 PRD/tests/plan 覆盖，通过后才计入 impl 轮次或进入 `EVALUATE`；T6 验证也纳入 autopilot 路径。

### A5 · implementation prompt 输入范围不足以支撑全量覆盖矩阵

- 偏差: T5 要求 `DONE` 报告输出 FR1-FRn / TC1-TCn 全量覆盖矩阵，但现有 prompt 只要求粘贴 PRD 相关片段和本链路相关 TC。
- 核实: `implementation-rehearsal-prompt.md` 当前输入段确实使用“相关片段 / 本链路相关 TC”。
- 影响: 子 agent 缺少全量信息时无法诚实输出全量矩阵，容易静默漏项。
- 修正: 已在 T5 增加输入上下文改造：粘贴完整 `prd.md` / `tests.md`，或授权子 agent 只读打开三文档，且不得省略任何 FR/TC/PLAN 行。

## 已闭环部分

- T3/T4/T7 对 TC5-TC8、TC12-TC15、TC20 的计划逻辑闭环。
- live 执行 TODO 表定位正确：只存在于实现候选报告内，不新增独立持久文件，不替代 `plan.md` / `state.md`。
- “主 agent 可亲自或按需派只读子 agent”未被写成必须派子 agent。
- 镜像验证明确使用 `templates/en/`，未误写为 `locales/en/templates/`。

## 处理结果

已修正 `plan.md`，本轮 mental 结论仍记录为 `ANOMALY_FOUND`。需要重新运行 mental 预演确认修正后的计划闭环。
