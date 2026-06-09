# Redteam 12 Report

**Status:** `BREACH_FOUND`

## Scope

mental-19 闭环后复攻 `plan.md`，重点检查：

- PRD 未确认全局门禁、三文档齐备/未齐备负向场景。
- autopilot / closing-the-loop / using-sandtable 同命令续跑例外。
- PRD 确认证据链与 resume/autopilot 续接判定。

只接受真实可复现破口；空泛风险、偏题脑洞和无现实触发路径的猜测不计入 breach。

## Result

2 个红军子 agent 均返回 `BREACH_FOUND`。主 agent 核实后归并为两条同源证据链问题，已修正 `plan.md`。

## Breaches

### RT12-B45: `phase>=TESTCASES` 被误作 PRD 已确认代理

**复现路径:**

1. autopilot 或错误续接写到 `tests.md`/`plan.md`，`phase=TESTCASES` 或 `phase=PLAN`，但没有开发者确认 PRD。
2. T1/T2 旧文本把 `phase>=TESTCASES` 当作“PRD 已确认”的正向条件。
3. 续接时误判 PRD 已确认，进入 PLAN/MENTAL，打穿 TC14。

**修正:**

- T1/T2 删除 `phase>=TESTCASES` 作为确认代理的语义。
- 可核实 PRD 确认只能来自开发者输入：本回合明确确认、AskQuestion answer id、用户确认原话摘录、确认时间，或等价 `state.md` 字段。
- `phase` 只能作为流程位置，不能单独证明 PRD 已确认。

### RT12-B46: journal 确认记录缺少可核实操作定义

**复现路径:**

1. agent 自己在 `journal.md` 写入“PRD 已确认，进入 TESTCASES”之类推进日志。
2. 用户从未确认 PRD。
3. resume/autopilot 续接时把 journal 的 agent 自写日志当作确认记录，绕过 PRD 未确认门禁。

**修正:**

- T1/T2 定义“可核实确认”必须带开发者来源。
- T2 新增步骤3.5：修订 `state-and-memory` 的 journal 信任规则，PRD 确认是硬例外；agent 自写推进日志、`autonomy.last_decision` 或无开发者来源的 “PRD 已确认” 不得算确认。
- T7 `writing-prd` 步骤要求收到确认时落可核实证据：AskQuestion answer id、用户原话、确认时间或等价 `prd_confirmed` 字段。
- T1/T2/T7 验证新增“仅有 agent 自写 journal，无开发者来源时仍停在 PRD 确认点”。

## Held

- RT11-B43/B44 的全局 PRD 门禁与 autopilot 同命令续跑例外已守住。
- live 完整性闸门、PRD-AC、MUST/MNOT、TODO 键粒度、四路径二次校验未被攻破。
- 镜像同步、T3/T4 真实问题/攻破口径、start/refine/resume 已确认续跑未发现其他计划层破口。

## Next

已修正 `plan.md`。重新运行 mental，闭环后再跑 redteam；全部守住后进入 implementation rehearsal。
