# 头脑预演 第 2 轮（针对修正后计划）

- 派发：A2=marketplace.json、B2=修正后 INSTALL.md+README。

## A2 结论
- T1（Claude Code 市场）：**LOGIC_CLOSED**。字段符合官方 schema，安装命令自洽，同仓 github 源不冲突。残余：双 clone、version 双写需同步、整仓入缓存（均非阻塞）。
- T2（Cursor 市场）：**ANOMALY_FOUND**。`source:"."` 官方零示例 + 社区报告 2.6+ 静默拒绝根级 source；更稳写法需重构目录（破红线）。→ 产品决策上报。

## B2 结论
- 前轮异常 A/B/C：**已消除**（目录/文件级 `-e` 守卫、symlink 指仓库根、手工兜底含 hooks/）。
- 引用路径：全部真实存在。
- **新异常 F（严重）**：步骤1本地路径回退 + 步骤6 `rm -rf` → 删用户源码。**已修**（步骤6仅删临时 clone）。

## 处置
- F 已修。T2 待开发者决策后定 T2 去留，再跑第 3 轮。
