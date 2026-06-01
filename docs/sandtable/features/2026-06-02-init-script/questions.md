# 待开发者澄清 · Questions

## Q1（状态：待答复，已采用推荐默认推进）
- 问题：feature 的 slug 是否限定为英文 kebab-case（`[A-Za-z0-9-]`），中文/特殊字符一律拒绝？
- 为什么阻塞：slug 进目录名和 `state.md` 的 YAML `feature:` 值。`/ . : & |` 等会导致路径错位、sed 损坏、YAML 误解析（红蓝对抗已复现）。
- 我已尝试的确认途径：读 `skills/state-and-memory/SKILL.md`（目录命名 `<YYYY-MM-DD>-<slug>`，未规定字符集）；本机复现 sed/date 行为。
- 可选项：
  - A.（推荐）限定英文 kebab-case，非法报错；需求中文名写进 `prd.md` 标题。最简、最安全、跨平台稳。
  - B. 允许中文等更宽字符，但需对 sed 转义 + YAML 加引号 + 禁 `/`/`..`。更复杂。
  - C. 允许任意，自动 slugify（把空格/非法字符转 `-`）。有"猜测用户意图"的风险。
- 开发者答复：（待）
- 已写回：采用 A 作为推荐默认 → prd.md FR1/MUST、plan.md T1 步骤1。开发者若选 B/C 再回到 refine。
