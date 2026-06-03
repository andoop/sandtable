# 头脑预演报告 · 轮 5

结果：`ANOMALY_FOUND`

## 背景
- 在 `mental-4.md` 完成一轮大范围计划修补后，再次执行 `/sandtable-mental`。
- 本轮继续使用只读子 agent，重点复核三条剩余链路：
  1. autopilot 前序流程预授权与 `<AUTOPILOT-OVERRIDE>`；
  2. 前序流程 / 推演链的回退与 `completed_rounds` 规则；
  3. TC8 与 T4/T5/T6 的边界验证口径。

## 本轮确认成立的 anomaly
1. `plan.md` 的局部条目仍残留旧口径，和 `prd.md` / `tests.md` 的新规则打架：
   - `T3` 一度还写着“因修正前序产物回退到 `MENTAL_REHEARSAL` 才清零 `completed_rounds`”，
   - 但 `prd.md` / `tests.md` / `T1` 已明确为“进入推演链后，只要需要写回文档再重演，就统一回 `MENTAL_REHEARSAL` 并清零三类推演轮次”。
2. `FR3` 的“补足该阶段最低配额”与 `FR4` 的“推演链统一回 `MENTAL_REHEARSAL`”曾有字面冲突，容易让执行者误判为 redteam/impl 只补本阶段。
3. `TC2` 与计划中的 `<AUTOPILOT-OVERRIDE>` 覆盖对象仍不够严：
   - 需要显式覆盖的手动命令不只 `/sandtable-start` / `/sandtable-objectives`，
   - 还应包含 `/sandtable-recon`、`/sandtable-plan`、`/sandtable-resume`，以及“缺少 `project.md` / `constraints.md` 时是否允许 autopilot 初始化”的全局确认节点。
4. `TC8` 与 `T5/T6` 的验证仍存在“只因出现 autopilot 关键词就误判通过”的风险：
   - 负向 `rg` 模式曾窄于 T4，
   - `mental/redteam/live` 的保留未被显式纳入文件存在性检查，
   - `project.md` 计数与全局索引虽然被要求更新，但验证口径一度没有同时覆盖正向、负向、存在性三类检查。

## 本轮已完成的修补
- `prd.md`
  - 把 FR3 改成与 FR4 配套：前序流程异常补足前序阶段后的后续流程；推演链异常统一回 `MENTAL_REHEARSAL` 后补足整条推演链。
  - 把 MUST 中“自动流程必须覆盖 `RECON / OBJECTIVES / TESTCASES / PLAN`”补成含 `INTAKE` 的完整前序流程。
- `tests.md`
  - TC2 补入：缺少 `project.md` / `constraints.md` 时，autopilot 可按模板自主初始化，除非触发 FR5 真阻塞。
  - TC4 明确：被攻破后回到 `MENTAL_REHEARSAL`，重新补足整条推演链最低配额。
  - TC8 升级为三段式检查：正向 `rg`、负向 `rg`、命令文件存在性检查；并显式把 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的保留纳入验收。
- `plan.md`
  - 修正 T3 对 `completed_rounds` 的旧触发条件，使其与 PRD / TC6 / T1 一致。
  - 把 T1 的验证拆开：TC1/TC3/TC4/TC5 仍在 T1；TC2 改由 T3.5/T3.6 在 `<AUTOPILOT-OVERRIDE>` 写入后验证，避免“先验后写”。
  - 收紧 T5/T6：把负向 `rg` 扩展到 `澄清→PRD→用例→计划→预演`、`串起三类推演 + 复盘` 等旧表述，并加入 `/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的 `test -f` 存在性检查。

## 当前仍未闭合的点
- 本轮最后一批修补完成后，尚未再次发起新的只读子 agent 复核，因此这些最新修补是否完全消除剩余矛盾，还没有新的独立证据。
- 下一轮只需复核两类点即可：
  1. `prd.md` / `tests.md` / `plan.md` 是否已在“推演链回退触发条件”上彻底一致；
  2. TC8 / T5 / T6 的正向、负向、存在性检查是否已经足够强，不会再被“只出现 autopilot 关键词”的假阳性绕过。

## 结论
- 本轮不进入 `REDTEAM`。
- 主 agent 已完成 anomaly 的核实与文档修补，但当前需求仍保持在 `MENTAL_REHEARSAL`，待下一轮只读复核确认无剩余计划级断点后，才能转入红蓝对抗。
