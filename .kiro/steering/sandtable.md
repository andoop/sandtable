---
inclusion: always
---

# Sandtable · 沙盘推演驱动开发 — 始终加载基线（精简版）

> Kiro CLI 默认 agent 始终加载这份精简基线（等价 Cursor 的 `.cursor/rules/sandtable.mdc`）。
> **完整方法论按需加载**：任何 Sandtable 工作的入口是读取 `skills/using-sandtable/SKILL.md`；其它细节读各自 `skills/<name>/SKILL.md`，不要把全部规则常驻上下文。

## 你在做什么
用 Sandtable 把一句话需求做成开发者**真正想要**的功能——逻辑闭环、产品闭环、细节完美。手段是一个循环：**制定计划 → 预演 → 发现问题 → 修正计划 → 再预演**，直到预演顺利再择优落地。

## 四条不可违背的底线
1. **不猜测、不捏造，实事求是**：不清楚就读代码/读文档/问开发者，并写回 PRD/计划/状态。
2. **先思考再动手**：显式列假设；多解都摆出来；不清楚就停下来问。
3. **外科手术式改动**：只动必须动的；不兜底、不加未要求的"灵活性"；每行可追溯到需求。
4. **目标驱动**：任务转成可验证的成功标准，循环到通过。

「太简单不用走流程」是最危险的合理化——所有需求都走流程，简单的流程可以很短。

## 核心闭环（状态机）
`INTAKE → RECON → OBJECTIVES → TESTCASES → PLAN → MENTAL_REHEARSAL → REDTEAM → IMPL_REHEARSAL → EVALUATE → INTEGRATE → VERIFY → DONE → FEEDBACK`

任一预演发现会影响闭环/验收/可行性/关键决策的异常 → **立即终止并上报** → 主 agent 核实 → 给方案或问开发者 → 修正 PRD/计划 → 重演。

## 预演两条铁律
1. 任一预演只要发现与计划不符、意料之外、之前没注意到的事，**立即终止并上报**，不要"顺手修一下继续跑"。
2. 预演在**隔离子 agent**中进行，可并行；实现预演各自独立 git worktree/分支。

## 优先级
用户显式指令 > Sandtable 方法论 > 默认行为。用户说"跳过流程/直接改"就照做，但提醒风险。

## 命令入口（Kiro CLI）
用 `/prompts sandtable-<名>` 或 `@sandtable-<名>`（`@`+Tab 补全）触发，`/prompts` 看全部。总入口 `sandtable-start`；自动推进 `sandtable-autopilot`；接防 `sandtable-resume`；战报 `sandtable-status`。

## 技能索引（需要时读 `skills/<name>/SKILL.md`）
`using-sandtable`（总入口）、`being-truthful`、`state-and-memory`、`gathering-intel`、`writing-prd`、`writing-tests`、`writing-plan`、`autonomous-orchestration`、`mental-rehearsal`、`red-team-wargame`、`implementation-rehearsal`、`evaluating-rehearsals`、`closing-the-loop`、`triaging-feedback`、`bugfix-with-evidence`、`mobile-companion`。
问题分级（P0–P3）、回合收尾、三类推演细则等，进入对应步骤时读 `using-sandtable` 及相关 skill，不在此常驻。

## 两条常驻门禁
- **PRD 确认门禁**：`prd.md` 已存在但无可核实开发者确认记录时，不得派发 mental/红军子 agent；同条消息确认 PRD 时，先把确认证据写入 `state.md`/`journal.md`。
- **手机同步常驻义务**（仅当 `.sandtable-runtime/session/mobile-sync.json` 的 `active=true` 且 sync server 在跑）：同步手机是常驻义务，与触发来源无关（手机指令或电脑端直接对话都一样）；在重要动作的前/中/后、阶段切换、关键决策、产生待确认或阻塞时主动同步；等待子 agent 永久阻塞、不设超时。详见 `skills/mobile-companion/SKILL.md`。
