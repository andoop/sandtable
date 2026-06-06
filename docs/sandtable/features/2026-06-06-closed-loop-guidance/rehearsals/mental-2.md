# MENTAL_REHEARSAL 轮 2 · 回合收尾与下一步引导（修补后复核）

**信号：`LOGIC_CLOSED`**

## 复核范围

修补后的 `plan.md`、`prd.md`、`tests.md`；对照 mental-1 九项 anomaly。

## 端到端逻辑链

1. 本回合触达 `docs/sandtable/` → 读 `state.md` → 加载 `closing-the-loop`（`plan.md` T1）
2. **profile 分流**：manual/blocked/PRD待确认/命令边界 → 完整四段 + AskQuestion（`prd.md` FR2/FR3）；autopilot 链内切换 → 战报收尾 + 同命令续跑（`plan.md` T3 3.5）；命令结束或 blocked → 完整收尾（`plan.md` T3 步骤8）
3. **sandtable-start**：步骤4 OBJECTIVES 后暂停完整收尾（`plan.md` T3 2a）；步骤7 PLAN 终局收尾（`tests.md` TC6）
4. **writing-prd 门禁**：OBJECTIVES 待确认不得推 TESTCASES（`plan.md` 映射 L89）
5. **负触发**：未读写 sandtable 的非 Sandtable 任务 → 禁止收尾（`prd.md` FR8、`tests.md` TC8b）
6. **分发**：`using-sandtable`/rules/commands + `plugins/sandtable` + en 39 commands；不改 `session-start`（`plan.md` T4 L211）

## 红线核对

| 红线 | 结论 |
|------|------|
| 不写入用户 templates/ | ✅ skill 在插件 skills/ |
| 不硬编码 session-start | ✅ MUST NOT + T4 明示 |
| 不改无关 skill Red Flags 表 | ✅ state-and-memory 仅追加索引段 |
| autopilot 不 AskQuestion 打断 | ✅ FR4 + 战报 profile |
| 零 node/python 脚本 | ✅ 纯 markdown skill |

## 已检查边界/异常路径

- OBJECTIVES PRD 待确认 vs 已确认子状态
- autopilot PLAN→MENTAL 阶段切换（TC3）
- blocked + questions.md（TC4）
- rehearse 链内中间 vs 命令结束（T3 2b）
- 异常回退 FIX→OBJECTIVES（TC5）
- en 安装 TC7 路径完整性（T4）

## 残余风险（不足 anomaly）

- TC8 未显式断言「不得推荐 TESTCASES」——约束在 plan 映射表，实现时易漏
- rehearse 链内「战报或省略」与 FR1 字面略歧义；实现宜统一为至少战报
- 无独立 TC 测 autopilot **命令完全结束**时的完整收尾
- 多路径镜像（13+26+39）人工验证成本高

## 结论

mental-1 九项 anomaly 已在文档层收口。可进入 `/sandtable-redteam` 或 `/sandtable-live`。
