# REDTEAM 轮 1 · 回合收尾与下一步引导（打计划）

**信号：`BREACH_FOUND`**（3/3 OPFOR 上报；主 agent 核实后修补 plan/prd/tests）

**目标**：计划层（尚无实现）  
**专攻向量**：autopilot 战报边界 · start 步骤4 · FR8/TC8b · 39 文件镜像

---

## 成立杀招（主 agent 核实）

| # | 攻击向量 | 杀招 | 严重度 | 处置 |
|---|----------|------|--------|------|
| 1 | 需求背离 | `plan.md` rehearse「战报**或省略**」击穿 FR1 | 严重 | 改为禁止省略，链内至少战报 |
| 2 | 边界突袭 | autopilot 命令终局无 TC，step7 散文可冒充收尾 | 严重 | 新增 TC10；plan 替换非追加 autopilot 步骤7 |
| 3 | 红线渗透 | OBJECTIVES 样例 L108 推荐 TESTCASES，违反 L89 + writing-prd | 致命 | 改样例；TC8 增补禁令 |
| 4 | 假设斩首 | start 命令 1→7 连续 vs plan 步骤4「结束本回合」 | 严重 | plan 重写 start 结构：步骤4 命令结束 |
| 5 | 侧翼包抄 | rules「每回合收尾」无 FR8 负触发 vs alwaysApply | 严重 | T2 改为内嵌 FR8 正负触发 |
| 6 | 反例攻击 | FR8 缺第三态：已读 sandtable 但非 Sandtable 任务 | 一般 | prd FR8 增补第三态；TC8b 放宽 Given |
| 7 | T1 内部矛盾 | EVALUATE 映射「无 slash」违反 MUST 可复制模版 | 一般 | 映射改为确认落地/status 模版 |
| 8 | 回归伏击 | T3 漏 `plugins/sandtable/commands`；VERIFY rg 可假绿灯 | 严重 | T3/T4/VERIFY 补镜像与 `rg -L`/`diff` |
| 9 | 边界突袭 | autopilot+blocked AskQuestion 纪律空洞 | 一般 | HARD-GATE：blocked 优先 FR5 |

## 未成立 / 设计张力（记录，非 anomaly）

- **战报收尾无完整模版 vs PRD 北极星**：FR2 已授权战报 profile 省略模版；autopilot 链内切换属刻意不打断（TC3）。用户价值在终局完整收尾（TC10 已补）。
- **T3 3.5 vs 步骤8 时机**：mental-2 已用双 profile 收口，本轮未再攻破。

## 蓝军修补摘要

- `plan.md`：start 结构、autopilot 步骤7 替换、rehearse 禁止省略、plugins 镜像、强验证
- `prd.md`：FR8 第三态 + rules 负触发
- `tests.md`：TC8 禁令、TC10 终局、TC8b Given

## 下一步

建议 **redteam-2** 复打同一向量，确认修补后 `HELD`。
