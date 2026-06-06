# 待开发者澄清 · Questions

> 仅放“读代码、读文档都无法确定，必须开发者拍板”的阻塞性问题。
> 有未解决的问题时，`state.md` 的 `blocked` 应为 `true`。

## Q1（状态：已答复）
- 问题：这次“完全跟 superpowers 对齐”里，**哪些 harness 需要纳入首期范围**？是严格镜像 `superpowers` 当前 8 个对象（`Claude Code`、`Codex CLI`、`Codex App`、`Factory Droid`、`Gemini CLI`、`OpenCode`、`Cursor`、`GitHub Copilot CLI`），还是保留 `sandtable` 现在额外强调的 `Kiro / 通用 agent` 作为附加支持对象？
- 为什么阻塞：这会直接决定 PRD 的支持矩阵、README/INSTALL 的结构、需要新增哪些 repo-side 资产，以及“完全对齐”到底是“严格同名单”还是“同方式 + 保留额外对象”。
- 我已尝试的确认途径：核读了 `sandtable/README.md`、`sandtable/INSTALL.md` 与 `superpowers/README.md` 的安装小节；两边当前列出的对象并不一致。
- 可选项（若有）：
  - A. 严格镜像 `superpowers` 的 8 个对象，不再把 `Kiro / 通用 agent` 作为主支持矩阵的一部分。
  - B. 以 `superpowers` 的 8 个对象为必选，同时保留 `Kiro / 通用 agent` 作为 Sandtable 的附加支持对象。
- 开发者答复：选 `B`。以 `superpowers` 的 8 个对象为必选，同时保留 `Kiro / 通用 agent` 作为 Sandtable 的附加支持对象。
- 已写回：`journal.md` 2026-06-06 12:49 条目；待写入 `prd.md` / `tests.md` / `plan.md`。

## Q2（状态：已答复）
- 问题：首期是否要把 **README 的主安装叙事** 从当前“让 AI 读取 `INSTALL.md` 自助安装”改成像 `superpowers` 那样**按 harness 分栏的原生安装路径**，并把 AI 自助安装降为次级/备用路径？
- 为什么阻塞：这会改变 README / INSTALL 的主结构、验收标准和“第一推荐入口”。如果继续以 AI 自助安装为主，就不是“跟 superpowers 一样方式”的首页体验；如果改成 harness-first，则需要重新定义 AI 自助安装在文档中的位置。
- 我已尝试的确认途径：核读 `sandtable/README.md:10-20,61-78` 与 `superpowers/README.md:31-152`；两者当前主叙事明显不同。
- 可选项（若有）：
  - A. 首页主路径改成和 `superpowers` 一样的 harness-first 安装矩阵，AI 自助安装放到补充/备用路径。
  - B. 保留 Sandtable 当前“AI 读 `INSTALL.md`”为主路径，只要求具体支持矩阵和 repo-side 接线尽量向 `superpowers` 靠拢。
- 开发者答复：选 `A`。README 主路径改成像 `superpowers` 一样的 harness-first 安装矩阵，AI 自助安装降为次级路径。
- 已写回：`journal.md` 2026-06-06 12:49 条目；待写入 `prd.md` / `tests.md` / `plan.md`。

## Q3（状态：已作废 → 见 Q4）
- 原答复 `A`（仅 repo-side）已被开发者 2026-06-06 新指令废止。

## Q4（状态：已答复）
- 问题：是否要把完成标准从「repo-side + 诚实 pending」扩到「**完整对齐 superpowers，含插件发布到各 marketplace**」？
- 开发者答复：**是。** 要完整方案、完整一样跟 Superpowers，包括插件发布到市场等。
- 已写回：`prd.md` §1/§3、`plan.md` Phase 2–4、`tests.md` TC10–TC14、`journal.md`。

## Q5（状态：已作废 — feature 终止）
- feature 已终止，不再执行。

## Q6（状态：已作废 — feature 终止）
- feature 已终止，不再执行。
