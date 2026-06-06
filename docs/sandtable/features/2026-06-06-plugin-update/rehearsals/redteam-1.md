# 红蓝对抗战报 · redteam-1（plugin-update，主 agent）

## 结论：HELD（无致命破口）+ 2 条加固/记录
- **B-lang（加固，纳入）**：D5=A 按提示词定语言、不自动探测现装语言；用户若装的是 zh 却贴 en 更新提示词，会把 en 资产叠加到 zh 安装形成混装。开发者已选 A（非 C 校验）。**加固**：UPDATE.md 加一行温和提醒"请用与安装时相同的语言更新"（不做强探测，符合 A）。
- **B-stale（记录，v1 非目标）**：覆盖式叠加不清理上游已删除/改名的旧资产（残留 stale 文件）。已发布版本无改名，风险低；UPDATE.md 报告区声明"stale 文件不自动清理"。
- **B-backup（记录）**：`.sandtable-backup/<ts>/` 在仓库根累积，可能被误提交/变大。UPDATE.md 提示用户可 gitignore/删除备份目录。
## 蓝军扛住
- 最高红线"绝不碰 docs/sandtable"：UPDATE.md 全部命令无 docs/sandtable 写入，核实通过。
- 零依赖：仅 cp/mkdir/test/date，无 jq/python/node。
- 备份在覆盖之前：逻辑正确。
