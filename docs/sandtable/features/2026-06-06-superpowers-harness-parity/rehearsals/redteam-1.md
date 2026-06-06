# 红蓝对抗 #1 · 攻击计划

**日期:** 2026-06-06  
**目标:** `plan.md`（实现尚未开始）  
**OPFOR 配置:** 3 个子 agent 并行（假设斩首 / 需求背离 / 红线渗透）  
**主 agent 裁决:** 全部杀招经亲自核实 **成立** → 登记 ANOMALY → 已修正 plan/tests

---

## 信号

**初始:** `BREACH_FOUND`（4 条致命/严重杀招 + 2 条验证盲区）  
**修正后:** 待 `redteam-2` 或实现预演复验；本轮 plan 已按 ANOMALY 加固

---

## 攻破清单（已核实）

### ANOMALY-1 · OpenCode 缺工具映射 → 三类推演断链
- **攻击向量:** 假设斩首 / FR6 渗透
- **复现:** 按原 T2 实现 OpenCode plugin（仅注入 `using-sandtable`）→ 触发 `/sandtable-mental` → 加载 `mental-rehearsal-prompt.md:6` 要求 `Task tool` → OpenCode 无此工具 → 子 agent 无法派发
- **证据:** `superpowers/.opencode/plugins/superpowers.js:76-83` 有映射；原 `plan.md` T2 仅两件事；`sandtable/skills/*/*-prompt.md:6-7`
- **严重度:** 致命
- **修正:** T2 步骤 3/4 要求注入 OpenCode 工具映射；T5 增补 `Task|Tool Mapping` rg；TC4 增补 bootstrap 映射验收

### ANOMALY-2 · Gemini 缺 gemini-tools → 同上断链
- **攻击向量:** 假设斩首 / FR7 渗透
- **复现:** 按原 T3 仅 `@using-sandtable` → 触发 `/sandtable-redteam` → `opfor-prompt.md:7` 要求 `Task tool` → 无 Gemini 映射
- **证据:** `superpowers/GEMINI.md:1-2` 双文件；原 T3 步骤 3 用「若实现时发现」推迟决策
- **严重度:** 致命
- **修正:** 文件地图 + T3 明确创建 `skills/using-sandtable/references/gemini-tools.md`；GEMINI.md 双 `@`；TC5 扩充

### ANOMALY-3 · T1 未强制摘除 AI-first 首屏 → TC1/TC3
- **攻击向量:** 需求背离
- **复现:** 在 `README.md:21` 后插入矩阵、保留 `:10-20` → 读者第一眼仍是「立刻试用」→ TC1 FAIL
- **证据:** `sandtable/README.md:10-20,45,61-78`；原 T1 步骤 1 仅写「改成」
- **严重度:** 严重
- **修正:** T1 步骤 1 点名移除/替换三处 AI-first 落点；T5 负向检查首屏

### ANOMALY-4 · Cursor `/add-plugin` 无 Q3 guard → TC7
- **攻击向量:** 需求背离 / 红线渗透
- **复现:** 照抄 `superpowers/README.md:132-138` 为 sandtable、省略「发布后可用」→ TC7 FAIL；T5 rg 不检测
- **证据:** T1 步骤 4b 未覆盖 Cursor；仓内无 Cursor marketplace 上架证据
- **严重度:** 严重
- **修正:** T1 步骤 3 增加 Cursor 诚实措辞 guard

### ANOMALY-5 · T4 未约束 INSTALL §5.2 → TC9
- **攻击向量:** 需求背离 / 侧翼包抄
- **复现:** README Cursor 写 marketplace；INSTALL `§5.2:176-186` 仍写复制 `.cursor/*` 且无交叉标注 → TC9 互斥
- **严重度:** 严重
- **修正:** T4 步骤 3b 重写 §5.2 层级与 README 交叉引用

### ANOMALY-6 · T5/TC7 扫描范围过窄 → companion files 可漏 superpowers 串
- **攻击向量:** 红线渗透
- **复现:** 仿抄 `superpowers/.opencode/INSTALL.md` 保留 `superpowers@git` URL → 原 T5 rg 仅扫根 README/INSTALL → 通过
- **严重度:** 一般
- **修正:** T5 扩展负向 rg 至 `.opencode/`、`GEMINI.md`、`gemini-tools.md`；TC7 Then 扩至全部安装产物

---

## 未攻破向量（修正后信心依据）

| 向量 | 为何原 plan 可被破 | 修正后 |
|------|-------------------|--------|
| 边界突袭 | OpenCode/Gemini 无映射 | T2/T3 已锁映射 |
| 回归伏击 | 未动 hooks/插件 JSON | 计划仍只改文档+companion files |
| 范围蔓延 | T3 步骤 3 授权临场扩 scope | 已改为显式文件地图 |

---

## 头脑预演遗留纠正

`mental-1.md:45-50` 断言「Sandtable 无需 OpenCode/Gemini 工具映射」**已被本轮回放证伪**；该断言不得再作为实现依据。

---

## 下一步

- 可选 `redteam-2` 对修正后 plan 复打
- 或进入 `/sandtable-live` 实现预演
