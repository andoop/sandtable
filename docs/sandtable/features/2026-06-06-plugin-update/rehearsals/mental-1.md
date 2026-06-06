# 头脑预演报告 · mental-1（plugin-update，主 agent）

## UPDATE.md 自身逻辑 → LOGIC_CLOSED
- 覆盖式叠加 `cp -R "$LANG_SRC/d/." d/`：新增+覆盖，闭环；stale（上游删除/改名文件）不自动清理——v1 非目标，UPDATE.md 报告区已声明。
- `bk` 备份在 cp 之前，文件/目录皆可（dirname 处理正确）。✓
- **无任一命令触及 `docs/sandtable/`**（最高红线）。✓
- 语言硬门禁同安装，正确。✓
- en 分支 `TEMPLATES_SRC=$SB_SRC/templates/en`：已确认 `templates/en/` 存在。✓

## ANOMALY A1（跨需求依赖缺陷，已验证）：templates/en 缺 feedback.md / lessons.md
- 偏差：root `templates/` 有 `feedback.md`+`lessons.md`（上一需求 post-landing-loop 新增），但 `templates/en/` **只有原 8 个**，缺这两个。`[已确认: ls templates/en vs templates]`
- 根因：post-landing-loop 实现时误判"en 不镜像模板"（当时查的是空的 `locales/en/templates`，而真正的 en 模板根是 `templates/en/`，INSTALL.md:84/§5.1 用 `$SB_SRC/templates/en`）。
- 影响：en 用户安装/更新后 `templates/` 缺 feedback/lessons 模板 → `triaging-feedback` 无法按模板建 feedback.md、`lessons.md` 无模板可建。波及 en 安装、en 更新（本需求）两条路径。
- 处置：补建 `templates/en/feedback.md`、`templates/en/lessons.md`（英文版）。属 post-landing-loop 的遗漏修复，顺带在本需求 rehearsal 中发现并修。
