# Prompt-Language Localized Install Assets · 测试用例

> 黑盒、场景化、人可读。每条用例都映射回 `prd.md` 的 FR / 验收 / MUST / MUST NOT。
> 审阅指引：开发者先读本文件判断“AI 是否真的懂了这次文档改造要达成什么”，再读 `prd.md` §6 勾选是否做完。

---

## TC1 · Chinese install prompt leads to Chinese local assets
- **映射**：FR1 / FR2 / FR3 / 验收“用户仅凭自己复制给 AI 的中文安装提示词，就能让 AI 安装对应语言的本地资产”
- **Given**：一个新项目尚未安装 Sandtable，用户把 README/INSTALL 提供的**中文官方安装提示词**复制给 AI。
- **When**：AI 读取这句话并按 `INSTALL.md` 执行安装。
- **Then**：写入项目的 `AGENTS.md`、`.cursor/rules/sandtable.mdc`、`commands/*.md`、`.cursor/commands/*.md`、`skills/*/SKILL.md`、`templates/*.md` 等自然语言资产为中文版本；安装后第一条命令仍是 `/sandtable-start`。
- **状态**：待验证

## TC2 · English install prompt leads to English local assets
- **映射**：FR1 / FR2 / FR3 / 验收“用户仅凭自己复制给 AI 的英文安装提示词，就能让 AI 安装对应语言的本地资产”
- **Given**：一个新项目尚未安装 Sandtable，用户把 README/INSTALL 提供的**英文官方安装提示词**复制给 AI。
- **When**：AI 读取这句话并按 `INSTALL.md` 执行安装。
- **Then**：写入项目的 `AGENTS.md`、`.cursor/rules/sandtable.mdc`、`commands/*.md`、`.cursor/commands/*.md`、`skills/*/SKILL.md`、`templates/*.md` 等自然语言资产为英文版本；不会仍落成中文资产，也不要求用户额外传 `lang=en` 之类参数。
- **状态**：待验证

## TC3 · Language is inferred from the exact official prompt body, not from an extra flag
- **映射**：FR2 / MUST“必须让 AI 以用户实际贴过去的话来判断中/英语言，不要求额外 flag”
- **Given**：`README.md` / `INSTALL.md` 同时给出中文与英文两条官方安装提示词。
- **When**：用户任选其中一条贴给 AI，而没有额外补充 `中文安装`、`English please`、`lang=...` 等指令。
- **Then**：AI 仍能仅根据那条**完整官方提示词正文**判断是中文安装还是英文安装；安装说明不把语言选择设计成另一个显式参数。
- **状态**：待验证

## TC3.5 · Mixed or unofficial prompt text is rejected for clarification, not guessed
- **映射**：FR2 / FR5 / MUST NOT“不把带包装词、混合语言或非官方改写的用户消息擅自判成某个安装语言”
- **Given**：用户没有直接粘贴 README/INSTALL 里的官方中文或英文提示词正文，而是发送了混合语言、带外层包装、或自行改写的版本，例如“给 Codex：Read INSTALL.md and install...”或“请按这句执行：Read INSTALL.md...”。
- **When**：AI 尝试判断安装语言。
- **Then**：AI 不会擅自把这类消息当作中文或英文安装指令；它会先澄清用户想要中文安装还是英文安装，或要求用户直接重发官方中文/英文提示词正文。
- **状态**：待验证

## TC4 · Both locale packs preserve rule, command, skill, and prompt-template semantics
- **映射**：FR3 / MUST“必须保持已有命令边界、安装护栏、异常语义和 Sandtable 术语关系不走样”
- **Given**：一个开发者分别检查中文与英文安装后落到本地的 `AGENTS.md`、`.cursor/rules/sandtable.mdc`、`commands/*.md`、`.cursor/commands/*.md`、`skills/` 下的 `SKILL.md` 与 prompt 模板文件。
- **When**：他对照当前仓库事实查看命令边界、状态机、三类推演与 Red Flags。
- **Then**：两种语言版本都保持同一语义：`.cursor/rules/sandtable.mdc` 仍要求按同一 Sandtable 状态机、同一子 agent 纪律和同一“异常即停”规则工作；`/sandtable-start` 只负责前五步，`/sandtable-rehearse` 只负责三类推演与复盘，`/sandtable-autopilot` 才是从原始需求一路自动推进到复盘；`skills/mental-rehearsal/mental-rehearsal-prompt.md`、`skills/red-team-wargame/opfor-prompt.md`、`skills/implementation-rehearsal/implementation-rehearsal-prompt.md` 这类 prompt 模板也与同目录 `SKILL.md` 等义，不会因为语言切换丢文件、变成中文尾巴或改写派发契约。
- **状态**：待验证

## TC5 · Codex and Kiro are explicit generic install targets, not special integrations
- **映射**：FR5 / 验收“Codex 与 Kiro 被明确支持，但仍只通过通用安装路径接入”
- **Given**：一个 Codex 用户和一个 Kiro 用户阅读 `README.md` 与 `INSTALL.md`。
- **When**：他们寻找“我该怎么开始”的默认路径。
- **Then**：两人都会看到自己被明确点名为通用安装对象，并被引导使用同一条“让 AI 读取 `INSTALL.md`”的路径；文档不会声称 Codex 或 Kiro 有新的专属插件市场、专属 rules 目录、专属 hooks 或新脚本。
- **状态**：待验证

## TC6 · Existing-file guard prevents silent language flipping
- **映射**：FR6 / MUST NOT“不为切换语言破坏既有不覆盖红线”
- **Given**：一个项目已经装好了中文版本的 Sandtable 资产。
- **When**：用户后来改把**英文官方安装提示词**贴给 AI，再次执行安装。
- **Then**：AI 不会覆盖现有中文文件去强行切成英文；它会继续遵守“存在即跳过、核心项跳过即安装不完整”的规则，并明确报告哪些本地文档/skills/hook 文件因不覆盖规则而没有被切换。更强地说：一旦预检发现任意语言相关目标路径已存在，AI 就不会再继续复制任何英文 locale pack 里的其它语言相关资产，避免出现“英文脚本 + 中文模板”之类半切换状态。若 `hooks/` 中既有共享机器文件又有语言相关文件，报告也必须指明未切换的是哪些具体 hook 文件，而不是只笼统提示“检查 hooks.json”。
- **状态**：待验证

## TC7 · Templates, init script text, and hook launcher/wrapper text do not become the hidden mixed-language tail
- **映射**：FR3 / FR4 / 验收“中文安装与英文安装都不会改变安装护栏或方法论语义”
- **Given**：一个项目分别完成中文安装与英文安装。
- **When**：开发者检查本地 `templates/*.md`、`scripts/sandtable-init.sh` 的 `usage` / 报错 / “next step”文本，并观察 `hooks/run-hook.cmd`、`hooks/session-start` 暴露给用户或 AI 的自然语言文本。
- **Then**：模板语言与所选安装语言一致，后续新建 `docs/sandtable/` 文件不会在首批产物里回退到另一种语言；英文模板与中文模板在文档角色、章节骨架和 Sandtable 术语职责上保持等义，不会把 `project/prd/tests/plan/state/journal/questions` 这些模板写成另一套方法论；`scripts/sandtable-init.sh` 的用户可见文本也与所选语言一致，同时它的参数校验、幂等保护、输出结构与下一步指引位置不变；`hooks/run-hook.cmd` 只切换 `usage` 之类用户可见文本，不改变 hook 转发行为；`hooks/session-start` 只切换 wrapper 与 fallback 错误文本语言，不改变它读取 `skills/using-sandtable/SKILL.md`、包装 bootstrap 内容和输出 JSON 契约的方式。若 hook launcher 或 hook wrapper 中存在自然语言，它们同样不会继续残留另一种语言形成混语。
- **状态**：待验证

## TC8 · Internal repo test scripts are not installed into user projects
- **映射**：FR4 / FR6 / MUST NOT“不为换语言或安装便利扩大无关安装面”
- **Given**：一个新项目按中文或英文提示词安装 Sandtable。
- **When**：开发者检查安装映射里 `scripts/` 的落点。
- **Then**：用户项目只拿到运行时需要的 `scripts/sandtable-init.sh`；仓库内部测试脚本 `scripts/test-sandtable-init.sh` 不会被安装进去，也不会被当成某种语言资产去复制。
- **状态**：待验证
