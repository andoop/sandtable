# 实现预演报告 · impl-1（plugin-update · 单一实现，在 main 工作树）

> 结论：**DONE**（T1–T3 + 依赖修复完成，TC1–TC8 + 一致性校验通过）。

## 落地清单
- T1：`UPDATE.md`（AI 驱动更新指南）——覆盖方法论资产、覆盖前备份 `.sandtable-backup/<ts>/`、硬保护 `docs/sandtable/`、语言硬门禁、零依赖、诚实报告 + 三项 redteam 加固（语言一致提醒 / stale 不清理声明 / 备份目录提示）。
- T2：`README.md` 新增"更新（已安装用户）"节 + 两条官方更新提示词。
- T3：`INSTALL.md` 末尾加更新指引指向 UPDATE.md。
- 依赖修复（mental-1 A1）：补建 `templates/en/feedback.md`、`templates/en/lessons.md`（post-landing-loop 的 en 模板遗漏）。

## 校验
- 官方提示词正文在 UPDATE.md 顶部与 README 两处**逐字一致**（grep 确认）。✓
- `UPDATE.md` 内 bash 代码块经 `awk` 抽取后 `bash -n` 语法通过。✓
- 全文无任何 `docs/sandtable/` 写入命令（最高红线）。✓
- 零依赖（cp/mkdir/test/date/awk 仅校验用）。✓
- en 模板补齐，安装/更新 en 路径不再缺 feedback/lessons。✓

## 自评（评分维度）
- 需求符合度：FR1-FR8 全落地。✓
- 红线符合度：不毁 docs/sandtable、零依赖、外科手术式、单一事实来源（提示词三处一致）。✓
- 正确性证据：bash -n + grep 一致性 + 文件存在性。✓
- 极简：仅 1 新文件 + 2 处接入 + 2 个 en 模板补齐，无越界。✓

## 残余（已记录，不阻断）
- v1 覆盖式更新不清理 stale；无版本号——均为 PRD 非目标，UPDATE.md 已声明。
