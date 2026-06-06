---
description: 头脑预演（军事隐喻：图上作业）· 只读子 agent 把整条逻辑链从头推到尾，验证闭环、无漏洞、无意外影响；异常即停上报。
---

对当前需求执行头脑预演；读取并遵循 `skills/mental-rehearsal/SKILL.md`。

执行：
1. 读本需求 `plan.md`、`prd.md`、`tests.md`、`constraints.md`、`state.md`。
2. 为每条独立逻辑链路准备完整上下文，按 `mental-rehearsal-prompt.md` 并行派发**只读**子 agent 推演。
3. 任一返回 `ANOMALY_FOUND` → 你亲自核实 → 必要时写 `questions.md` 问我 → 修正 `prd.md`/`tests.md`/`plan.md` → 重演。
4. 全部 `LOGIC_CLOSED` → 把报告写入 `rehearsals/mental-<n>.md`，更新 `state.md`（mental.last=closed），提示我可用 `/sandtable-redteam` 做红蓝对抗或 `/sandtable-live` 实现预演。

铁律：纯只读不改代码；异常即停；不脑补兜底；不轻信子 agent，抽查其引用。
