# 红蓝对抗 第 1 轮（对计划 T1/T3/T4）

派发 2 个 OPFOR：红军1 打 INSTALL.md(T3)，红军2 打 T1+README(T4)。结果均 BREACH_FOUND。

## 红军1（INSTALL.md）杀招 — 主 agent 已核实
| # | 严重 | 杀招 | 处置 |
|---|------|------|------|
| 1 | 致命 | AGENTS.md "已存在"分支无 `[ -f ]` 守卫、节锚点与源标题不符 → 易覆盖用户文件 | 改：guarded append + 正确锚点 |
| 2 | 致命 | 步骤6按路径字符串判 provenance，用户本地路径=/tmp/sandtable-src 时仍 rm -rf 删源码 | 改：按"本 agent 是否亲自 clone"判断，并用唯一临时目录 |
| 3 | 严重 | 已有 skills/ 整树跳过，步骤5单点检查 → 假阳性"装好了" | 改：验证代表集合，跳过核心项即 FAIL 上报 |
| 附 | 中 | cwd 歧义；scripts/ 跳过后步骤4仍跑 init→exit127；hooks 假阴性 | 加固：统一 cwd、步骤4 guard、步骤5 报告跳过项 |

## 红军2（T1+README）杀招 — 主 agent 已核实
| # | 严重 | 杀招 | 处置 |
|---|------|------|------|
| 1 | 高 | marketplace 条目与 plugin.json 双写 version=0.1.0；plugin.json 优先，不 bump 则 /plugin update 空转 | 去掉 marketplace 条目 version；README 更新措辞改"发布新版后升级" |
| 2 | 高 | Cursor symlink 本地插件不加载 `.cursor/rules/sandtable.mdc`（plugin.json 无 rules、无 rules/ 目录）→ 方法论不自动生效 | README 改：Cursor 以拷贝 .cursor/ / INSTALL.md 为可靠路径，symlink 如实降级 |
| 3 | 中高 | FR2 已 drop marketplace.json，README 仍写"团队市场导入本仓"走不通 | 删除团队市场误导项 |

## 未破（信心依据）
- `.claude-plugin/marketplace.json` 与 `plugin.json` 同目录共存：Anthropic 官方 claude-code 仓同布局，安全。
- `sandtable@sandtable` 命名自洽；`owner.email`/plugin `version` 可省；github `andoop/sandtable` 简写被接受（schemastore + 官方文档）。

## 处置
T1/T3/T4 按上表修正后重演（第 2 轮红蓝 + 头脑确认）。
