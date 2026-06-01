# 待澄清问题 · Questions

> blocked=true 时，主流程暂停直到这些问题有答复。
>
> **2026-06-02 已答复（开发者）**：
> - Q1 = A，仓库已公开。
> - Q2 = "都支持"（Claude Code 市场 + Cursor 市场）+ 额外提供"让 AI 阅读、自己把 Sandtable 装成技能"的便捷手动安装说明。
> - Q3 = A，默认市场名/插件名 = `sandtable`。
> 阻塞解除，进入 PLAN。残余风险（非阻塞）：Cursor marketplace.json 对"仓库根即插件"`source:"."` 的支持未见官方示例，已在 journal 记录，以本地 symlink 为 Cursor 可靠路径。

## Q1 · 仓库是否为 GitHub 公共仓库
- 为何阻塞：`/plugin marketplace add andoop/sandtable` 一行安装的前提是该仓库公开可 clone。若私有，用户需先认证/授权，体验不再"一行"。
- 已尝试确认：`git remote -v` = `git@github.com:andoop/sandtable.git`，但无法离线判断公开/私有。
- 选项：A 已公开（默认假设）；B 私有，需相应在 README 说明授权步骤。

## Q2 · harness 范围
- 为何阻塞：决定改动面与 README 写法。
- 选项：
  - A 仅 Claude Code 市场（真正的 superpowers 等价物，改动最小）——推荐。
  - B A + 新增 `.cursor-plugin/marketplace.json`（Cursor 公共市场需 Cursor 审核、团队市场需 Teams/Enterprise；给不出免审核一行装，只能做"可被团队市场导入/未来官方上架"+ 本地 symlink 文档）。
  - C A + B + 给无插件机制的 harness（Codex 等）一个兜底（更清晰的手工步骤或一行安装脚本）。

## Q3 · 市场名与安装命令默认
- 默认：marketplace 名 = `sandtable`，plugin 名 = `sandtable` → `/plugin marketplace add andoop/sandtable`、`/plugin install sandtable@sandtable`。
- 选项：A 认可默认；B 想用别的市场名（请给定）。
