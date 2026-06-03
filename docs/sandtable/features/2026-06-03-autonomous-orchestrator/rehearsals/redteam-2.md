# REDTEAM 轮2 · 结果：HELD

> 我在用 red-team-wargame 发起红蓝对抗。
> 目标：只攻击 `2026-06-03-autonomous-orchestrator` 当前计划里 redteam 第 1 轮遗留的 `breach-5`，即 `TC8 / T5 / T6` 对“同义改写 + 脚注式合规 + 非主段落复述旧心智”的防护是否仍可被打穿。

## 本轮编组
- OPFOR-A：攻击 `README` / `AGENTS.md` / `.cursor/rules/sandtable.mdc` / `skills/using-sandtable/SKILL.md` 的主索引位是否仍可用“贴纸式合规 + 旁段旧心智”通过。
- OPFOR-B：攻击 `state-and-memory` 从 `TC8` 拆回 `TC6 / T3` 后，验收分层是否仍混乱。
- OPFOR-C：攻击 denylist 仍遗漏的常见同义改写与人工审读范围空档。

## 已核实成立的 breach 与修补

### breach-5a · `TC8` 虽已要求主索引位原位替换，但仍主要靠 `rg`
- 杀招：把 `state-and-memory` 从 `TC8` 移走后，仍可在非主索引段落用 `核心入口` / `推演总控` / `一次串完` 等同义句复述旧心智，而让主索引位与字面 denylist 全绿。
- 核实：成立。`TC8 / T5 / T6` 当时仍把 `rg` 当成主要终验，未明确把“同义改写 + 脚注式合规 + 非主段落复述旧心智”列为人工否决项。
- 处置：已修订 `tests.md` / `plan.md`，把 `TC8 / T5 / T6` 升级为“机器检查 + 人工语义审读”双门槛；明确人工审读必须否决上述三类绕过，不再声称 regex 能独自证明语义收束。

### breach-5b · autopilot 自己的 skill / 命令正文未纳入终验范围
- 杀招：即使 `README` / `AGENTS` / `rule` 已收束，也可在 `skills/autonomous-orchestration/SKILL.md` 或 `commands/sandtable-autopilot.md` 里把 `/sandtable-rehearse` 重新讲成“总控/总入口/全流程升级版”，而原版 `TC8` 不会扫到这些文件。
- 核实：成立。更新为“人工审读”后，最初的审读范围仍只覆盖 `README`、`AGENTS`、`rule`、`using-sandtable`，未把 autopilot 新载体纳入。
- 处置：已修订 `prd.md` / `tests.md` / `plan.md`，把 `skills/autonomous-orchestration/SKILL.md`、`commands/sandtable-autopilot.md`、`.cursor/commands/sandtable-autopilot.md` 一并纳入 `TC8 / T5 / T6` 的负向 `rg` 与人工审读范围，并明确 autopilot skill/命令正文也不得复述旧总入口心智。

## 复打后已扛住的攻击面
- `HELD`：`TC8 / T5 / T6` 不再假装仅靠 regex 就能证明语义收束，已显式要求人工语义审读。
- `HELD`：`state-and-memory` 的 autopilot 回退语义已稳定回归 `TC6 / T3`，不再与 `TC8` 的索引对账混在一起。
- `HELD`：主索引位、autopilot skill、autopilot 命令正文现在都纳入同一套“正向断言 + `! rg` 负向 0 命中 + 文件存在性 + 人工语义审读”验收链。

## 当前判断
- 本轮红蓝对抗结果：`HELD`
- 已核实并修补的 breach：2 条（均为 `breach-5` 的剩余变体）
- 当前剩余计划级风险：未发现新的可复现 breach；余下的是“执行者若跳过人工审读则违反流程纪律”的执行风险，不属于本轮验收设计漏洞。

## 建议下一步
- redteam 已闭环，可进入 `/sandtable-live` 做实现预演。
