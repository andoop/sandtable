# 红蓝对抗 第 3 轮（对第 3 次加固方案）

## 已确认堵死（致命毁数据类，跨轮验证）
- AGENTS.md symlink 写穿：`[ -L ]||[ ! -f ]` 守卫。
- 步骤6 误删 SB_SRC：mktemp 自 clone + 仅自 clone 才删。
- marketplace 双 version：plugin 条目无 version，plugin.json 单一权威。
- 版本叙事：README/plan 与官方"plugin.json 优先、发版 bump"一致。

## 仍 BREACH（同一类：假完整/诚实报告缺口，非毁数据）
- #2/#3/#10/#11：用户已有同名 skills/templates/commands/hooks → 安全跳过，但步骤5 `-e` 仍 ok → 误报完整。
- #9：grep 全标题仍是子串匹配，AGENTS.md 仅"提及"也假命中跳过。

## 收口（根治整类）
- 顶层诚实报告改为**硬性规则**：步骤2/3 跳过任一核心项 → 必报"安装不完整"，`-e` 为真也不算完整；跳过清单为权威。
- AGENTS.md 锚点换成更独特的正文探针 `四条不可违背的底线`。
- 步骤5 先看跳过清单再做辅助存在性检查。

## 残余（低）
- 只读 AGENTS.md 追加失败（静默不完整，非毁数据）；步骤6 仍依赖 agent 自觉（执行纪律）；GitHub 公开性（Q1 已答已公开）。

## 处置
整类已用收口规则消除。下一轮确认后转实现预演。
