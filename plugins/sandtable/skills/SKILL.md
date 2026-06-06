---
name: autonomous-orchestration
description: Use when the developer wants Sandtable to advance from intake through debrief without manual handoff between phases. Defines autonomous progression, minimum rehearsal quotas, rollback rules, and on-disk state updates.
---

# 全自主自动沙盘编排

**开始时声明：** "我在用 autonomous-orchestration 执行无人值守的 Sandtable 全流程。"

## 硬门禁

<HARD-GATE>
1. 自动模式必须完整覆盖 `INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN → MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE`。
2. 最低配额是硬门槛，不可降级：
   - mental：至少 3 轮，每轮至少 3 个只读子 agent；
   - redteam：至少 3 轮，每轮至少 3 个红军子 agent；
   - impl：至少 2 轮，每轮至少 2 个独立 worktree 子 agent。
3. 任一 `ANOMALY_FOUND` / `BREACH_FOUND` / `BLOCKED` 都要先由主 agent 亲自核实；写回 `prd.md` / `tests.md` / `plan.md` / `state.md` / `journal.md` 后，再从最早尚未重新验证的阶段重演。异常轮不计入配额。
4. 只有真正需要开发者提供的产品意图、登录、授权、批准或工具权限时，才允许写 `questions.md` 并停下。
</HARD-GATE>

## AUTOPILOT-OVERRIDE

<AUTOPILOT-OVERRIDE>
1. 只在开发者本回合显式触发 `/sandtable-autopilot`，或显式要求以 autopilot 方式续跑 `/sandtable-resume` 时生效。
2. 作用域只限当前这次命令执行；开发者之后若显式触发手动 slash（如 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live`、`/sandtable-rehearse`），必须按该手动命令的边界执行，不能因为 `autonomy.mode=autopilot` 就静默覆盖。
3. 手动命令仍可继续写 `rehearsals/`、`rehearsals.*.runs` 与 `rehearsals.*.last`，但这些手动记录不能抵扣 autopilot 的 `autonomy.completed_rounds`。
</AUTOPILOT-OVERRIDE>

## 自动流程

1. 先加载 `state-and-memory`，确认 `docs/sandtable/`、feature 目录与 `state.md` 存在；若 feature 不存在，按模板创建并把 `phase` 设为 `INTAKE`。
2. 一进入自动模式，就把 `state.md` 写成：
   - `autonomy.mode=autopilot`
   - `autonomy.min_rounds={ mental: 3, redteam: 3, impl: 2 }`
   - `autonomy.min_agents_per_round={ mental: 3, redteam: 3, impl: 2 }`
   - `autonomy.last_decision=进入 autopilot，开始 RECON`
   - `phase=RECON`
3. 自动完成 `RECON → OBJECTIVES → TESTCASES → PLAN`。正常路径下主 agent 自主决定下一步，不逐步等开发者确认。
3.5 自动阶段**切换时**加载 `closing-the-loop` 的**战报收尾** profile；不 AskQuestion；**同一 `/sandtable-autopilot` 命令内**立即执行下一合法阶段。命令完全结束或 `blocked=true` 时输出**完整收尾**。
4. 每次自动推进或回退重演时，都同步更新 `state.md.updated`、`phase` 与 `autonomy.last_decision`，并在 `journal.md` 追加本次裁决的原因。
5. 进入推演链后，按配额闭包推进：
   - `autonomy.completed_rounds.mental < autonomy.min_rounds.mental` 时，继续 mental；
   - mental 达标后，若 `autonomy.completed_rounds.redteam < autonomy.min_rounds.redteam`，继续 redteam；
   - redteam 达标后，若 `autonomy.completed_rounds.impl < autonomy.min_rounds.impl`，继续 impl；
   - 三类配额全部达标后，进入 `EVALUATE`。
6. `phase` 在 autopilot 下是记录位；恢复与续跑时，优先看 `autonomy.completed_rounds` 是否闭包达标，再决定下一步。

## 轮次判定

- mental 一轮完成：该轮至少 3 个只读子 agent，且全部返回 `LOGIC_CLOSED`。
- redteam 一轮完成：该轮至少 3 个红军子 agent，且全部返回 `HELD`。
- impl 一轮完成：该轮至少 2 个独立 worktree 子 agent，且全部返回 `DONE`。
- 任一子 agent 在该轮返回异常/攻破/阻塞：本轮不计入 `autonomy.completed_rounds`；先修正，再重跑当前阶段。

## 阻塞与回退裁决

| 信号 | 主 agent 裁决 | `state.md` 动作 |
|------|---------------|-----------------|
| `ANOMALY_FOUND` | 亲自核实后修正文档/计划并重演 | `blocked=false`；`phase` 设为最早尚未重新验证的阶段；刷新 `autonomy.last_decision` |
| `BREACH_FOUND` | 亲自核实后修正文档/计划并从 mental 重新验证 | `blocked=false`；`phase=MENTAL_REHEARSAL`；刷新 `autonomy.last_decision` |
| `BLOCKED`（内部可修正） | 作为可修正阻塞处理，修正后重演 | `blocked=false`；`phase` 设为最早尚未重新验证的阶段；刷新 `autonomy.last_decision` |
| `BLOCKED`（外部依赖） | 升级为真正阻塞，写 `questions.md` 向开发者提问 | `blocked=true`；保留当前 `phase`；刷新 `autonomy.last_decision` 说明阻塞原因 |

## 落盘要求

每完成一次自动动作，都要同时写回：
- `state.md`：`phase`、`updated`、`autonomy.*`、必要时 `selected_impl`
- `journal.md`：为什么推进 / 为什么回退 / 为什么升级阻塞
- `rehearsals/`：每轮独立报告，如 `mental-<n>.md`、`redteam-<n>.md`、`impl-<n>-<branch>.md`

## Red Flags

| 念头 | 现实 |
|------|------|
| "照老习惯先问用户要不要继续下一步" | 自动模式默认自己继续；除非是真阻塞。 |
| "这轮发现异常了，先算完成，后面补轮" | 不行。异常轮不计入配额，修正后重跑。 |
| "手动跑过一次 mental，可以顺手抵掉 autopilot 的一轮" | 不行。手动 `rehearsals.*` 不能回填 `autonomy.completed_rounds`。 |
| "state.md 里已经写了 phase，就不用看 quota" | 不行。autopilot 恢复与续跑先看配额闭包，再看 `phase`。 |
