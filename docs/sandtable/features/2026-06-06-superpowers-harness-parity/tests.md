# Superpowers 式多 harness 安装对齐 · 测试用例

> 黑盒、场景化、人可读。每条用例都映射回 `prd.md` 的 FR / 验收 / MUST / MUST NOT。
> 审阅指引：开发者先读本文件判断“AI 是否真的懂了这次安装矩阵对齐要达成什么”，再读 `prd.md` §6 勾选是否做完。

---

## TC1 · README 主入口变成 harness-first 安装矩阵
- **映射**：FR1 / 验收“README 首页的主安装入口已经从当前 AI-first 叙事改为 harness-first 矩阵”
- **Given**：一个第一次访问 `sandtable` 仓库首页的开发者。
- **When**：他阅读 `README.md` 的安装入口与 Quickstart。
- **Then**：他首先看到的是类似 `superpowers` 的分 harness 安装矩阵，而不是“先把这句提示词发给 AI”；矩阵中至少出现 `Claude Code`、`Codex CLI`、`Codex App`、`Factory Droid`、`Gemini CLI`、`OpenCode`、`Cursor`、`GitHub Copilot CLI` 这 8 个对象。
- **状态**：待验证

## TC2 · Kiro 与通用 agent 仍被保留为额外支持对象
- **映射**：FR1 / FR4 / MUST“必须以 superpowers 当前 8 个对象为主矩阵，并额外保留 Kiro / 通用 agent”
- **Given**：一个 `Kiro` 用户和一个不属于主矩阵的通用 coding agent 用户。
- **When**：他们阅读 `README.md` 与 `INSTALL.md`。
- **Then**：两人仍能找到明确的 Sandtable 安装/启动路径；文档不会因为向 `superpowers` 主矩阵对齐，就把 `Kiro / 通用 agent` 从支持对象里删除或写成“不支持”。
- **状态**：待验证

## TC3 · AI 自助安装路径从主路径降为次级/备用路径，但没有被删除
- **映射**：FR1 / FR4 / 验收“AI 自助安装路径仍然存在，但被放到次级/备用位置”
- **Given**：一个更喜欢让 AI 自己安装 Sandtable 的开发者。
- **When**：他在新 README 中查找当前那两条官方中文/英文安装提示词与 `INSTALL.md`。
- **Then**：这些入口仍然存在，`INSTALL.md` 的 locale-pack 与不覆盖规则仍保留，但 README 不再把它们放在首页主入口的第一位置，而是作为次级/备用安装路径出现。
- **状态**：待验证

## TC4 · OpenCode 不是纯文案支持，而是有真实 repo-side companion files
- **映射**：FR2 / FR6 / 验收“OpenCode 在仓库内拥有明确 repo-side companion files”
- **Given**：一个开发者查看 `sandtable` 仓库中与 OpenCode 对齐的资产。
- **When**：他检查根目录与 `.opencode/`。
- **Then**：仓库里存在 OpenCode 所需的 companion files，例如根 `package.json`、`.opencode/INSTALL.md`、`.opencode/plugins/sandtable.js`；README 的 OpenCode 小节会指向这些文件，而不是只留一句模糊命令。`.opencode/plugins/sandtable.js` 的 bootstrap 须包含 OpenCode 工具映射（至少 `Task` → subagent），因 Sandtable 推演 prompt 模板绑定 `Task tool`（`skills/mental-rehearsal/mental-rehearsal-prompt.md` 等）。
- **状态**：待验证

## TC5 · Gemini CLI 不是纯文案支持，而是有真实 repo-side companion files
- **映射**：FR2 / FR7 / 验收“Gemini CLI 在仓库内拥有明确 repo-side companion files”
- **Given**：一个开发者查看 `sandtable` 仓库中与 Gemini CLI 对齐的资产。
- **When**：他检查仓库根目录。
- **Then**：仓库里存在 `GEMINI.md` 与 `gemini-extension.json`，以及 `skills/using-sandtable/references/gemini-tools.md`（或等价的 Sandtable 工具映射文件）；`GEMINI.md` 须 `@` 加载 skill 与工具映射；README 的 Gemini CLI 安装说明对这些文件有明确落点；Gemini 支持不再只是“README 里写了一条命令”。
- **状态**：待验证

## TC6 · 现有 Claude / Cursor / Codex 资产没有回退
- **映射**：FR2 / FR5 / 验收“现有 Claude / Cursor / Codex 资产未回退”
- **Given**：一个开发者对照当前仓库已有的插件与 marketplace 资产。
- **When**：他查看本轮改动后的 `.claude-plugin/*`、`.cursor-plugin/plugin.json`、`.agents/plugins/marketplace.json`、`plugins/sandtable/.codex-plugin/plugin.json` 以及 README / INSTALL 对它们的说明。
- **Then**：这些现有资产仍存在且角色更清楚，不会因为 README 改成 harness-first 就被删除、重命名，或被说成“不再支持”；同时 README 不会把当前仅有本地/开发路径的能力谎称为“官方已上架”。
- **状态**：待验证

## TC7 · 发布状态与 README 措辞一致（pending 或 live，不可撒谎）
- **映射**：FR3 / 验收“文档与实际上架状态一致”
- **Given**：一个开发者阅读 README 各 harness 安装小节，并对照 `docs/PUBLISHING.md` 或发布状态表。
- **When**：他检查某 harness 是标 live（现在时一行装）还是 pending（审核中/待 PR merge）。
- **Then**：已上架 harness 使用 superpowers 同级现在时命令；未上架 harness 标 pending 且不给“搜索即可安装”的虚假承诺；**不会出现** superpowers 专有标识；**不会出现**已 live 仍标「发布后可用」的滞后文档。
- **状态**：待验证

## TC8 · harness-first 对齐不会把 Sandtable 变回单语或破坏现有安装护栏
- **映射**：FR4 / MUST“必须保留现有双语 INSTALL.md 入口与 locale-pack 安装红线” / MUST NOT“不回退现有 INSTALL.md 的语言判断与不覆盖安装护栏”
- **Given**：一个开发者对照本轮改造后的 `README.md` 与 `INSTALL.md`。
- **When**：他检查官方中文/英文提示词、语言判断规则、locale-pack 预检与不覆盖安装约束。
- **Then**：这些现有护栏仍然存在且语义不变；README 主路径虽已改成 harness-first，但 Sandtable 没有因此失去双语 AI-assisted 安装能力，也没有放宽“不覆盖已有文件”的安装红线。
- **状态**：待验证

## TC9 · README 与 repo-side 资产之间的支持矩阵是自洽的
- **映射**：FR1 / FR2 / FR3 / FR5 / 验收“主矩阵、repo-side 资产与诚实边界保持自洽”
- **Given**：一个开发者按 README 的安装矩阵逐项检查仓库内容。
- **When**：他把每个 harness 小节与仓库中的对应资产、README 的说明边界、INSTALL 的备用路径逐一对照。
- **Then**：不会出现以下任一情况：
  - README 声称支持某个 harness，但仓库内完全没有对应 repo-side 落点且也没诚实写成待发布/待补齐。
  - 仓库已有现成资产，但 README / INSTALL 没提到它。
  - README 把 `Kiro / 通用 agent` 从支持对象中写没了。
  - README 与 INSTALL 对同一 harness 的路径描述互相矛盾。
- **状态**：待验证

## TC10 · 版本 bump 工具链覆盖全部 manifest
- **映射**：FR8
- **Given**：维护者准备发新版。
- **When**：运行 `./scripts/bump-version.sh patch`。
- **Then**：`.version-bump.json` 列出的全部文件 version 字段同步递增；marketplace 插件条目不双写 version；`bash -n` 与 dry bump 无报错。
- **状态**：待验证

## TC11 · Codex 官方 sync 脚本可执行
- **映射**：FR9
- **Given**：维护者 fork 了 `openai/plugins`（或等效）且已配置 `gh`。
- **When**：运行 `./scripts/sync-to-codex-plugin.sh -n`（dry-run）或完整 PR 流程。
- **Then**：脚本从 `plugins/sandtable/` 同步到 fork 的 `plugins/sandtable/` 且无路径错误；journal 或 PUBLISHING 记录 PR 状态；merge 后 Codex `/plugins` 可搜到 `sandtable`（最终验收）。
- **状态**：待验证

## TC12 · 独立 sandtable-marketplace 仓可供 Copilot/Claude community 使用
- **映射**：FR10
- **Given**：GitHub 上存在 `andoop/sandtable-marketplace`（由 scaffold 发布）。
- **When**：用户执行 README 中的 Copilot 或 Claude community marketplace 命令。
- **Then**：marketplace 指向 `https://github.com/andoop/sandtable.git`；install 命令为 `sandtable@sandtable-marketplace`；无 superpowers 标识。
- **状态**：待验证

## TC13 · 各 harness 至少一条 live 安装路径（最终 DONE）
- **映射**：FR11–FR13 / PRD §6.2
- **Given**：全部发布任务 T9–T11 执行完毕或 journal 记录阻塞。
- **When**：维护者按 PUBLISHING checklist 逐项 smoke test。
- **Then**：8 harness 各自有可复现的一行装或官方 marketplace 装（Gemini/OpenCode/Droid 为 repo URL / extension install）；Cursor/Claude official/Codex official 在平台审核通过后 README 为 live。
- **状态**：待验证

## TC14 · PUBLISHING runbook 覆盖完整发版流程
- **映射**：FR14
- **Given**：新维护者接手发版。
- **When**：阅读 `docs/PUBLISHING.md`。
- **Then**：能找到 bump→各平台上架→README 更新→验证的完整 checklist；含账号前置条件与 smoke test 命令。
- **状态**：待验证
