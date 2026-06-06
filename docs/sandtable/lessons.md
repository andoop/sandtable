# 全局教训台账 · Lessons（跨 feature 累积，只增不改历史条目）

> 每条来自一次已关闭的验收反馈/缺陷。开新需求时 RECON / 红蓝对抗 / 写 PRD 若存在本文件则必读，把过去的坑变成未来的检查项与攻击向量。

## 2026-06-06 · 来源 2026-06-06-post-landing-loop / 镜像遗漏（plugin-update 推演中发现）
- 根因摘要：post-landing-loop 新增 `templates/feedback.md`/`lessons.md` 时未镜像到 en 模板根。误把"en 模板根"当成 `locales/en/templates`（空目录），据此判"en 不镜像模板"；真正的 en 模板源是 `templates/en/`（见 INSTALL.md §3:84、§5.1 `TEMPLATES_SRC`）。导致 en 用户安装/更新后缺这两个模板。
- 怎么预防：**新增/改动任何"语言相关资产"时，必须对照 INSTALL.md §3 的源路径映射逐项核对每个 locale 的真实源路径**，不能只看"最显眼的目录"。镜像核对脚本应覆盖 `templates/en/`，而非 `locales/en/templates/`。
- 吸取的教训：判断"是否需要 en 镜像 / en 源在哪"，以 INSTALL.md §3 的权威映射为准，不靠目录名直觉；空目录 ≠ 不镜像。
- 候选红线/检查项更新：RECON 清单加一项——"涉及多 locale 资产的需求，开工前对照 INSTALL.md §3 列全每个 locale 的真实源/目标路径"；可考虑加一个镜像完整性自检（比对 root templates 与 templates/en 的文件集差异）。
- 采纳情况：待定（教训已记；是否落 constraints.md/RECON 清单由开发者拍板）。
