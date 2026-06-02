# 项目北极星 · Project

> 全局唯一。描述这个项目"为什么存在、要达成什么"。

## 目标（北极星）
Sandtable 是一套给 coding agent 用的"沙盘推演驱动开发"方法论插件：让 AI 把简单需求做成逻辑闭环、细节完美的功能。本仓既是方法论本体，也用自身方法论自举改进自己。

## 背景 / 现状
- 插件结构：`skills/`（11 个 skill）、`commands/` + `.cursor/commands/`（12 个 slash 命令）、`templates/`（8 个模板）、`hooks/`（会话启动注入 `using-sandtable`）、`.claude-plugin/` + `.cursor-plugin/` + `.cursor/rules/`、`AGENTS.md`(=`CLAUDE.md`)。
- 运行时在目标项目生成 `docs/sandtable/`：`project.md`、`constraints.md`、`features/<日期-slug>/{prd,tests,plan,state,journal,questions}.md` + `rehearsals/`。
- 当前缺一个脚手架工具：把上述运行时目录从 `templates/` 一键初始化出来，全靠手工拷贝易错。

## 范围
- 在范围内：方法论内容（skills/commands/templates）、接入文件、配套脚本。
- 不在范围内：把方法论绑定到任何具体业务项目。

## 关键干系人
- 开发者 / 决策人：仓库作者（用户）
- 目标用户：在 Cursor/Claude Code 等使用本插件的开发者
