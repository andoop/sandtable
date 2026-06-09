# MENTAL_REHEARSAL 轮 9 · mental-8 修正后重演

**信号:** `ANOMALY_FOUND`

## 范围

mental-8 修正 `plan.md` 后，重新并行派发 3 个只读子 agent：

- T1/T2：A13/B28、manual→autopilot、TC2/TC9-TC11。
- T3/T8：A14/B26、behavior baseline、TC5/TC16/TC18。
- 全局：TC1-TC20、MUST/MUST NOT、镜像同步、live 完整性闸门。

## 结果

T1/T2 与全局检查返回 `LOGIC_CLOSED`；T3/T8 返回 `ANOMALY_FOUND`。

## 异常与修正

### A15 · behavior baseline 核心闭环段落残留 blanket 表述

- 问题：T3 步骤3.6 已要求收窄 behavior baseline 的预演铁律，但未显式覆盖“核心闭环/状态机摘要”段落里的“异常/意外 → 上报”、`unexpected fact`、`surprise` 等 blanket 表述；验证词也漏 `意外` / `surprise`。
- 后果：alwaysApply 基线仍可能压过 mental 新口径，打穿 TC5。
- 修正：T3 步骤3.6 明确同步处理 behavior baseline 核心闭环段落；验证搜索词补入 `意外`、`surprise`、`anomaly or unexpected` 等。

## 已闭环项

- A13/B28 已闭环：autopilot 与 resume 都会在三文档未齐备时先补齐文档。
- A14 已闭环：behavior baseline 五份文件已进入 T3 任务级清单与 T8 核对范围。
- B25、B27、B29 已闭环。

## 下一步

`plan.md` 已修正 A15。需重新运行 mental，再运行 redteam；两者闭环后才能进入 implementation rehearsal。
