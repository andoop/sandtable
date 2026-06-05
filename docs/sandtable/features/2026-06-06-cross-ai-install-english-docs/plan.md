# Prompt-Language Localized Install Assets · 改动计划

**目标:** 让用户复制给 AI 的官方安装提示词是什么语言，AI 就按那种语言把 Sandtable 的本地文档资产装进项目；首期支持中文与英文。
**架构:** 保持现有统一入口“让 AI 读 `INSTALL.md`”，但把仓库改成“共享机器资产 + 按语言选择的自然语言资产”结构。安装前先根据用户贴过去的话判断是中文还是英文，再从对应语言资产源拷入本地；若目标已存在，继续遵守不覆盖规则并报告未切换完成。纯机器接线文件保留单份，自然语言资产至少覆盖 `AGENTS`、规则、命令、`skills/`、`templates/` 以及会话 hook 的自然语言包装文本。
**对应 PRD:** `prd.md`
**预演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。重点攻击面：①AI 是否能仅凭复制过去的话稳定判断中/英 ②本地自然语言资产范围是否漏掉 `skills/` / `templates/` / hook 包装文本 ③不覆盖红线下的“换语言重装”是否会假成功 ④双语资产是否篡改命令边界或方法论语义。

---

## 文件地图
- 修改 `README.md` — 提供中英两条官方安装提示词，并解释“AI 按用户贴过去的话判断安装语言”。
- 修改 `INSTALL.md` — 明确中英语言判断规则、语言资产映射、共享机器资产与不覆盖下的换语言行为。
- 创建 `locales/en/AGENTS.md` — English local install variant of the baseline doc.
- 创建 `locales/en/.cursor/rules/sandtable.mdc` — English local install variant of the project rule.
- 创建 `locales/en/commands/*.md` — English local install variants of command docs.
- 创建 `locales/en/.cursor/commands/*.md` — English local install variants of Cursor command docs.
- 创建 `locales/en/skills/**` — English local install variants of all installable natural-language skill assets, including `SKILL.md` and subagent prompt templates.
- 创建 `templates/en/*.md` — English localized templates kept under the single `templates/` source tree.
- 创建 `locales/en/scripts/sandtable-init.sh` — English local install variant of the init script’s user-facing text.
- 修改 `hooks/run-hook.cmd` — Make the root hook launcher’s user-visible usage text the Chinese install source.
- 修改 `hooks/session-start` — Make the root hook wrapper the Chinese install source so it matches the root `zh` asset set.
- 创建 `locales/en/hooks/run-hook.cmd` — English local install variant of the hook launcher’s user-visible usage text.
- 创建 `locales/en/hooks/session-start` — English local install variant of the hook wrapper text.
- 复用根目录现有中文资产作为 `zh` 安装源：`AGENTS.md`、`.cursor/rules/sandtable.mdc`、`commands/`、`.cursor/commands/`、`skills/`、`templates/`、`scripts/sandtable-init.sh`、`hooks/session-start`。
- 保持共享机器资产单份：`hooks/hooks.json`、`hooks/hooks-cursor.json`。
- 不再把仓库内部测试脚本 `scripts/test-sandtable-init.sh` 安装到用户项目；安装面收紧为实际运行时需要的 `scripts/sandtable-init.sh`。

---

### 任务 T1: Define the bilingual install entry and language-selection contract

**文件:**
- 修改: `README.md`
- 修改: `INSTALL.md`

- [ ] 步骤1: 在 `README.md` 的 Quickstart / install entry 中并列给出两条官方可复制提示词：中文版、英文版；两条都继续指向同一个 `INSTALL.md`。
- [ ] 步骤2: 在 `INSTALL.md` 开头写死语言判断契约：AI 必须先在用户消息中匹配**官方中文提示词正文**或**官方英文提示词正文**；命中中文正文则安装中文资产，命中英文正文则安装英文资产；首期仅支持中/英，不要求额外 flag。
- [ ] 步骤3: `README.md` 与 `INSTALL.md` 都显式点名 `Codex` 与 `Kiro` 属于这条通用路径支持对象，但文案不得暗示存在新的工具专属接线。
- [ ] 步骤4: `INSTALL.md` 必须把“不覆盖已有文件”的影响前置写明：若项目已装某种语言版本，后来改贴另一种语言提示词，AI 仍只能跳过既有文件并报告“未完整切换”，不能覆盖；并且一旦预检发现任一语言相关目标路径已存在，就不得继续复制任何该 locale 的其它语言相关资产。
- [ ] 步骤5: 维持当前统一默认路径与第一条命令不变：仍是“让 AI 读 `INSTALL.md` 并安装到当前项目”，安装后第一条命令仍是 `/sandtable-start`。
- [ ] 步骤6: `INSTALL.md` 必须明确：若用户消息同时命中两种官方正文、只包含混合/包装文本、或只包含非官方改写版，AI 不得猜测语言，必须先澄清或要求用户直接重发官方中文/英文提示词正文。
- [ ] 步骤7: 在 `INSTALL.md` 中把脚本安装面从“复制整个 `scripts/` 目录”收紧为“只安装 `scripts/sandtable-init.sh`”，明确 `scripts/test-sandtable-init.sh` 是仓库内部测试文件，不属于用户项目安装资产。
- [ ] 步骤8: 验证步骤引用 `TC1` / `TC2` / `TC3` / `TC3.5` / `TC5` / `TC6`：人工检查两个官方提示词都可独立触发正确语义，且混合/包装/非官方提示词会被拒绝并要求澄清；同时没有引入 “Codex/Kiro 专属插件”“额外语言 flag”“覆盖式换语言” 等错误承诺。

### 任务 T2: Create the English local asset pack

**文件:**
- 创建: `locales/en/AGENTS.md`
- 创建: `locales/en/.cursor/rules/sandtable.mdc`
- 创建: `locales/en/commands/sandtable-*.md`
- 创建: `locales/en/.cursor/commands/sandtable-*.md`
- 创建: `locales/en/skills/**`
- 创建: `templates/en/*.md`
- 创建: `locales/en/scripts/sandtable-init.sh`
- 修改: `hooks/run-hook.cmd`
- 修改: `hooks/session-start`
- 创建: `locales/en/hooks/run-hook.cmd`
- 创建: `locales/en/hooks/session-start`

- [ ] 步骤1: 以根目录现有中文资产为 `zh` source-of-truth，对每类自然语言资产建立一套英文镜像，路径与最终安装目标一一对应，避免 AI 安装时再做自由翻译。
- [ ] 步骤2: `locales/en/AGENTS.md`、`locales/en/.cursor/rules/sandtable.mdc`、English commands、English Cursor commands、English skill assets（含 `SKILL.md` 与 prompt 模板）必须逐个保留现有边界语义，特别是 Sandtable 状态机、子 agent 纪律、“异常即停”规则，以及 `/sandtable-start`、`/sandtable-rehearse`、`/sandtable-autopilot` 的职责切分与各 skill 的硬门禁/Red Flags。
- [ ] 步骤3: `templates/en/*.md` 必须与根目录中文模板等义，这样英文安装后运行 `scripts/sandtable-init.sh` 产出的 `docs/sandtable/` 初始文档也是英文，同时 `templates/` 仍保持单一模板根目录。
- [ ] 步骤4: `locales/en/scripts/sandtable-init.sh` 必须只本地化 `usage` / 报错 / 结尾提示等用户可见文本，不改脚本行为、参数、路径解析、幂等保护或输出结构。
- [ ] 步骤5: 把根目录 `hooks/run-hook.cmd` 的 `usage` 文本改成中文，使它与根目录 `zh` 安装源一致；同时创建 `locales/en/hooks/run-hook.cmd` 作为英文镜像。除用户可见文本外，不改 launcher 行为。
- [ ] 步骤6: 把根目录 `hooks/session-start` 的自然语言 wrapper 与 fallback 错误文本改成中文，使它与根目录 `zh` 安装源一致；同时创建 `locales/en/hooks/session-start` 作为英文镜像。两者都继续加载对应安装路径里的 `skills/using-sandtable/SKILL.md`，不改 hook 结构与 JSON 输出契约。
- [ ] 步骤7: 验证步骤引用 `TC2` / `TC4` / `TC7`：抽查英文镜像中的 rule 语义、命令边界、skill 硬门禁、skill prompt 模板契约、模板角色/章节骨架、init 脚本文字与中英 hook launcher / wrapper（含 fallback 错误文本）文本，不允许比中文源多出或少掉实质约束。

### 任务 T3: Specify the install-time asset mapping and shared-vs-localized split

**文件:**
- 修改: `INSTALL.md`
- 复用: `AGENTS.md`、`.cursor/rules/sandtable.mdc`、`commands/`、`.cursor/commands/`、`skills/`、`templates/`、`hooks/session-start`
- 复用: `scripts/sandtable-init.sh`、`hooks/run-hook.cmd`、`hooks/hooks.json`、`hooks/hooks-cursor.json`

- [ ] 步骤1: 在 `INSTALL.md` 中写死安装映射：中文提示词时从仓库根复制中文自然语言资产；英文提示词时从 `locales/en/` 复制英文自然语言资产，但模板例外，统一从 `templates/en/` 复制到用户项目的 `templates/`；共享机器资产始终从仓库根复制。
- [ ] 步骤2: 把 `CLAUDE.md` 的处理写清：若安装逻辑仍创建 `CLAUDE.md -> AGENTS.md` 的链接，则语言切换落在 `AGENTS.md` 内容本身，不再为 `CLAUDE.md` 维护独立文本副本。
- [ ] 步骤3: 明确 `.cursor/rules/sandtable.mdc` 属于必须随语言切换的本地方法论资产，不能被遗漏在“只是文档”之外。
- [ ] 步骤4: 明确不在语言切换范围内的共享机器资产，防止实现时把真正纯机器文件复制成两套无意义副本；同时把 `scripts/sandtable-init.sh` 从“共享机器资产”里剔除，因为它包含用户可见文本。
- [ ] 步骤5: 明确 `hooks/run-hook.cmd` 与 `hooks/session-start` 都不是共享机器资产，而是随语言切换的本地 hook launcher / wrapper；中文路径使用根目录版本，英文路径使用 `locales/en/hooks/*`。
- [ ] 步骤6: 对所有**语言相关安装资产**采用 locale-pack 预检：`AGENTS.md`、rules、commands、Cursor commands、skills、templates、`scripts/sandtable-init.sh`、`hooks/run-hook.cmd`、`hooks/session-start` 在复制前先逐项检查目标路径；只要任一目标已存在，就不再复制该 locale 的任何语言相关资产，而是报告整包切换未完成。
- [ ] 步骤7: 对 `hooks/` 采用**文件级**非覆盖映射，而不是整目录跳过：`hooks.json` / `hooks-cursor.json` 作为共享机器文件单独守卫；`run-hook.cmd` / `session-start` 作为语言相关文件单独守卫与单独报告，避免旧语言 hooks 被整目录跳过后伪成功。
- [ ] 步骤8: 明确 `scripts/test-sandtable-init.sh` 不属于安装映射，不再随安装落到用户项目，从源头消除它成为英文安装残留中文脚本的可能。
- [ ] 步骤9: 验证步骤引用 `TC1` / `TC2` / `TC4` / `TC6` / `TC7` / `TC8`：从映射表出发检查中文和英文两条路径都不会漏掉 `skills/` 下的 prompt 模板、`templates/`、`scripts/sandtable-init.sh`、rules 或 hook launcher / wrapper，且不会误装 `scripts/test-sandtable-init.sh`；一旦任一语言相关目标已存在，新的 locale pack 也不会再部分复制其它语言相关资产。

### 任务 T4: Final consistency sweep

**文件:**
- 修改: `README.md`
- 修改: `INSTALL.md`
- 创建: `locales/en/**`
- 创建: `templates/en/*.md`

- [ ] 步骤1: 全仓扫描中英安装提示词与语言选择语境，确认 README / INSTALL 只有“官方中文提示词 + 官方英文提示词 + AI 自行判断语言”这一套规则，没有遗留旧的“统一英文主文”目标。
- [ ] 步骤2: 全仓扫描 `Codex` / `Kiro`，确认两者都出现在 README / INSTALL 的通用安装语境中，但没有被包装成专属集成；同时检查混合/包装/非官方提示词被要求先澄清，而不是直接当成语言选择器。
- [ ] 步骤3: 对照 `tests.md` 逐条人工验收 `TC1`–`TC8`，检查是否存在：
  - AI 无法仅凭提示词判断语言
  - 本地自然语言资产漏切换
  - `skills/` 下的 prompt 模板 / `templates/` / `.cursor/rules` / `scripts/sandtable-init.sh` / hook launcher / wrapper 被遗漏
  - 已存在文件时假装完成语言切换
  - 中英两套资产在命令边界或硬门禁上发生漂移
- [ ] 步骤4: 运行定点检查：
  - `rg -n "中文|English|Codex|Kiro|INSTALL.md|/sandtable-start|/sandtable-rehearse|/sandtable-autopilot" README.md INSTALL.md`
  - `rg -n "phase|MENTAL_REHEARSAL|REDTEAM|IMPL_REHEARSAL|/sandtable-start|/sandtable-rehearse|/sandtable-autopilot" "locales/en/AGENTS.md" "locales/en/commands" "locales/en/.cursor/commands" "locales/en/skills"`
  - `rg -n "用法:|Usage:|下一步:|Next step:" scripts/sandtable-init.sh locales/en/scripts/sandtable-init.sh`
  - `rg -n "^# |^## " templates "templates/en"`
  预期：中英提示词与语言判断规则都能命中；English asset pack 保留关键命令与状态机语义；中英 init script 的用户可见文本都存在；`templates/` 作为单一模板根目录下同时包含中文模板与 `templates/en` 英文模板，且两套结构对齐。

---

## 任务与 TC 映射
- `TC1` / `TC2` / `TC3` / `TC5` / `TC6` → `T1`, `T3`, `T4`
- `TC4` / `TC7` / `TC8` → `T2`, `T3`, `T4`

## 计划红线复核
- 不新增 Codex / Kiro 专属插件机制、rules 目录或安装脚本。
- 不靠运行时自由翻译现有资产。
- 不为“换语言”覆盖用户现有文件。
- 只为自然语言本地资产建立英文镜像；共享机器资产保持单份。
