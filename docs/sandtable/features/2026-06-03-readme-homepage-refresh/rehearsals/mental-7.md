# MENTAL_REHEARSAL 轮 7 · README 首页重塑（第 3 轮压力测试终复核）

## 结论
`LOGIC_CLOSED`

本轮在收口 `FR6` 互斥版本与 `plan.md` 首屏边界冲突后，再次并行派出 3 个只读子 agent 重跑第 3 轮 mental。3 个方向全部返回 `LOGIC_CLOSED`，因此本轮计入 autopilot 的有效 `mental` 轮次。

## 审查范围
- 首次访客在前两屏内是否能同时看懂价值主张、闭环防失控逻辑、以及 Sandtable 与 `superpowers` 不是同题复述。
- 对比区块两句制、首屏/Why 句级锚点、微对比边界与整版文案红线是否已形成可执行且可验收的闭环。
- 首屏试用摘要、前两屏单跳到同一 `Quickstart`、Claude Code / Cursor 默认与备选路径、以及 Cursor 本地插件 caveat 是否已互相对齐。

## 结果
1. **首页理解护栏**：通过  
   - `prd.md`、`tests.md`、`plan.md` 已把首屏边界、闭环图白话解释、前两屏微对比与优先级顺序同时写死，不再留下实现漂移空间。

2. **文案与对比护栏**：通过  
   - 两句制逐点对比、句级事实锚点、无锚点优越词/点评句/口号句禁令，已同时具备 PRD 约束、测试失败条件与终审动作。

3. **试用路径护栏**：通过  
   - Cursor 默认路径已统一为“让 AI 读 `INSTALL.md` 并自助安装”，手工拷 `.cursor/` 仅为备选可靠路径；前两屏单跳到同一 `Quickstart` 的三件套要求也已在文档层闭环。

## 主 agent 裁决
- 这轮 `mental` 满足“至少 3 个只读子 agent，且全部 `LOGIC_CLOSED`”。
- `autonomy.completed_rounds.mental` 现可加到 `3/3`。
- 下一步：切换到 `REDTEAM`，开始第 1 轮红蓝对抗，继续攻击 README 首页方案的事实边界、试用链路与实现落地风险。
