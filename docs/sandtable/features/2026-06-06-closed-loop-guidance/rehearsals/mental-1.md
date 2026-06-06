# MENTAL_REHEARSAL 轮 1 · 回合收尾与下一步引导

**信号：`ANOMALY_FOUND`**（3/3 子 agent 上报；主 agent 核实后已修 plan/prd/tests）

## 子 agent 摘要

| 链路 | 信号 | 核心发现 |
|------|------|----------|
| T1+T2 核心 skill | ANOMALY | OBJECTIVES 待确认无模版；异常回退缺 OBJECTIVES；FR8/TC8b 与「每回合」措辞冲突；TC6 依赖 T3 sandtable-start |
| T3 commands/autopilot | ANOMALY | T3 3.5 vs 步骤8 输出时机矛盾；四段 vs 战报未定义；start 步骤4 无暂停收尾 |
| T4 locale 镜像 | ANOMALY | en command 须 39 文件非 26；rg 过窄；state T2 误写 session-start |

## 主 agent 处置

已修正 `plan.md`、`prd.md`、`tests.md`：
- 两种 profile（完整收尾 / 战报收尾）
- OBJECTIVES·PRD待确认 子状态 + writing-prd 交叉引用
- sandtable-start 步骤4 暂停 + 步骤7 终局
- FR8 正负触发；T4 39 文件清单
- autopilot/rehearse 链内纪律统一

## 下一步

重跑 mental-2 验证修补 → 见 `mental-2.md`
