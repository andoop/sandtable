# Codex Slash Install · Questions

## 待答复（阻塞）

暂无。

### Q1 · Codex 接线范围确认
- 问题：是否确认把本需求的“像 Cursor 一样可以正常使用 slash 命令”落为 **新增 Sandtable Codex plugin/commands 接线**，而不是继续只依赖 `AGENTS.md` + 自然语言触发？
- 为什么阻塞：现有文档明确写 Codex/Kiro 不新增专属接线；若不确认这个边界变化，后续 PRD/计划会和现有安装原则冲突。
- 已尝试确认：已读 `README.md:72-75`、`INSTALL.md:39`、`INSTALL.md:191`；本地 Codex plugin 示例显示 plugin 可包含 `commands/`（`/Users/andoop/.codex/.tmp/plugins/README.md:5-8`）。
- 推荐选项：确认新增 Codex plugin 接线，并在 README/INSTALL 里说明 Codex 的 slash 命令来自 Codex plugin 安装，不来自 `.cursor/commands` 自动发现。
- 状态：已答复。开发者回复“继续呀”，按推荐方向推进。

## 已答复

- Q1：确认按新增 Sandtable Codex plugin/commands 接线推进。
