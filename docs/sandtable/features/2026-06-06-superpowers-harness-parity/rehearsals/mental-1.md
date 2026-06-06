# 头脑预演 #1 · Superpowers 式多 harness 安装对齐

**信号：** `LOGIC_CLOSED`（经 1 次 ANOMALY 修正后收口）

## 推演范围
- T1 + T4：README harness-first 主叙事 + INSTALL 次级路径
- T2：OpenCode companion files
- T3：Gemini CLI companion files
- T5：矩阵自洽与诚实边界

## 第 1 轮发现 · ANOMALY_FOUND（已亲自核实并修正）

**偏差：** 计划 T1 步骤 4 只要求 Factory Droid / GitHub Copilot CLI “诚实标注发布状态”，但没有禁止实现者照抄 `superpowers/README.md` 里的 `obra/superpowers-marketplace` 命令。

**位置：** `plan.md` T1 步骤 4；对照 `superpowers/README.md:145-151` 与 `sandtable/.claude-plugin/marketplace.json:1-19`

**为什么是问题：** `superpowers` 的 Copilot CLI 依赖独立 marketplace 仓 `obra/superpowers-marketplace`；`sandtable` 只有仓内 `.claude-plugin/marketplace.json`（`name: sandtable`，`repo: andoop/sandtable`），没有对应独立 Copilot marketplace。若 README 照抄 superpowers 命令，会直接写出 Sandtable 不存在的安装路径，违反 FR3 / TC7。

**处置：**
- `plan.md` T1 新增步骤 4b：禁止引用 superpowers 专有 marketplace；Claude 用 `andoop/sandtable`；Copilot/Droid 未验证则标“发布后可用”。
- `tests.md` TC7 增补：不得出现 `obra/superpowers-marketplace` 等 superpowers 专有标识。

## 第 2 轮 · 端到端逻辑链

### 链路 A：README harness-first 主入口
1. 用户打开 `README.md` → 首先看到 8 个 harness 分栏（对齐 `superpowers/README.md:31-152`）+ 附加 `Kiro / 通用 agent`（FR1，开发者 Q1=B）。
2. 每个 harness 小节落到仓内已有或计划新增资产：
   - Claude → `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`（已存在）
   - Cursor → `.cursor-plugin/plugin.json`（已存在；无 marketplace.json 是历史决策，README 需诚实说明）
   - Codex CLI/App → 官方路径标“发布后可用”；本地路径指向 `plugins/sandtable/` + `.agents/plugins/marketplace.json`（已存在）
   - OpenCode → 新增 `package.json` + `.opencode/*`（T2）
   - Gemini CLI → 新增 `GEMINI.md` + `gemini-extension.json`（T3）
   - Factory Droid / Copilot CLI → README 命令只写 Sandtable 源或“发布后可用”（T1 步骤 4b）
3. AI-assisted 路径下沉到 README 次级区 + `INSTALL.md` 全文（T1 步骤 5 + T4）→ 闭环。

### 链路 B：INSTALL 次级路径
1. 用户不走 harness-native 安装，或平台未上架 → README 指向 `INSTALL.md`（T4 步骤 1-2）。
2. `INSTALL.md` 保留双语官方提示词、locale-pack 预检、不覆盖规则（`INSTALL.md:25-123`）→ 与 TC3/TC8 一致。
3. `Kiro / 通用 agent` 仍走 `AGENTS.md` + `commands/*.md`（T4 步骤 4）→ 闭环。

### 链路 C：OpenCode bootstrap
1. 用户读 README OpenCode 小节 → 跳转 `.opencode/INSTALL.md`（T2 步骤 2）。
2. 在 `opencode.json` 添加 git-backed plugin spec → OpenCode 加载根 `package.json` → `main` 指向 `.opencode/plugins/sandtable.js`（T2 步骤 1/3，仿 `superpowers/package.json:1-6`）。
3. Plugin JS 注册 `skills/` path + 注入 `skills/using-sandtable/SKILL.md` bootstrap（仿 `superpowers/.opencode/plugins/superpowers.js:98-133`）。
4. Sandtable skills 不含 Claude 专有工具名（仅 subagent prompt 模板含 `Task tool`），无需额外 OpenCode 工具映射文件即可最小闭环 → TC4 成立。

### 链路 D：Gemini bootstrap
1. 用户执行 `gemini extensions install https://github.com/andoop/sandtable` → 读取 `gemini-extension.json` → 加载 `GEMINI.md`（T3，仿 `superpowers/gemini-extension.json:1-6` + `GEMINI.md:1-2`）。
2. `GEMINI.md` 引用 `skills/using-sandtable/SKILL.md` → bootstrap 生效。
3. superpowers 额外引用 `gemini-tools.md`；Sandtable 当前无 Gemini 工具映射需求（skills 未绑定 Claude 工具名）→ 计划 T3 步骤 3 允许按需追加，非阻塞 → TC5 成立。

## 已检查的边界 / 异常路径
- **Cursor 无 marketplace.json：** 2026-06-02-easy-install 已决策不交付；README 必须诚实，不能写“一行 marketplace 必装”。T1 步骤 2/3 覆盖。
- **Codex 官方 vs 本地：** 仓内仅有本地 workspace marketplace；官方搜索路径标“发布后可用”。T1 步骤 3 + FR3。
- **Copilot/Droid marketplace .slug 误抄：** 已通过 T1 步骤 4b + TC7 守卫。
- **OpenCode 默认中文 bootstrap：** 仓根 `skills/` 为中文源；与 superpowers 英文仓根一致；属插件仓语言，不在本轮 locale-pack 范围。残余风险：英文 OpenCode 用户看到中文 bootstrap，可后续另开需求。
- **global constraints “不引入 node/python”：** 仅约束 `配套脚本`（bash）；OpenCode plugin JS 使用 Node 内建模块、零 npm 依赖，与 superpowers 同模式，不违反 PRD“不引入新的第三方运行时依赖”。

## 红线核对
| 红线 | 结论 |
|------|------|
| 8 对象 + Kiro/通用 agent | 计划覆盖 |
| harness-first，AI 安装降级 | T1/T4 覆盖 |
| OpenCode/Gemini 真实 repo-side 文件 | T2/T3 覆盖 |
| 保留双语 INSTALL + locale-pack | T4 步骤 5，不改 skill 文本 |
| 诚实发布状态 | T1 步骤 2/4b，TC7 |
| 不回退 Claude/Cursor/Codex 资产 | T1 步骤 3，只改文档 |
| 不引入第三方 npm 依赖 | T2 OpenCode plugin 零依赖 |
| 不改方法论 skill 已调校文本 | 本轮只改 README/INSTALL/新增 harness 文件 |

## TC 核对摘要
- TC1–TC3：README/INSTALL 叙事链闭环
- TC4：OpenCode 三文件 + README 引用
- TC5：Gemini 两文件 + README 引用
- TC6：现有插件资产保留
- TC7：诚实措辞 + 禁止 superpowers marketplace 误抄（修正后）
- TC8：INSTALL 护栏保留
- TC9：矩阵与资产自洽（修正 Copilot 后）

## 残余风险（不构成 anomaly）
- OpenCode/Gemini bootstrap 默认加载中文 `using-sandtable`；若需英文插件体验需另开需求。
- Factory Droid / Copilot CLI 的实际 marketplace 消费方式未在本仓实测；Q3=A 下 README 只能写预期路径或“发布后可用”。
- Cursor 官方 marketplace 上架状态未知；不得夸大。
