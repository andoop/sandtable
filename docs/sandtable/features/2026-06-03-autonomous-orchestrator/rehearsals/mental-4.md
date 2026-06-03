# 头脑预演报告 · 轮 4

结果：`ANOMALY_FOUND`

## 背景
- 当前需求仍处于 `MENTAL_REHEARSAL`。
- 本轮按三条链路并行复核：`autopilot 自动入口与配额`、`状态持久化与恢复`、`全局索引与入口边界`。
- 主 agent 对子 agent 报告逐项抽查后，确认本轮发现属于**计划级 anomaly**，不是“尚未实现”带来的噪声。

## 已核实成立的 anomaly
1. `autopilot` 续接语义与“进入即 `phase=RECON`”冲突，缺少“全新需求 vs 已有 feature”分流。
2. `autonomy.completed_rounds` 的回卷规则不明确，且一度与 `rehearsals.*.runs` 的职责混淆，无法支撑 resume 正确续跑。
3. autopilot 想覆盖“不要逐步等人确认”，但与 `writing-prd` / `writing-tests` 等现有 skill 的确认门槛缺少显式 override。
4. `README` / `AGENTS` / `.cursor/rules` / `commands` 对 start/rehearse 的旧表述若只追加 autopilot 而不收束，仍会和新入口冲突。
5. 前序流程回退规则一度只写“最早尚未重新验证”，缺少可执行映射；同一计划文件内部还出现了旧表述与新映射并存。

## 本轮已完成的修补
- `prd.md`
  - 明确区分“全新需求起跑”和“已有 feature 续接”。
  - 明确 `INTAKE` 由 `state-and-memory` 建档/恢复，`RECON → PLAN` 显式沿用 `gathering-intel → writing-prd → writing-tests → writing-plan`。
  - 明确 `/sandtable-autopilot` 的显式触发是对前序流程的预授权，并要求在新 skill 中显式 override 手动命令与相关 skill 的确认门槛。
  - 把前序流程回退改成“按被修正的最早产物映射到 `RECON/OBJECTIVES/TESTCASES/PLAN`”，把推演链回退改成“修正前序产物后统一回 `MENTAL_REHEARSAL` 并清零 `mental/redteam/impl` 的 `completed_rounds`”。
- `tests.md`
  - TC1 / TC2 / TC6 / TC8 同步覆盖：前序流程 skill 链、预授权 override、`completed_rounds` 与 `rehearsals.*.runs` 的分工、命令层与索引层的边界收束、`project.md` 数量对账。
- `plan.md`
  - T1 自动流程补入“全新 vs 续接”“INTAKE vs RECON→PLAN 四 skill”“前序流程回退映射”“推演链回退清零规则”。
  - T3 补入 `completed_rounds` / `rehearsals.*.runs` 的权威关系，以及 `state-and-memory` 的 autopilot 分支要求。
  - T4/T5/T6 补入 `using-sandtable` 的 autopilot 例外说明、`sandtable-rehearse` frontmatter 收束、README 命令表精确替换稿、以及更严格的验证口径。

## 当前仍未闭合的点
- 本轮最后一批文档修补完成后，**尚未再发起一轮新的 mental 子 agent 复核**，因此这些修补是否已完全消除剩余歧义，还没有新证据闭环。
- 下一轮应优先复核三件事：
  1. `plan.md` 中前序流程回退映射、推演链回退触发条件、以及 `completed_rounds` 规则是否已全量一致；
  2. `<AUTOPILOT-OVERRIDE>` 是否在实现计划中完整覆盖手动命令与相关 skill 的旧确认门槛；
  3. TC8 / T4 / T5 / T6 的验证口径是否足以防止“只出现 autopilot 关键词就误判通过”。

## 结论
- 本轮不进入 `REDTEAM`。
- 主 agent 已完成本轮 anomaly 的核实与文档修补，但仍需继续 `MENTAL_REHEARSAL`，在新一轮只读复核确认无剩余计划级断点后，才能转入下一阶段。
