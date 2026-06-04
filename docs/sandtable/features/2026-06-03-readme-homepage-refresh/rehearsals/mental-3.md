# MENTAL_REHEARSAL 轮 3 · README 首页重塑（实现层风险）

## 结论
`ANOMALY_FOUND`

本轮从 3 个实现层视角并行审查“真正改 README 时最容易失手的地方”，至少 1 个子 agent 返回 anomaly，且主 agent 已核实成立，因此本轮不计入 autopilot 的有效 `mental` 轮次。

## 已核实异常

1. **顶部实现骨架仍不够硬**
   - 表现：虽然已有前两屏优先级，但之前缺少固定的 README 顶部骨架、旧 section 处置清单和 section 级预算。
   - 风险：实现者容易把新首页叠在旧正文上，导致首屏顺序漂移、行数失控。
   - 处置：已在 `plan.md` 中补入 README 骨架、旧 section 处置清单和 160 行 section 预算。

2. **试用流默认路径与 Cursor caveat 保护不足**
   - 表现：之前只要求“有试用入口”，没有固定默认推荐路径，也没有把 Cursor 本地插件不会自动加载项目级规则的 caveat 升成受保护事实。
   - 风险：读者被说服后还要先做选择题，或按本地插件路径试用后误以为规则失效是仓库问题。
   - 处置：已在 `prd.md/tests.md/plan.md` 中补入默认推荐路径、Cursor caveat 保护和顺读式验收脚本。

3. **措辞与结果句仍可能滑向软营销**
   - 表现：之前虽然压住了无证 superiority claim，但还没有把对比两句制、结果句锚点、红线失败条件彻底写进 PRD / tests / plan。
   - 风险：README 可能结构合规，却仍混入“更像真正方法论”“少返工”“更值得试”之类软性结论。
   - 处置：已在 `prd.md/tests.md/plan.md` 中补入两句制逐点事实模板、结果句必须回指事实、以及红线可判失败化。

## 主 agent 裁决
- 本轮 anomaly 已完成核实并回写到 `prd.md` / `tests.md` / `plan.md` / `journal.md` / `state.md`。
- `autonomy.completed_rounds.mental` 维持 `1/3`。
- 下一步：按新约束重跑第 2 轮 mental，验证这些实现层护栏是否已经闭环。
