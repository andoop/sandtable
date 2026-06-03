# 全自主自动沙盘编排 autopilot · 本需求的测试用例

> 我在用 writing-tests 把需求具体化为测试用例。
> 黑盒、场景化、人可读。每条用例映射回 `prd.md` 的 FR / 验收标准 / MUST / MUST NOT。
> 审阅指引：开发者先读本文件判断“AI 是否真的懂了什么叫全自主自动编排”，再读 PRD §6 勾选是否做完。

---

## TC1 · 一个命令覆盖从需求到复盘的全流程
- **映射**：FR1 / FR2
- **Given**：仓库新增了 `/sandtable-autopilot` 命令与 `skills/autonomous-orchestration/SKILL.md`。
- **When**：开发者给出一句原始需求后触发 `/sandtable-autopilot`。
- **Then**：命令说明与 skill 明确写出流程从 `INTAKE/RECON/OBJECTIVES/TESTCASES/PLAN` 一直推进到 `MENTAL_REHEARSAL/REDTEAM/IMPL_REHEARSAL/EVALUATE`，不是“做到计划后提示用户自己继续”。
- **状态**：待验证

## TC2 · 自动模式默认不逐步等人确认
- **映射**：FR1 / FR5 / MUST NOT“不把需要开发者确认每一步包装成自动化”
- **Given**：自动模式的 skill 与命令文案。
- **When**：人阅读自动模式的执行规则。
- **Then**：正常路径写明“主 agent 自主决定下一步，不向开发者逐步请示”；只有真正阻塞（缺产品意图、权限、登录、批准等）才写 `questions.md` 并停下。
- **状态**：待验证

## TC3 · 头脑预演至少三轮且每轮至少三个子 agent
- **映射**：FR3 / MUST“mental 3x3”
- **Given**：自动模式配置写入 skill / state 模板。
- **When**：人读自动模式的配额定义与 `state.md` 持久化字段。
- **Then**：能明确看到 mental 最低配额是 `3` 轮、每轮至少 `3` 个只读子 agent；若某轮发现 anomaly，文档要求先修正再补足轮次，不能直接把该轮算过。
- **状态**：待验证

## TC4 · 红蓝对抗至少三轮且每轮至少三个红军子 agent
- **映射**：FR3 / MUST“redteam 3x3”
- **Given**：自动模式配置写入 skill / state 模板。
- **When**：人读自动模式的对抗规则。
- **Then**：能明确看到 redteam 最低配额是 `3` 轮、每轮至少 `3` 个红军子 agent；每轮都要求指定攻击向量并记录 `HELD` / `BREACH_FOUND`；若被攻破，先写回修正再补足轮次。
- **状态**：待验证

## TC5 · 实现预演至少两轮且每轮至少两个独立 worktree 子 agent
- **映射**：FR3 / MUST“impl 2x2”
- **Given**：自动模式配置写入 skill / state 模板。
- **When**：人读实现预演编排规则。
- **Then**：能明确看到 impl 最低配额是 `2` 轮、每轮至少 `2` 个独立 worktree 子 agent；只要有 `ANOMALY_FOUND` / `BLOCKED` 就必须回修正循环，全部 `DONE` 后才进入复盘择优。
- **状态**：待验证

## TC6 · 自动模式状态可恢复
- **映射**：FR6 / 验收“持久化打通，中断后可续”
- **Given**：更新后的 `templates/state.md`、`skills/state-and-memory/SKILL.md`、`commands/sandtable-status.md` 与 `commands/sandtable-resume.md`（含 Cursor 副本）。
- **When**：人阅读状态模板与恢复说明。
- **Then**：`state.md` 里存在自动模式相关字段（至少包括 `autonomy.mode`、最低轮次、每轮最少子 agent 数、已完成轮次、最近自动决策）；并明确“进入 autopilot / 每次自动推进 / 每次回退重演”都会同步写回这些字段与 `phase`；`/sandtable-status` 与 `/sandtable-resume` 都明确会读取这些字段，而不是只看传统汇总计数。
- **状态**：待验证

## TC7 · 真阻塞才问人，普通异常自动修正
- **映射**：FR4 / FR5
- **Given**：自动模式的异常处理规则。
- **When**：人分别阅读“异常”“阻塞”两类处置。
- **Then**：普通 `ANOMALY_FOUND` / `BREACH_FOUND` 会进入“亲自核实 → 写回 PRD/tests/plan/state/journal → 重演”；子 agent 返回 `BLOCKED` 时会先被主 agent 分类，只有读代码与文档仍无法确认的需求、权限、登录、批准等外部依赖才会升级为 `blocked=true` 并向开发者提问，其余 `BLOCKED` 按内部可修正阻塞回修正循环。
- **状态**：待验证

## TC8 · 全仓索引与手动入口保持自洽
- **映射**：FR7 / FR8
- **Given**：新增了 autopilot skill/command 的仓库。
- **When**：`rg -n "autopilot|autonomous-orchestration|全自动|无人值守" README.md AGENTS.md .cursor/rules/sandtable.mdc skills/using-sandtable/SKILL.md commands .cursor/commands docs/sandtable/project.md`
- **Then**：README 的命令表与目录结构、总入口 skill、AGENTS、Cursor rule、命令目录、project.md 都能找到对应入口与描述；同时仍保留 `/sandtable-start`、`/sandtable-rehearse` 等手动命令，不存在“文档有 autopilot 但命令缺失”或“新增入口后手动入口消失”的情况。
- **状态**：待验证
