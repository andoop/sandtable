# 测试用例 · 插件更新机制

> tests.md = 理解闸门。黑盒 Given/When/Then，每条映射回 FR/验收/MUST/MUST NOT。

## TC1 · 已安装用户更新后拿到新版本资产（含本版本新增）
- **映射**: FR1, FR4；验收「资产升级到最新」
- **Given**: 项目已装旧版 Sandtable（无 `skills/triaging-feedback`、无 `/sandtable-bugfix`）。
- **When**: 用户贴中文官方更新提示词执行。
- **Then**: `skills/triaging-feedback/`、`skills/bugfix-with-evidence/`、`commands/sandtable-bug.md`、`commands/sandtable-bugfix.md` 等**新增**资产被复制到位；既有资产（AGENTS.md、using-sandtable 等）被覆盖为最新内容；报告区分"新增"与"已覆盖"。
- **状态**: 待验证

## TC2 · docs/sandtable 零改动（最高红线）
- **映射**: FR2；MUST NOT「禁止动 docs/sandtable」
- **Given**: 项目 `docs/sandtable/` 有用户的 project.md/constraints.md/lessons.md/features/**（含一场进行中的战役）。
- **When**: 执行更新。
- **Then**: 更新结束后 `docs/sandtable/` 下**所有文件逐字节未变**（mtime/内容均不被更新流程触碰）；报告显式声明"未触碰 docs/sandtable"。
- **状态**: 待验证

## TC3 · 覆盖前备份可找回
- **映射**: FR3；验收「被覆盖文件有备份」
- **Given**: 用户改过 `AGENTS.md`（加了自定义段落），现执行更新。
- **When**: 更新覆盖 `AGENTS.md`。
- **Then**: 覆盖前先把原 `AGENTS.md` 备份到 `.sandtable-backup/<时间戳>/AGENTS.md`（镜像相对路径）；新 `AGENTS.md` 为最新版本；报告列出该文件在"已覆盖并备份"清单并给出备份目录路径，用户可据此找回自定义段落。
- **状态**: 待验证

## TC4 · 语言由官方更新提示词精确匹配决定
- **映射**: FR5；MUST NOT「禁止猜语言」
- **Given**: 用户贴**英文**官方更新提示词（完全相等匹配）。
- **When**: AI 判定语言。
- **Then**: 用 `locales/en/` 作为语言相关资产源覆盖（AGENTS/rules/commands/.cursor commands/skills/plugins skills+commands/scripts/hooks 的 en 版本）；共享机器资产从根目录。若提示词带包装/混合/改写 → 不猜，先澄清。
- **状态**: 待验证

## TC5 · AGENTS.md 在更新中可覆盖（与安装相反）
- **映射**: FR4；背景「安装受保护、更新可覆盖」
- **Given**: 已存在 `AGENTS.md`（安装时受保护未被覆盖的旧版）。
- **When**: 执行更新。
- **Then**: `AGENTS.md` 被备份后**覆盖**为最新（不像安装那样跳过）；`CLAUDE.md` 软链不被改动、仍指向 `AGENTS.md`。
- **状态**: 待验证

## TC6 · 官方更新提示词 + README/INSTALL 接入
- **映射**: FR6, FR7
- **Given**: 开发者查阅仓库。
- **When**: 读 `UPDATE.md`、`README.md`、`INSTALL.md`。
- **Then**: `UPDATE.md` 顶部有中/英两条官方更新提示词（指向 UPDATE.md raw 链接）；`README.md` 有"如何更新"节给出这两条并指向 `UPDATE.md`；`INSTALL.md` 末尾有一行指引已安装用户去看 `UPDATE.md`。
- **状态**: 待验证

## TC7 · 零依赖、不节外生枝
- **映射**: MUST「零依赖」；MUST NOT「不更新清单外文件」
- **Given**: 审查 `UPDATE.md` 指令。
- **When**: 检查其命令与覆盖范围。
- **Then**: 只用 POSIX sh/bash + coreutils（cp/mkdir/test 等），不依赖 jq/python/node；覆盖范围严格限于 FR4 资产清单，不碰 `docs/sandtable/`、不碰清单外仓库文件（如 `scripts/test-sandtable-init.sh`）。
- **状态**: 待验证

## TC8 · 更新不完整时诚实报告
- **映射**: FR8
- **Given**: 某核心资产复制失败（如源缺失/无写权限）。
- **When**: 更新结束自检。
- **Then**: 报告"更新不完整"并列出失败/缺失项，不得谎报"更新完成"。
- **状态**: 待验证
