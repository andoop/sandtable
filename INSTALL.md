# 让 AI 把 Sandtable 装进你的项目

## 官方可复制提示词（只有这两条）

把下面其中一条官方提示词正文原样发给你的 coding agent（Cursor / Claude Code / Codex / Kiro / 其它通用 agent 均可）：

中文官方提示词：

> 阅读 https://github.com/andoop/sandtable/blob/main/INSTALL.md ，并据此按中文把 Sandtable 安装进当前项目。

English official prompt:

> Read https://github.com/andoop/sandtable/blob/main/INSTALL.md and use it to install Sandtable into the current project in English.

两条都只走同一个 `INSTALL.md` 路径；差别只在于用户贴给 AI 的这条官方提示词正文是什么语言。首期仅支持中文与英文。

下面是给 AI agent 的安装指令。

---

## 给 AI 的安装指令

你是一个 coding agent。请把 Sandtable 方法论安装进用户当前所在项目的根目录（下文命令都在项目根执行；若用户在子目录，先与用户确认项目根再开始）。

### 0. 先判断安装语言（硬门禁）

在执行任何安装步骤前，先读取用户本回合实际贴给你的那句话，并做空白归一化（把连续空白视作单个空格；去掉首尾空白）后，与下面两条官方提示词正文做完全相等匹配：

- 命中中文官方提示词正文：安装中文 locale pack，并设 `SB_LOCALE=zh`
- 命中英文官方提示词正文：安装英文 locale pack，并设 `SB_LOCALE=en`

若出现以下任一情况，不得猜测安装语言，必须先澄清，或要求用户直接重发上面的官方中文/英文提示词正文：

- 用户消息带任何包装前缀或后缀，例如“给 Codex：...”或“请按这句执行：...”
- 混合语言
- 两条官方提示词同时出现
- 只是用户自行改写、转述、删改后的非官方版本

不要要求额外 `lang=...` 或独立语言 flag。`.cursor/commands` 只服务 Cursor；Codex 的命令入口由 Sandtable Codex plugin 提供，Kiro / 通用 agent 仍使用 `AGENTS.md` 行为基线与普通消息入口。

### 1. 安装总规则（严格遵守）

- 绝不覆盖用户已有文件：所有写入前都先检查目标路径；已存在就跳过并记入报告，禁止覆盖。
- 语言相关资产按整个 locale pack 预检：只要该语言包中任一目标路径已存在，就不得继续复制这个 locale pack 的任何语言相关资产；必须直接报告“语言切换未完成 / 安装不完整”，并列出冲突路径。共享机器文件可继续独立处理。
- `AGENTS.md` 仍是受保护文件、绝不覆盖；但在本次 locale-pack 安装规则下，它同时属于语言相关资产，所以只要 `AGENTS.md` 已存在，就视为 locale-pack 冲突，停止复制该语言包并如实报告，而不是继续追加。
- 外科手术式：只安装本说明列出的文件；不要顺手安装其它仓库文件。
- 诚实报告（硬性）：只要跳过的是核心项（`skills/`、`templates/`、`commands/`、`plugins/sandtable/commands`、`plugins/sandtable/skills`、`AGENTS.md`、`.cursor/rules/sandtable.mdc`、`plugins/sandtable/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json`、`hooks/run-hook.cmd`、`hooks/session-start` 之一），最终都必须报告“安装不完整”。存在性检查只是辅助，跳过清单才是权威。
- Mobile Review Companion 是可选 runtime；本安装流程不安装 Node、Flutter、Dart 或 runtime 依赖。需要手机审阅时，安装方法论资产后再按 `docs/mobile-review-companion/runtime.md` 显式启用。

### 2. 取得 Sandtable 源

优先克隆到一个由你创建的临时目录（记住：这是你 clone 的，步骤 7 才删它）：

```bash
SB_SRC="$(mktemp -d)/sandtable"
git clone --depth 1 https://github.com/andoop/sandtable "$SB_SRC"
```

若无网络或无 git：向用户索取本地 Sandtable 仓库路径，令 `SB_SRC=<该路径>`；这种情况下步骤 7 必须跳过（那是用户的源码，绝不能删）。下文一律用 `$SB_SRC` 引用源。

### 3. 定义安装映射

先根据上面的语言判定，定义语言相关资产源与共享机器资产源：

- 中文 locale pack（根目录中文源）：
  - `AGENTS.md` ← `$SB_SRC/AGENTS.md`
  - `.cursor/rules/sandtable.mdc` ← `$SB_SRC/.cursor/rules/sandtable.mdc`
  - `commands/*.md` ← `$SB_SRC/commands/*.md`
  - `plugins/sandtable/commands/*.md` ← `$SB_SRC/plugins/sandtable/commands/*.md`
  - `plugins/sandtable/skills/**` ← `$SB_SRC/plugins/sandtable/skills/**`
  - `.cursor/commands/*.md` ← `$SB_SRC/.cursor/commands/*.md`
  - `skills/**` ← `$SB_SRC/skills/**`
  - `templates/**` ← `$SB_SRC/templates/**`
  - `scripts/sandtable-init.sh` ← `$SB_SRC/scripts/sandtable-init.sh`
  - `hooks/run-hook.cmd` ← `$SB_SRC/hooks/run-hook.cmd`
  - `hooks/session-start` ← `$SB_SRC/hooks/session-start`
- 英文 locale pack：
  - `AGENTS.md` ← `$SB_SRC/locales/en/AGENTS.md`
  - `.cursor/rules/sandtable.mdc` ← `$SB_SRC/locales/en/.cursor/rules/sandtable.mdc`
  - `commands/*.md` ← `$SB_SRC/locales/en/commands/*.md`
  - `plugins/sandtable/commands/*.md` ← `$SB_SRC/locales/en/plugins/sandtable/commands/*.md`
  - `plugins/sandtable/skills/**` ← `$SB_SRC/locales/en/plugins/sandtable/skills/**`
  - `.cursor/commands/*.md` ← `$SB_SRC/locales/en/.cursor/commands/*.md`
  - `skills/**` ← `$SB_SRC/locales/en/skills/**`
  - `templates/**` ← `$SB_SRC/templates/en/**` 复制到目标项目的 `templates/`
  - `scripts/sandtable-init.sh` ← `$SB_SRC/locales/en/scripts/sandtable-init.sh`
  - `hooks/run-hook.cmd` ← `$SB_SRC/locales/en/hooks/run-hook.cmd`
  - `hooks/session-start` ← `$SB_SRC/locales/en/hooks/session-start`
- 共享机器资产（不随语言切换，始终从根目录复制）：
  - `hooks/hooks.json` ← `$SB_SRC/hooks/hooks.json`
  - `hooks/hooks-cursor.json` ← `$SB_SRC/hooks/hooks-cursor.json`
  - `plugins/sandtable/.codex-plugin/plugin.json` ← `$SB_SRC/plugins/sandtable/.codex-plugin/plugin.json`
  - `.agents/plugins/marketplace.json` ← `$SB_SRC/.agents/plugins/marketplace.json`

说明：

- `templates/` 必须始终是唯一模板根目录；英文模板也必须安装到用户项目的 `templates/`，不能变成第二个平行模板根。
- `CLAUDE.md` 不维护独立语言副本；若目标项目没有 `CLAUDE.md`，继续按原规则创建 `CLAUDE.md -> AGENTS.md` 的符号链接即可，语言跟随 `AGENTS.md` 内容本身。
- `scripts/test-sandtable-init.sh` 是仓库内部测试脚本，绝不安装到用户项目。
- Codex plugin manifest 和 marketplace 注册文件是共享机器资产；它们不随语言切换，但 `plugins/sandtable/commands/*.md` 与 `plugins/sandtable/skills/**` 必须跟随 locale pack。

### 4. locale pack 预检（语言相关资产整包守卫）

在复制任何语言相关资产前，先逐项检查下面这些目标路径是否已存在：

- `./AGENTS.md`
- `./.cursor/rules/sandtable.mdc`
- `./commands`
- `./plugins/sandtable/commands`
- `./plugins/sandtable/skills`
- `./.cursor/commands`
- `./skills`
- `./templates`
- `./scripts/sandtable-init.sh`
- `./hooks/run-hook.cmd`
- `./hooks/session-start`

规则：

1. 只要上述任一目标路径已存在，就不要复制任何该 locale pack 的语言相关资产。
2. 立即报告 `Locale pack conflict` / `语言包冲突`，列出全部冲突路径，并在总结中标记为“语言切换未完成 / 安装不完整”。
3. 共享机器资产（`hooks/hooks.json`、`hooks/hooks-cursor.json`、`plugins/sandtable/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json`）可继续按各自目标路径独立判断并复制。

这条规则尤其适用于“先装中文，后来又贴英文官方提示词”的场景：你不能覆盖已有中文文件，也不能继续部分复制英文资产形成半切换状态。

### 5. 执行安装

#### 5.1 通用方法论文件

先定义源路径变量：

```bash
if [ "$SB_LOCALE" = "zh" ]; then
  LANG_SRC="$SB_SRC"
  TEMPLATES_SRC="$SB_SRC/templates"
  AGENTS_SRC="$SB_SRC/AGENTS.md"
  RULES_SRC="$SB_SRC/.cursor/rules/sandtable.mdc"
  CURSOR_COMMANDS_SRC="$SB_SRC/.cursor/commands"
  SCRIPT_SRC="$SB_SRC/scripts/sandtable-init.sh"
  HOOK_LAUNCHER_SRC="$SB_SRC/hooks/run-hook.cmd"
  HOOK_SESSION_SRC="$SB_SRC/hooks/session-start"
else
  LANG_SRC="$SB_SRC/locales/en"
  TEMPLATES_SRC="$SB_SRC/templates/en"
  AGENTS_SRC="$SB_SRC/locales/en/AGENTS.md"
  RULES_SRC="$SB_SRC/locales/en/.cursor/rules/sandtable.mdc"
  CURSOR_COMMANDS_SRC="$SB_SRC/locales/en/.cursor/commands"
  SCRIPT_SRC="$SB_SRC/locales/en/scripts/sandtable-init.sh"
  HOOK_LAUNCHER_SRC="$SB_SRC/locales/en/hooks/run-hook.cmd"
  HOOK_SESSION_SRC="$SB_SRC/locales/en/hooks/session-start"
fi
```

目录类语言资产仅当 locale pack 预检全部通过时才复制：

```bash
for d in skills commands; do
  cp -R "$LANG_SRC/$d" "./$d"
done
cp -R "$TEMPLATES_SRC" ./templates
mkdir -p ./scripts
cp "$SCRIPT_SRC" ./scripts/sandtable-init.sh
mkdir -p ./plugins/sandtable
cp -R "$LANG_SRC/plugins/sandtable/commands" ./plugins/sandtable/commands
cp -R "$LANG_SRC/plugins/sandtable/skills" ./plugins/sandtable/skills
```

行为基线 `AGENTS.md`（locale pack 预检通过后才会执行；绝不覆盖）：

```bash
[ -e ./AGENTS.md ] && echo "跳过 AGENTS.md（locale pack 预检本应已拦截）" \
  || cp "$AGENTS_SRC" ./AGENTS.md
```

#### 5.2 按 harness 接线（目标已存在则跳过并报告）

- Cursor（让方法论 alwaysApply 生效 + 提供 slash 命令）：

```bash
mkdir -p ./.cursor/rules ./.cursor/commands
[ -e ./.cursor/rules/sandtable.mdc ] && echo "跳过 .cursor/rules/sandtable.mdc（已存在）" \
  || cp "$RULES_SRC" ./.cursor/rules/sandtable.mdc
for f in "$CURSOR_COMMANDS_SRC"/*.md; do
  t="./.cursor/commands/$(basename "$f")"
  [ -e "$t" ] && echo "跳过 $t（已存在）" || cp "$f" "$t"
done
```

- Claude Code（会话启动注入 + 指令文件；`hooks/` 采用文件级处理，不是整目录跳过）：

```bash
mkdir -p ./hooks
[ -e ./hooks/hooks.json ] && echo "跳过 ./hooks/hooks.json（已存在）" \
  || cp "$SB_SRC/hooks/hooks.json" ./hooks/hooks.json
[ -e ./hooks/hooks-cursor.json ] && echo "跳过 ./hooks/hooks-cursor.json（已存在）" \
  || cp "$SB_SRC/hooks/hooks-cursor.json" ./hooks/hooks-cursor.json
[ -e ./hooks/run-hook.cmd ] && echo "跳过 ./hooks/run-hook.cmd（已存在）" \
  || cp "$HOOK_LAUNCHER_SRC" ./hooks/run-hook.cmd
[ -e ./hooks/session-start ] && echo "跳过 ./hooks/session-start（已存在）" \
  || cp "$HOOK_SESSION_SRC" ./hooks/session-start
[ -e ./CLAUDE.md ] || ln -s AGENTS.md ./CLAUDE.md
```

- Codex（通过 Sandtable Codex plugin 提供命令入口；目标已存在则跳过并报告）：

```bash
mkdir -p ./plugins/sandtable/.codex-plugin ./.agents/plugins
[ -e ./plugins/sandtable/.codex-plugin/plugin.json ] && echo "跳过 ./plugins/sandtable/.codex-plugin/plugin.json（已存在）" \
  || cp "$SB_SRC/plugins/sandtable/.codex-plugin/plugin.json" ./plugins/sandtable/.codex-plugin/plugin.json
[ -e ./.agents/plugins/marketplace.json ] && echo "跳过 ./.agents/plugins/marketplace.json（已存在）" \
  || cp "$SB_SRC/.agents/plugins/marketplace.json" ./.agents/plugins/marketplace.json
```

把项目内 marketplace 注册给 Codex，并安装/启用本地 Sandtable plugin（这不是发布插件，只是本机 Codex 注册本地 marketplace；执行前向用户说明会写入 Codex 本机插件配置）：

```bash
codex plugin marketplace add "$PWD"
codex plugin add sandtable --marketplace sandtable-local
```

Codex 插件命令使用插件命名空间；安装后优先尝试 `/sandtable:sandtable-start`。若当前 Codex 客户端的 `/` 菜单不展示本地插件命令，不得谎报“slash 提示已生效”；如实报告为客户端 autocomplete 限制，并说明插件仍已在本机注册/启用。

- Kiro / 通用 agent：步骤 5.1 的 `AGENTS.md` 即为行为基线；没有专属 slash 接线时，把 `/sandtable-start` 作为普通消息发给 AI 执行。

### 6. 初始化运行时工作区（可选，推荐）

仅当 `scripts/sandtable-init.sh` 已就位时：

```bash
[ -f ./scripts/sandtable-init.sh ] && bash ./scripts/sandtable-init.sh <slug>   # slug 用 kebab-case，如 user-login
```

脚本幂等：已存在的 `docs/sandtable/` 文件会被跳过，不覆盖。

### 6.5 验证并诚实报告

先看 locale pack 预检结果与跳过清单：若语言相关资产预检失败，或步骤 5 跳过了任一核心项，直接判“安装不完整”。再做存在性辅助检查；任一 `MISSING` 也判不完整。两者任一不满足都不得报告“安装完成”：

```bash
# 通用核心
for p in skills/using-sandtable/SKILL.md skills/being-truthful/SKILL.md templates AGENTS.md scripts/sandtable-init.sh commands/sandtable-start.md; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（安装不完整）"
done
# Cursor 用户追加
for p in .cursor/rules/sandtable.mdc .cursor/commands; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（Cursor 不完整）"
done
# Codex 用户追加
for p in plugins/sandtable/.codex-plugin/plugin.json plugins/sandtable/commands/sandtable-start.md plugins/sandtable/skills/using-sandtable/SKILL.md .agents/plugins/marketplace.json; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（Codex 不完整）"
done
# Claude Code 用户追加（hooks 文件级检查）
for p in hooks/hooks.json hooks/hooks-cursor.json hooks/run-hook.cmd hooks/session-start; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（Claude Code 不完整）"
done
```

Codex 还必须人工或由 AI 读取 `./.agents/plugins/marketplace.json`，确认 `plugins` 数组里存在 `name` 为 `sandtable` 的条目，且 `source.path` 为 `./plugins/sandtable`、`policy.authentication` 为 `ON_INSTALL`、`category` 为 `Developer Tools`；若不符合，报告 `Codex 不完整`。这项 JSON 结构检查不要依赖 `jq`、Python、Node 或其它非 POSIX/coreutils 工具。

Cursor 提示用户重载窗口后 `alwaysApply` 规则生效。Codex 提示用户按 Codex 本地插件流程启用 Sandtable Local，并优先尝试 `/sandtable:sandtable-start`。最后按工具入口开始第一场战役。

### 7. 清理

仅当步骤 2 是你自己 `git clone` 到临时目录时执行（即用户未提供本地路径）：

```bash
rm -rf "$SB_SRC"
```

若 `$SB_SRC` 是用户提供的本地路径，绝不执行本步。

---

> 想走最短路径？把本文件开头那两条官方提示词中的一条原样发给你的 AI。除了这两条官方正文，其它包装、混合或改写版本都必须先澄清语言，不能靠猜。
>
> 已经装过 Sandtable、想升级到最新？**不要重跑本安装**（安装器"已存在即跳过"无法更新）。改用 [`UPDATE.md`](UPDATE.md) 的官方更新提示词。
