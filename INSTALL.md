# 让 AI 把 Sandtable 装进你的项目

把这句话发给你的 coding agent（Cursor / Claude Code / Codex / 其它均可）：

> 阅读 https://github.com/andoop/sandtable 的 `INSTALL.md` 并据此把 Sandtable 安装进当前项目。

下面是给 **AI agent** 的安装指令。

---

## 给 AI 的安装指令

你是一个 coding agent。请把 Sandtable 方法论安装进**用户当前所在项目的根目录**（下文命令都在项目根执行；若用户在子目录，先与用户确认项目根再开始）。严格遵守：

- **绝不覆盖用户已有文件**：下列每一步写入前先判断目标是否已存在；**已存在就跳过该项并记入「跳过清单」**，禁止覆盖、禁止 `cp -R` 往已存在的同名目录硬拷。
- **AGENTS.md 用受保护的追加，绝不替换**：见步骤 2。
- **外科手术式**：只放本说明列出的文件。
- **诚实报告（硬性）**：步骤 2/3 每出现一次「跳过 …」就记入跳过清单。**只要跳过的是核心项（`skills/`、`templates/`、`commands/`、`hooks/`、`AGENTS.md`、`.cursor/rules/sandtable.mdc` 之一），最终必须报告"安装不完整"并列出跳过项——即使该路径已存在（`-e` 为真）也不得判定为完整**。存在性检查只是辅助，跳过清单才是权威。

### 步骤 1 · 取得 Sandtable 源
**优先**克隆到一个**由你创建的**临时目录（记住：这是你 clone 的，步骤 6 才删它）：
```bash
SB_SRC="$(mktemp -d)/sandtable"
git clone --depth 1 https://github.com/andoop/sandtable "$SB_SRC"
```
若无网络/无 git：向用户索取本地 Sandtable 仓库路径，令 `SB_SRC=<该路径>`；**这种情况下步骤 6 必须跳过**（那是用户的源码，绝不能删）。下文一律用 `$SB_SRC` 引用源。

### 步骤 2 · 通用方法论文件（所有 harness）
目录：仅当项目无同名目录时拷贝：
```bash
for d in skills templates commands scripts; do
  if [ -e "./$d" ]; then echo "跳过 ./$d（已存在，请手动核对）"; else cp -R "$SB_SRC/$d" "./$d"; fi
done
```
行为基线 `AGENTS.md`（受保护，绝不覆盖、绝不写穿符号链接）：
```bash
if [ ! -e ./AGENTS.md ]; then
  cp "$SB_SRC/AGENTS.md" ./AGENTS.md
elif [ -L ./AGENTS.md ] || [ ! -f ./AGENTS.md ]; then
  echo "跳过 AGENTS.md（是符号链接或非普通文件，交由用户手动处理，避免写穿）"
elif grep -qF "四条不可违背的底线" ./AGENTS.md; then
  echo "跳过 AGENTS.md（已含 Sandtable 基线）"
else
  { printf '\n\n---\n\n'; cat "$SB_SRC/AGENTS.md"; } >> ./AGENTS.md
  echo "已把 Sandtable 基线追加到现有 AGENTS.md 末尾"
fi
```

### 步骤 3 · 按 harness 接线（目标已存在则跳过并报告）
- **Cursor**（让方法论 alwaysApply 生效 + 提供 slash 命令）：
```bash
mkdir -p ./.cursor/rules ./.cursor/commands
[ -e ./.cursor/rules/sandtable.mdc ] && echo "跳过 .cursor/rules/sandtable.mdc（已存在）" \
  || cp "$SB_SRC/.cursor/rules/sandtable.mdc" ./.cursor/rules/sandtable.mdc
for f in "$SB_SRC"/.cursor/commands/*.md; do
  t="./.cursor/commands/$(basename "$f")"
  [ -e "$t" ] && echo "跳过 $t（已存在）" || cp "$f" "$t"
done
```
- **Claude Code**（会话启动注入 + 指令文件）：
```bash
[ -e ./hooks ] && echo "跳过 ./hooks（已存在，请手动核对 hooks.json）" || cp -R "$SB_SRC/hooks" ./hooks
[ -e ./CLAUDE.md ] || ln -s AGENTS.md ./CLAUDE.md
```
- **其它（Codex/通用）**：步骤 2 的 `AGENTS.md` 即为行为基线。

### 步骤 4 · 初始化运行时工作区（可选，推荐）
仅当 `scripts/sandtable-init.sh` 已就位时：
```bash
[ -f ./scripts/sandtable-init.sh ] && bash ./scripts/sandtable-init.sh <slug>   # slug 用 kebab-case，如 user-login
```
脚本幂等：已存在的 `docs/sandtable/` 文件会被跳过，不覆盖。

### 步骤 5 · 验证并诚实报告
**先看跳过清单**：若步骤 2/3 跳过了任一核心项，直接判"安装不完整"（不论下方 `-e` 结果）。再做存在性辅助检查；任一 `MISSING` 也判不完整。两者任一不满足都不得报告"安装完成"：
```bash
# 通用核心
for p in skills/using-sandtable/SKILL.md skills/being-truthful/SKILL.md skills/red-team-wargame/SKILL.md templates AGENTS.md; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（安装不完整）"
done
# Cursor 用户追加
for p in .cursor/rules/sandtable.mdc .cursor/commands; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（Cursor 不完整）"
done
# Claude Code 用户追加
[ -e ./hooks/hooks.json ] && echo "ok ./hooks/hooks.json" || echo "MISSING ./hooks/hooks.json（Claude Code 会话注入不可用）"
```
Cursor 提示用户重载窗口后 `alwaysApply` 规则生效。最后提示用 `/sandtable-start` 开始第一场战役。

### 步骤 6 · 清理
**仅当步骤 1 是你自己 `git clone` 到临时目录**时执行（即用户未提供本地路径）：
```bash
rm -rf "$SB_SRC"
```
若 `$SB_SRC` 是用户提供的本地路径，**绝不执行本步**。

---

> 想走最短路径？把 README 里的那句“阅读 `INSTALL.md` 并据此把 Sandtable 安装进当前项目”直接发给你的 AI。
