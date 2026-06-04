---
feature: 2026-06-03-readme-homepage-refresh
phase: VERIFY
blocked: false
updated: 2026-06-04T10:54:00+08:00
tasks:
  - { id: T1, title: 重构 README 首屏叙事, status: done }
  - { id: T2, title: 加入明确流程图与差异化对比, status: done }
  - { id: T3, title: 保留试用路径并补上自举证明, status: done }
  - { id: T4, title: 文案终审与 GitHub 呈现检查, status: done }
rehearsals:
  mental:  { runs: 8, last: closed }
  redteam: { runs: 3, last: held }
  impl:    { runs: 0, last: none }
autonomy:
  mode: manual
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 1, redteam: 0, impl: 0 }
  last_decision: 开发者进一步确认首页不应过度强调 /sandtable-autopilot；README 与 feature 文档已把前置记忆点收口为“推演 + 自我完善 + 自举”主导
selected_impl: none
---

## 当前进展
已为“README GitHub 首页重塑”建立新 feature，并完成侦察、PRD、测试用例和改动计划。开发者随后显式要求跳过剩余 autopilot 预演配额与 `/sandtable-live` 的隔离 worktree 语义，直接在主工作区实现 `README.md`；当前成稿已修复实现级 redteam 打出的 breach，并通过定点复打，处于 `VERIFY`。

## 关键决策（最近）
- 采用“重构 README 首页信息架构”而不是只追加几段卖点。
- `superpowers` 对比只允许写重心差异与 Sandtable 的前置记忆点，不允许失实贬低。
- 前两屏只优先服务“为什么值得试”“如何闭环防失控”两个判断题，流程图必须紧接首屏。
- `superpowers` 对比只允许“已核实事实 + 重心差异 + 读者先感知到什么”，禁止无证优越性判断词。
- `superpowers` 对比中的每个对比点都必须带事实锚点，不能只做整块语气约束。
- Cursor 默认试用路径已再次写死为“让 AI 读 `INSTALL.md` 并自助安装”；手工拷 `.cursor/` 只作备选可靠路径。
- `Quickstart` 已被收紧为唯一试用落点；前两屏试用锚点不能再跳向独立“安装 / 接入”区块。
- README 中涉及 `superpowers` 的比较句，只允许出现在“前两屏 1 条微对比”或正式对比区块；`Why` 等其它 section 不得再夹带比较句。
- Cursor 默认路径的 `Quickstart` 子块必须显式写出“重载窗口/重开工作区，使 `alwaysApply` 生效”这一步，不能只藏在 `INSTALL.md`。
- 当前 README 成稿已压缩为约 110 行，并完成 token/结构核对；后续若继续手动推进，应在 `VERIFY` 基础上做最终人工审读或再开一轮针对成稿的红队。
- 当前 README 已通过实现级 redteam 复打；上一轮打出的正式对比位置、首屏记忆点、试用摘要顺序、流程图闭环与本地插件语境问题均已收口。
- README 的默认试用路径现统一为“把一句安装指令发给 AI，让它阅读 `INSTALL.md` 并安装到当前项目”；不再在首页展开 `Claude Code marketplace` 或 `Cursor` 分栏。
- 首屏记忆点已去掉对 `/sandtable-autopilot` 的过度前置，改为强调“推演会反过来改进方法论”这一自我完善特征。
- 本次实现范围限定在 `README.md` 与本 feature 文档。
