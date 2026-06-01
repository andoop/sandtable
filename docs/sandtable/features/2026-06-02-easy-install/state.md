---
feature: 2026-06-02-easy-install
phase: DONE             # INTAKE|RECON|OBJECTIVES|PLAN|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|EVALUATE|INTEGRATE|VERIFY|DONE
blocked: false
updated: 2026-06-02T02:35:00+08:00
tasks:
  - id: T1
    title: Claude Code 市场清单 .claude-plugin/marketplace.json
    status: done
  - id: T2
    title: (取消) Cursor 市场清单 —— source:"." 不可用且与红线冲突，开发者决策 drop
    status: cancelled
  - id: T3
    title: 面向 AI 的自助安装说明 INSTALL.md
    status: done
  - id: T4
    title: 重写 README 安装小节（四条路径）
    status: done
  - id: T5
    title: 整体验证
    status: done
rehearsals:
  mental:  { runs: 2, last: closed }   # none|closed|anomaly （异常均已修正，红蓝 HELD 印证逻辑闭环）
  redteam: { runs: 4, last: held }     # none|held|breach
  impl:    { runs: 1, last: done }     # none|done|anomaly|blocked
selected_impl: rehearsals/impl-1-easy-install.md
---

## 当前进展
DONE。实现预演 #1 落地：fast-forward 合并到 master（提交 `02d5e47`），T1/T3/T4 交付完成、T5 验收全绿、T2 取消未创建。worktree 与分支已清理。剩余残余风险（低危）：Cursor `.cursor/rules` 不随本地插件加载、`/plugin update` 需维护者递增 plugin.json 的 version——均已在 README/INSTALL 如实写明。

## 关键决策（最近）
- 范围=都支持：Claude Code 市场 + Cursor 市场 + INSTALL.md（让 AI 自助安装）。详见 journal 2026-06-02 01:08。
- Claude 源用 github 指向本仓；Cursor `source:"."` 属残余风险，以本地 symlink 为可靠路径。
