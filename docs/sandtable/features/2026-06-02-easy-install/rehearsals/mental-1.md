# 头脑预演 第 1 轮

- 目标：T1–T4 计划逻辑闭环。
- 派发：2 个只读子 agent（A=marketplace.json，B=INSTALL.md+README）。
- 结果：A 网络中断未返回；B = **ANOMALY_FOUND**。

## B 的杀招（主 agent 已逐条亲自核实）
| # | 严重度 | 内容 | 核实 |
|---|--------|------|------|
| A | 严重 | INSTALL.md "禁止覆盖"红线 vs 无条件 `cp -R` 自相矛盾 | 本机复现：目录嵌套 `dst/skills/skills`、文件覆盖 |
| B | 严重 | README `ln -s "$(pwd)/sandtable"` 在仓库根执行为悬空路径 | 逻辑确认 |
| C | 中 | 手工拷贝兜底漏 `hooks/` | 旧 README:43 / cursor plugin.json 依赖 hooks |
| D | 低·疑似 | `<slug>` 占位 | 判定为 CLI 参数写法，保留 |
| E | 低 | 自查漏 `.cursor/commands` | 补入 |

## 通过项
- INSTALL 引用路径全部真实存在；README 替换边界 27–44 精确；命名自洽；不夸大 Cursor。

## 处置
T3/T4 已按修正（见 journal 01:22）。进入第 2 轮重演。
