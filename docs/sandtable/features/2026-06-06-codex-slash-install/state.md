---
feature: 2026-06-06-codex-slash-install
phase: DONE
blocked: false
updated: 2026-06-06T12:23:14+08:00
tasks:
  - id: T1
    title: 明确 Codex 支持边界与用户路径
    status: done
  - id: T2
    title: 新增 marketplace-compatible Sandtable Codex plugin
    status: done
  - id: T3
    title: 准备 Codex plugin commands 资产
    status: done
  - id: T4
    title: 更新安装映射与非覆盖规则
    status: done
  - id: T5
    title: 一致性扫描与文档验收
    status: done
rehearsals:
  mental:  { runs: 2, last: closed }
  redteam: { runs: 0, last: none }
  impl:    { runs: 3, last: done }
autonomy:
  mode: manual
  min_rounds: { mental: 3, redteam: 3, impl: 2 }
  min_agents_per_round: { mental: 3, redteam: 3, impl: 2 }
  completed_rounds: { mental: 0, redteam: 0, impl: 0 }
  last_decision: none
selected_impl: sandtable/rehearse/codex-slash-install-3
---

## 当前进展
已完成集成与验证。Codex plugin/commands 接线已落到主工作区，README/INSTALL 已更新，状态进入 DONE。

## 关键决策（最近）
- 原始需求：让 Codex 也能通过 AI 一句话安装 Sandtable，并像 Cursor 一样正常使用 slash 命令。
- 已确认现状：当前 README/INSTALL 明确写 Codex/Kiro 走通用路径、不新增专属接线；本需求会改变该边界。
- 开发者已确认继续推进，按新增 Sandtable Codex plugin/commands 接线方向写出 `tests.md` 与 `plan.md`。
- mental-1 发现并确认 anomaly：单独创建根目录 `.codex-plugin/plugin.json` 不足以闭环；修正为 `plugins/sandtable/` + `.agents/plugins/marketplace.json`。
- mental-2 已确认回修后的 marketplace-compatible 方案逻辑闭环。
- impl-1 发现并确认 anomaly：`.agents/plugins/marketplace.json` 必须使用 plugins 数组，并包含 `policy.authentication=ON_INSTALL`。
- impl-2 发现并确认 anomaly：README 顶部/Quickstart 必须按工具区分命令入口；INSTALL 验证不得依赖 `jq`。
- impl-3 完成并通过抽查，选为当前候选实现。
- 集成时发现并修正 manifest 结构偏差，最终主工作区验证通过。
- DONE 后实测反馈发现 Codex plugin 包缺少 `skills/`，已补齐 plugin-local skills、manifest `skills` 字段与安装/README 说明，并重新安装本地插件缓存；Codex composer 的 `/` autocomplete 仍不能由终端保证。
