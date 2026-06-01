# 红蓝对抗 第 2 轮（对加固后 T1/T3/T4）

## 红军1-r2（INSTALL.md）
- 向量A（致命）：AGENTS.md 为 symlink → `>>` 写穿链接目标。→ 修：`[ -L ]||[ ! -f ]` 守卫。
- 向量B（严重）：步骤5代表集过窄（漏 hooks/templates/.cursor 规则）→ 残缺栈假"完整"。→ 修：按 harness 分组 MISSING 校验。
- 向量C（中高）：grep 子串锚点假命中。→ 修：全标题锚点 + `-F`。
- 上轮 #1/#2/#3 普通路径已堵。

## 红军2-r2（T1+README）
- 版本叙事（高）：plugin.json 仍 pin 0.1.0、官方恒优先；仅删 marketplace version 不够，"push commit 后升级"不实。→ 决策对标 superpowers=保留 plugin.json version + 每次发版 bump；README/plan 措辞改为"递增 plugin.json version 后升级"。
- HELD：同目录 marketplace.json+plugin.json 共存（Anthropic 官方先例）、`sandtable@sandtable` 命名、owner.email/version 省略、github 简写、Cursor symlink 已如实降级、团队市场已删、无第三方依赖。

## 处置
T1/T3/T4 已第 3 次加固。残余低风险记 journal。下一轮确认。
