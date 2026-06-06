# PRD · 插件更新机制（已安装用户升级方法论资产）

> 对应 project.md 北极星 / 继承 constraints.md 红线。实现细节见 plan.md，场景见 tests.md。

## 目标
让**已安装 Sandtable 的用户**能把项目内的**方法论资产**升级到最新版本，过程**绝不触碰**用户运行时记忆 `docs/sandtable/`，并对被覆盖文件先备份。交付一份 AI 驱动的 `UPDATE.md`（镜像 `INSTALL.md` 范式）+ 官方更新提示词 + README"如何更新"节。

## 背景与现状
- `INSTALL.md` 为 AI 驱动、"已存在即跳过、绝不覆盖" + locale-pack 整包预检 `[INSTALL.md:43-47,101-123]`；**重跑安装无法更新**。
- 无 `UPDATE.md`、无版本号、无更新脚本/命令 `[仓库枚举]`。
- 方法论资产 vs 运行时记忆边界见 `INSTALL.md §3`；`docs/sandtable/` 是用户的战役记忆（含全局 `lessons.md`）。
- zh/en 两个 locale pack，由官方提示词正文精确匹配决定语言 `[INSTALL.md:25-39]`。

## 方案探索（已确认 D1-D5 全 A）
| 维度 | 选定 |
|------|------|
| 形态 | `UPDATE.md`（AI 驱动，镜像 INSTALL.md）|
| 版本号 | v1 不做，覆盖到最新（YAGNI）|
| 改过的资产 | 覆盖前备份到带时间戳备份目录 + 报告清单 |
| 官方提示词 | 中/英两条官方更新提示词指向 UPDATE.md |
| 语言确定 | 同安装：官方更新提示词正文精确匹配 |

## 功能需求
- **FR1（UPDATE.md·覆盖语义）**：新建仓库根 `UPDATE.md`，AI 驱动。核心语义与安装**相反**：对**方法论资产**执行"同步到最新"（覆盖已存在 + 补齐新增文件），而非跳过。〔D1=A、D2=A〕
- **FR2（硬保护运行时记忆）**：更新流程**绝不**读写/覆盖/删除 `docs/sandtable/` 下任何内容（含 `project.md`/`constraints.md`/`lessons.md`/`features/**`）。这是最高红线。〔继承 constraints「不毁用户 docs/sandtable」〕
- **FR3（覆盖前备份）**：覆盖任一已存在的方法论资产前，先把原文件备份到带时间戳目录 `.sandtable-backup/<ISO 时间戳>/`（镜像原相对路径），再写新版本；报告列出"已覆盖并备份"清单与备份目录位置。新增文件（本版本新增、用户处尚无）直接复制并列入"新增"清单。〔D3=A〕
- **FR4（资产清单·与 INSTALL 一致）**：更新覆盖范围 = `INSTALL.md §3` 的方法论资产集：`AGENTS.md`、`.cursor/rules/sandtable.mdc`、`commands/*`、`.cursor/commands/*`、`plugins/sandtable/{commands,skills}/**`、`skills/**`、`templates/**`、`scripts/sandtable-init.sh`、`hooks/{run-hook.cmd,session-start,hooks.json,hooks-cursor.json}`、`plugins/sandtable/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json`。**与安装不同**：`AGENTS.md` 在更新里**可覆盖**（先备份）。`CLAUDE.md` 软链不动。〔D1=A〕
- **FR5（语言确定·硬门禁）**：与安装一致——读用户本回合贴的官方更新提示词正文、空白归一化后与中/英官方更新提示词**完全相等匹配**决定用 zh 源（仓库根）还是 en 源（`locales/en/`）覆盖；带包装/混合/改写则不得猜测，先澄清。〔D5=A〕
- **FR6（官方更新提示词）**：`UPDATE.md` 顶部给出中/英两条官方可复制更新提示词（指向 `UPDATE.md` 的 raw 链接），与 INSTALL 的两条对称。〔D4=A〕
- **FR7（接入点）**：`README.md` 增"如何更新"节，给出两条官方更新提示词并指向 `UPDATE.md`；`INSTALL.md` 末尾加一行指引"已安装用户更新见 `UPDATE.md`"。〔D4=A〕
- **FR8（验证与诚实报告）**：`UPDATE.md` 末尾要求 AI 校验关键资产已是最新（存在性 + 抽样）、报告"已覆盖并备份/新增/未触碰 docs/sandtable"，任一核心资产同步失败则报"更新不完整"。

## 验收标准（抽象成功定义）
- [ ] 已安装用户按官方更新提示词执行后，方法论资产（含本版本新增的 skill/命令/模板）升级到最新。
- [ ] 全过程 `docs/sandtable/` 零改动（用户战役记忆与 `lessons.md` 完好）。
- [ ] 被覆盖的原文件有备份可找回；报告清楚列出覆盖/新增/保护项。
- [ ] zh 与 en 用户各自按对应官方提示词得到对应语言资产，不混装。

## MUST
- 必须新建 `UPDATE.md`（AI 驱动，覆盖方法论资产、硬保护 docs/sandtable、覆盖前备份）。
- 必须提供中/英两条官方更新提示词，并在 README/INSTALL 接入。
- 必须只用 POSIX sh/bash + coreutils，零运行时依赖。

## MUST NOT
- 禁止读写/覆盖/删除 `docs/sandtable/` 任何内容（最高红线）。
- 禁止不备份就覆盖用户可能改过的资产。
- 禁止猜测语言；禁止把 zh 装成 en 或反之。
- 禁止顺手更新未列入资产清单的仓库文件、不节外生枝。
- 禁止引入新第三方依赖、不依赖 jq/python/node 做 JSON 校验。

## 非目标 / 暂不做
- 不做版本号/差量检测（v1 覆盖到最新）。
- 不做自动定时更新 / 自更新命令（仅 AI 驱动文档）。
- 不做 `docs/sandtable/` 的迁移/升级（用户数据不归更新管）。
- 不本地化 `UPDATE.md` 自身（与 INSTALL.md 一致，单文件含中英提示词）。

## 未决问题
无（D1-D5 已确认）。
