# 头脑预演报告 · 轮 6

结果：`ANOMALY_FOUND`

## 背景
- 在第 5 轮继续修补 `prd.md` / `tests.md` / `plan.md` 后，再次执行 `/sandtable-mental`。
- 本轮不再大范围扫描，只聚焦两类剩余断点：
  1. `autopilot` 前序预授权与 `<AUTOPILOT-OVERRIDE>` 的计划落地；
  2. `TC8 / T5 / T6` 的验证口径是否足以防止“关键词命中即通过”的假阳性。

## 本轮结论
- **前序预授权与推演链回退规则已基本闭环。**
  - `prd.md`、`tests.md`、`plan.md` 对 `INTAKE + RECON + OBJECTIVES + TESTCASES + PLAN` 的前序流程定义、`<AUTOPILOT-OVERRIDE>` 的覆盖对象、以及推演链 `MENTAL_REHEARSAL` 回退与 `completed_rounds` 清零条件，已基本一致。
- **剩余 anomaly 只集中在 TC8 / T5 / T6 的可执行验收口径。**
  - `TC8.When`、`T5`、`T6` 虽然都已经有“正向 + 负向 + 存在性”检查，但三者还没有完全对齐。
  - 仍存在几类风险：
    1. `T5` 的检查弱于 `TC8`，执行者若只跑 `T5` 可能误判“TC8 已通过”；
    2. `rg` 模式里把 `sandtable-mental|sandtable-redteam|sandtable-live` 与 start/rehearse 边界条件混在同一条 OR 里，仍可能让边界检查被无关命中绕过；
    3. `只串` / `仅串起` / `可一键串起` 等表述还没有被同一套正则和负向词表完全收束；
    4. `T6` 的 smoke 检查仍弱于 `TC8` / `T5` 的最严格版本。

## 本轮已完成的修补
- `prd.md`
  - 把 MUST 补成含 `INTAKE` 的完整前序流程。
  - 把 `FR3` 与 `FR4` 的推演链异常处理口径进一步统一。
- `tests.md`
  - TC2 补入 `project.md` / `constraints.md` 自主初始化例外。
  - TC4 明确被攻破后回到 `MENTAL_REHEARSAL` 再补足整条推演链。
  - TC8 升级为更强的“正向 + 负向 + 文件存在性”三段式检查，并把 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-mental`、`/sandtable-redteam`、`/sandtable-live` 的保留都纳入验收。
- `plan.md`
  - 修正了 `T3` 对 `completed_rounds` 清零条件的旧措辞。
  - 把 TC2 的验证从 T1 挪到 `<AUTOPILOT-OVERRIDE>` 写入之后。
  - 继续扩展 T5/T6 的负向词表与命令存在性检查。

## 当前剩余未闭合点
- 要想真正拿到 `LOGIC_CLOSED`，下一轮只需做一件事：
  - **把 `TC8.When`、`T5`、`T6` 的检查命令完全对齐成同一套最严格口径**，特别是：
    1. 把 start/rehearse 边界命中从 OR 模式拆成独立必选条件；
    2. 统一 `只串` / `仅串` / `可一键串起` 的字面与负向词表；
    3. 让 `T6` 至少不弱于 `TC8` / `T5` 的最强版本。

## 结论
- 本轮不进入 `REDTEAM`。
- 当前需求仍停留在 `MENTAL_REHEARSAL`，但异常已经收敛到单一、很窄的“验收口径”问题；再做一轮很小的文档修补与只读复核，就有机会拿到 `LOGIC_CLOSED`。
