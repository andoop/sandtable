# Codex 一句话安装与 Slash 命令接线 · PRD

> 对应 `project.md` 北极星 / 继承 `constraints.md` 红线。实现细节待 PRD 确认后进入 `tests.md` 与 `plan.md`。

## 1. 目标
让 Codex 用户也能通过一条官方 AI 安装提示词完成 Sandtable 安装，并获得可在 Codex 中调用的 Sandtable slash 命令体验；同时诚实区分 Cursor 的 `.cursor/commands` 自动接线与 Codex 的 plugin/commands 接线能力。

## 2. 背景与现状
- README 已提供中文/英文两条官方 AI 安装提示词，并把 Cursor / Claude Code / Codex / Kiro / 通用 coding agent 都列为可用对象。安装后当前文案提示第一条命令是 `/sandtable-start`。来源：`README.md:10-20`, `README.md:61-75`。
- INSTALL 已定义按官方提示词语言选择 locale pack，并将 `commands/*.md`、`.cursor/commands/*.md`、`skills/**`、`templates/**` 等安装到目标项目。来源：`INSTALL.md:25-47`, `INSTALL.md:60-92`。
- 现有 README/INSTALL 明确写 Codex/Kiro 只走通用路径，不新增专属接线。来源：`README.md:72-75`, `INSTALL.md:39`, `INSTALL.md:191`。
- 当前仓库已经有通用 `commands/*.md` 与 Cursor 专用 `.cursor/commands/*.md` 两套命令资产。来源：`commands/sandtable-start.md`, `.cursor/commands/sandtable-start.md`。
- 本地 Codex CLI 有 `codex plugin` 管理能力；本地 Codex 插件示例说明 plugin 可包含 `.codex-plugin/plugin.json`、`skills/`、`commands/` 等 companion surfaces。来源：`codex plugin --help`, `/Users/andoop/.codex/.tmp/plugins/README.md:5-8`。
- 未确认项：Codex 是否支持从任意目标项目根目录自动发现 `commands/` 或 `.cursor/commands/` 并显示为 slash 命令；目前不能把这一点写成承诺。

## 3. 方案探索
- **方案 A：只改文案，告诉 Codex 用户“直接输入 `/sandtable-start` 或自然语言即可”。**
  - 优点：改动小，延续现有通用路径。
  - 缺点：不能解决“slash 菜单没有出来”的核心体验；用户仍会误以为 Cursor 命令能被 Codex 自动发现。
- **方案 B：新增 Sandtable Codex plugin 包，复用现有 `commands/*.md` 与 `skills/`，让 Codex 用户安装 plugin 后获得 Codex 的命令入口。**
  - 优点：贴近 Codex 已暴露的插件模型；能把“一句话安装”与“Codex slash 命令接线”说清楚；不假装 `.cursor/commands` 对 Codex 生效。
  - 缺点：需要新增 Codex 专属 plugin/marketplace 安装说明，改变上一轮“Codex 不新增专属接线”的边界。
- **方案 C：尝试把 `commands/*.md` 直接复制到某个用户全局 Codex 配置目录，让 slash 命令全局可用。**
  - 优点：可能最接近 Cursor 的项目外补全体验。
  - 缺点：当前没有已确认的稳定官方路径；可能写入用户全局配置，破坏项目内安装边界；风险高。

**推荐：方案 B。** 它最符合“像 Cursor 一样正常使用 slash 命令”的目标，又能诚实遵守 Codex 的实际接线方式：Codex 命令来自 plugin/commands，而不是 Cursor 的 `.cursor/commands`。

## 4. 用户故事 / 场景
- 作为 Codex 用户，我希望把官方中文或英文安装提示词发给 AI 后，AI 能告诉我 Codex 需要安装 Sandtable Codex plugin 才能出现命令入口，而不是只复制 `.cursor/commands`。
- 作为 Codex 用户，我希望安装完成后可以输入或选择 Sandtable 的命令入口，例如 `/sandtable-start`，并触发与 Cursor 命令等义的流程。
- 作为 Cursor 用户，我希望现有 `.cursor/rules` 与 `.cursor/commands` 行为不受影响。
- 作为 Claude Code / 通用 agent 用户，我希望现有 `AGENTS.md` / `CLAUDE.md` / hooks / 自然语言触发路径不被破坏。

## 5. 功能需求
- **FR1（一句话安装继续有效）**：README/INSTALL 仍必须提供官方中文/英文 AI 安装提示词，并让用户无需手动 clone 本仓库即可开始安装。现有语言判断、不覆盖、locale pack 预检红线不得回退。
- **FR2（Codex 接线显式化）**：README/INSTALL 必须把 Codex 从“只走通用路径且无专属接线”改为“可选/推荐安装 Sandtable Codex plugin，以获得 Codex 命令入口”。文案必须说明 `.cursor/commands` 只服务 Cursor，不会让 Codex 自动出现 slash 命令。
- **FR3（新增 Codex plugin 资产）**：仓库必须提供可被 Codex plugin 机制识别的 Sandtable plugin 包，采用 marketplace-compatible 结构，至少包含 `plugins/sandtable/.codex-plugin/plugin.json` 与 `plugins/sandtable/commands/`；命令内容必须与现有 `commands/*.md` 的 Sandtable 语义保持一致。
- **FR4（命令命名与边界一致）**：Codex plugin commands 必须覆盖现有 13 个 Sandtable 命令：`sandtable-start`、`sandtable-autopilot`、`sandtable-recon`、`sandtable-objectives`、`sandtable-plan`、`sandtable-refine`、`sandtable-mental`、`sandtable-redteam`、`sandtable-live`、`sandtable-debrief`、`sandtable-rehearse`、`sandtable-status`、`sandtable-resume`。各命令职责不得漂移。
- **FR5（安装说明可执行且诚实）**：INSTALL 必须说明 Codex plugin 的安装方式、workspace marketplace 注册方式、安装后的预期体验、以及当前无法确认/不支持的行为边界；不得承诺 Codex 会读取项目 `.cursor/commands`，也不得承诺没有 plugin 安装就一定出现 slash 菜单。
- **FR6（语言资产保持一致）**：若 Codex plugin 包内含自然语言命令/skill 文本，中文与英文安装资产必须保持当前 locale 规则：中文路径使用中文，英文路径使用英文，不能靠 AI 运行时自由翻译。
- **FR7（不破坏现有 harness）**：Cursor、Claude Code、通用 agent 的安装路径和原有命令资产不得被删除或重命名；新增 Codex 接线必须是增量改动。

## 6. 验收标准（成功定义 · 抽象层）
- [ ] Codex 用户读 README/INSTALL 后能明确知道：AI 一句话安装仍可用，但 Codex slash 命令需要 Sandtable Codex plugin/commands 接线。
- [ ] 仓库存在可安装/可分发的 Sandtable Codex plugin 资产，并包含与现有 Sandtable 命令等义的命令入口。
- [ ] Codex plugin 可通过 workspace marketplace 文件被发现，而不是只把 manifest 放在项目根目录。
- [ ] 文档不再误导用户以为 `.cursor/commands` 能在 Codex 中自动出现。
- [ ] Cursor/Claude Code/通用 agent 的既有安装路径不回退。
- [ ] 未确认的 Codex 原生限制被诚实写出，不用猜测填补。

## 7. MUST（绝对要做）
- 必须保留现有官方中文/英文 AI 安装提示词与 locale pack 规则。
- 必须让 Codex 的命令入口来自 Codex 支持的 plugin/commands 机制或其它已确认机制。
- 必须提供 workspace marketplace 注册文件或等价的已确认注册方式，使 Codex 能发现 Sandtable plugin。
- 必须复用/镜像现有 Sandtable 命令语义，不重新发明另一套流程。
- 必须在文档中明确 Cursor `.cursor/commands` 与 Codex commands/plugin 的区别。
- 必须保持外科手术式改动，只动安装/命令接线所需文件。

## 8. MUST NOT（绝对不能做）
- 不声称 Codex 会自动发现 `.cursor/commands`。
- 不声称没有安装 Codex plugin 就一定能在 Codex UI 里看到 slash 命令补全。
- 不覆盖或破坏用户已有 Sandtable 安装文件。
- 不删除现有 Cursor / Claude Code / 通用 agent 支持。
- 不引入第三方运行时依赖。

## 9. 非目标 / 暂不做（YAGNI）
- 不实现 Kiro 专属命令接线，除非后续另开需求。
- 不为 Codex 写复杂 MCP 服务或 GUI app。
- 不改 Sandtable 方法论本体的硬门禁、Red Flags 或状态机语义。
- 不承诺把命令同步到用户全局 `~/.codex` 目录，除非后续确认 Codex 官方稳定支持该路径并由开发者明确选择。
- 不把仓库根目录 `.codex-plugin/plugin.json` 作为唯一插件发现路径，除非后续确认 Codex 官方支持 repo-root plugin discovery。

## 10. 未决问题
当前无阻塞未决问题；Q1 已由开发者确认，按“新增 Sandtable Codex plugin/commands 接线”推进。
