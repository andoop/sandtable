# 头脑预演 #4 · 状态机一致性（轮2重演）→ ANOMALY_FOUND（已补 T10）

**结论:** 上轮 6 异常计划层已覆盖、无假锚点、六命令双副本同源成立；但发现更细遗漏，已补任务 T10。

## 仍遗漏（已核实属实，纳入 T10）
- `skills/using-sandtable/SKILL.md:88` 异常写回清单仅 `prd.md/plan.md`。
- `skills/being-truthful/SKILL.md:44` 同上。
- `commands/sandtable-mental.md:8/:10`（+ .cursor 副本）读取/修正清单无 tests.md。
- `commands/sandtable-rehearse.md:10`（+ 副本）修正清单无 tests.md（与 T7 合并）。
- frontmatter 描述走旧序列：`commands/sandtable-start.md:2`、`skills/writing-prd/SKILL.md:3`、`skills/writing-plan/SKILL.md:3`。

## 已确认正确
- 6 命令双副本逐字同源（抽样 objectives/plan），T7 diff 验证可行。
- 无 mental-1 式假锚点；TC3 放宽后与缩写式副本自洽。

## 处置
新增 T10 清扫；TC6 扩"异常写回清单含 tests.md"。再重演。
