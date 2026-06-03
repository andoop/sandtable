# REDTEAM 轮1 · 结果：BREACH_FOUND

> 我在用 red-team-wargame 发起红蓝对抗。
> 目标：攻击 `2026-06-03-autonomous-orchestrator` 的当前计划（`prd.md` / `tests.md` / `plan.md`），验证它是否仍可被具体场景击穿。

## 本轮编组
- OPFOR-A：攻击 `autopilot` override 与手动 slash 边界。
- OPFOR-B：攻击 `phase` / `completed_rounds` / resume 的配额闭包。
- OPFOR-C：攻击 `using-sandtable` / README / AGENTS / rule / `state-and-memory` 的旧总入口与旧回退语义。
- OPFOR-D：攻击 `TC8 / T5 / T6` 的机械验收强度与假阳性窗口。

## 已核实成立的 breach

### breach-1 · override 静默削弱手动命令
- 杀招：只要 `autonomy.mode=autopilot`，随后显式执行 `/sandtable-start` 也会被 `<AUTOPILOT-OVERRIDE>` 静默跳过确认。
- 核实：成立。`FR1` / `TC2` / `T1` / `T3.5` 之前只写“覆盖旧确认门槛”，未把生效域限定在当前 `/sandtable-autopilot` 回合或 autopilot 版 `/sandtable-resume`。
- 处置：已修订 `prd.md` / `tests.md` / `plan.md`，明确 override 只在本回合显式 `/sandtable-autopilot` 或 autopilot 版 `/sandtable-resume` 生效；手动 slash 命令仍按手动语义执行。

### breach-2 · `phase` 可压过配额闭包
- 杀招：已有 feature 若 `phase=REDTEAM`、`completed_rounds.mental<3`，autopilot 续接时仍可能“按当前阶段继续”，跳过 mental 缺口。
- 核实：成立。`plan.md` 一度把“按当前阶段继续”放在已有 feature 分支，而配额闭包在后文单列，触发点不够硬。
- 处置：已修订 `prd.md` / `tests.md` / `plan.md`，统一为“续接已有 feature 时先做配额闭包纠偏，再从最早未完成推演阶段继续”；`phase` 降为记录位，不再是推演链续跑权威。

### breach-3 · manual 报告可能被偷算进 `completed_rounds`
- 杀招：先手动跑 `/sandtable-mental` / `/sandtable-rehearse` 生成 `rehearsals/*.md`，再让 autopilot 以“已有报告”为由直接给 `completed_rounds` 加一。
- 核实：成立。此前只排除了 `runs/last`，没有把 manual `rehearsals/*.md` 也列入“非 autopilot 进度权威”。
- 处置：已修订 `prd.md` / `tests.md` / `plan.md`，明确 manual 产出的 `rehearsals/*.md`、`runs`、`last` 都不能抵 autopilot 配额；autopilot 接手后也必须重新派满该轮最低子 agent 数并重写本轮报告。

### breach-4 · `state-and-memory` 旧回退语义未被强校验
- 杀招：`TC8 / T5 / T6` 若只做弱负向，执行者可保留 `state-and-memory` 的旧回退简写，只额外补一段 autopilot 说明。
- 核实：成立。原验收更偏“扫雷”，对 `state-and-memory` 的 autopilot 分支缺少正向锚点。
- 处置：已修订 `tests.md` / `plan.md`，把 `skills/state-and-memory/SKILL.md` 纳入 `TC8 / T5 / T6` 的正向锚点检查（`autonomy.mode=autopilot`、`MENTAL_REHEARSAL`、`completed_rounds`、产物映射），并扩大负向模式，禁止旧回退简写与 `FIX -> OBJ` / `FIX -> OBJECTIVES` 变体。

## 复打后已扛住的攻击面
- `HELD`：手动 slash 不再被 autopilot 静默覆盖。
- `HELD`：`phase` 不能再领先于配额闭包推进。
- `HELD`：manual `rehearsals/*.md` / `runs` / `last` 不能再偷算进 `completed_rounds`。

## 仍未完全收口的 breach

### breach-5 · `TC8 / T5 / T6` 仍偏 regex 驱动，存在语义绕过窗口
- 杀招：通过“同义改写 + 脚注式合规 + 局部贴纸化正向命中”，在不触发 denylist 的情况下保留旧总入口/旧回退心智，却机械通过 `rg` 验收。
- 例子：
  - `总入口` 改写为 `核心入口` / `主编排`；
  - `总演习` 改写为 `推演总控`；
  - 在 README / AGENTS / rule 追加一行满足边界 `rg` 的短句，但正文其它位置继续保留等价旧语义；
  - `state-and-memory` 用同义句表达“异常后按 phase 回退到 OBJECTIVES/TESTCASES/PLAN”，避开 denylist 精确字面。
- 主 agent 裁决：成立。这不是“当前文档没改对”，而是“当前终验过于依赖字符串匹配，尚不能完全证明语义已收束”。

## 当前判断
- 本轮红蓝对抗结果：`BREACH_FOUND`
- 已在轮内修补并复打通过：4 条
- 当前剩余 anomaly：1 条（`TC8 / T5 / T6` 的 regex 型验收仍不足以完全防住语义绕过）

## 建议下一步
- 继续 `/sandtable-redteam` 第 2 轮，只攻击“验收从 regex 升级为更强结构化断言”的设计；
- 或者先问开发者是否接受该残余风险，再决定是否转入 `/sandtable-live`。
