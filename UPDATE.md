# 把已安装的 Sandtable 更新到最新

## 官方可复制更新提示词（只有这两条）

中文官方更新提示词：

> 阅读 https://github.com/andoop/sandtable/blob/main/UPDATE.md ，并据此按中文把当前项目里已安装的 Sandtable 更新到最新。

English official update prompt:

> Read https://github.com/andoop/sandtable/blob/main/UPDATE.md and use it to update the already-installed Sandtable in the current project to the latest, in English.

两条都只走同一个 `UPDATE.md` 路径；差别只在用户贴的这条官方提示词正文是什么语言。仅支持中文与英文。**请用与你安装时相同的语言更新**（更新不自动探测现装语言；zh 装的别用 en 提示词，反之亦然，否则会语言混装）。

---

## 给 AI 的更新指令

你是一个 coding agent。请把用户当前项目里**已安装**的 Sandtable **方法论资产**升级到最新（命令在项目根执行）。

### 0. 先判断更新语言（硬门禁）

读取用户本回合实际贴的那句话，空白归一化（连续空白视作单个空格、去首尾空白）后，与上面两条官方更新提示词正文**完全相等匹配**：

- 命中中文：设 `SB_LOCALE=zh`
- 命中英文：设 `SB_LOCALE=en`

带任何包装前缀/后缀、混合语言、两条同现、或自行改写的非官方版本 → **不得猜测**，先澄清或要求用户重发官方正文。

### 1. 更新铁律（严格遵守）

- **最高红线：绝不读写/覆盖/删除 `docs/sandtable/` 下任何内容**（用户的战役记忆，含 `project.md`/`constraints.md`/`lessons.md`/`features/**`）。更新只动方法论资产。
- **覆盖前先备份**：覆盖任一已存在资产前，先把原文件/目录备份到 `./.sandtable-backup/<时间戳>/`（镜像相对路径），再写最新版本。
- **同步到最新**：方法论资产"覆盖已存在 + 补齐新增文件"，不像安装那样跳过。`AGENTS.md` 在更新中**可覆盖**（先备份）；`CLAUDE.md` 软链不动。方法论资产含 `/sandtable-mobile-*` 命令（三处 harness）、`scripts/sandtable-mobile-*.sh`、`docs/mobile-review-companion/` 文档与 `runtime/server/` server 源码，更新时一并覆盖到最新。
- **外科手术式**：只更新下面列出的资产；不碰 `docs/sandtable/`、不碰清单外文件（如 `scripts/test-sandtable-init.sh`、`scripts/mobile-listening-e2e.sh`）。
- **零依赖**：只用 POSIX sh/bash + coreutils；JSON 不依赖 jq/python/node。
- **诚实报告**：任一核心资产同步失败/源缺失，报"更新不完整"。
- 可选 Mobile Review Companion 的 `runtime/server/` **源码**随方法论更新覆盖（排除并**绝不删除/改动** `node_modules/`、`dist/`、`.vite/` 等用户依赖与构建产物）；`apps/`（Flutter App）不随更新升级，需用户单独 `git pull` 仓库源。更新流程也**不修改** `.sandtable-runtime/` 或 `docs/sandtable/` 战役记忆。

### 2. 取得最新源

```bash
SB_SRC="$(mktemp -d)/sandtable"
git clone --depth 1 https://github.com/andoop/sandtable "$SB_SRC"
```

无网络/无 git：向用户索取本地最新 Sandtable 仓库路径，令 `SB_SRC=<该路径>`，并跳过步骤 5 的清理（那是用户的源码）。

### 3. 定义语言源与备份目录

```bash
BK="./.sandtable-backup/$(date +%Y%m%dT%H%M%S)"
mkdir -p "$BK"
if [ "$SB_LOCALE" = "zh" ]; then
  LANG_SRC="$SB_SRC";            TEMPLATES_SRC="$SB_SRC/templates"
else
  LANG_SRC="$SB_SRC/locales/en"; TEMPLATES_SRC="$SB_SRC/templates/en"
fi
# 备份助手：目标存在才备份（文件或目录都可）
bk() { [ -e "$1" ] && { mkdir -p "$BK/$(dirname "$1")"; cp -R "$1" "$BK/$(dirname "$1")/"; }; }
```

### 4. 执行更新（覆盖方法论资产，绝不碰 docs/sandtable）

语言相关 · 目录资产（备份后覆盖式叠加）：

```bash
for d in skills commands .cursor/commands; do
  bk "$d"; mkdir -p "$d"; cp -R "$LANG_SRC/$d/." "$d/"
done
bk templates; mkdir -p templates; cp -R "$TEMPLATES_SRC/." templates/
mkdir -p plugins/sandtable
for d in plugins/sandtable/skills plugins/sandtable/commands; do
  bk "$d"; mkdir -p "$d"; cp -R "$LANG_SRC/$d/." "$d/"
done
```

语言相关 · 文件资产（备份后覆盖）：

```bash
bk AGENTS.md;                   cp "$LANG_SRC/AGENTS.md" AGENTS.md
mkdir -p .cursor/rules
bk .cursor/rules/sandtable.mdc; cp "$LANG_SRC/.cursor/rules/sandtable.mdc" .cursor/rules/sandtable.mdc
mkdir -p scripts
bk scripts/sandtable-init.sh;   cp "$LANG_SRC/scripts/sandtable-init.sh" scripts/sandtable-init.sh
mkdir -p hooks
bk hooks/run-hook.cmd;          cp "$LANG_SRC/hooks/run-hook.cmd" hooks/run-hook.cmd
bk hooks/session-start;         cp "$LANG_SRC/hooks/session-start" hooks/session-start
```

共享机器资产（始终从仓库根，备份后覆盖）：

```bash
bk hooks/hooks.json;            cp "$SB_SRC/hooks/hooks.json" hooks/hooks.json
bk hooks/hooks-cursor.json;     cp "$SB_SRC/hooks/hooks-cursor.json" hooks/hooks-cursor.json
mkdir -p plugins/sandtable/.codex-plugin .agents/plugins
bk plugins/sandtable/.codex-plugin/plugin.json; cp "$SB_SRC/plugins/sandtable/.codex-plugin/plugin.json" plugins/sandtable/.codex-plugin/plugin.json
bk .agents/plugins/marketplace.json;            cp "$SB_SRC/.agents/plugins/marketplace.json" .agents/plugins/marketplace.json
```

可选 Mobile Companion 脚本（共享，备份后覆盖）：

```bash
mkdir -p scripts
for s in sandtable-mobile-start.sh sandtable-mobile-status.sh sandtable-mobile-stop.sh sandtable-mobile-wait.sh; do
  bk "scripts/$s"; cp "$SB_SRC/scripts/$s" "scripts/$s"
done
```

可选 Mobile Companion 文档（方法论参考文档，非战役记忆；备份后覆盖）：

```bash
mkdir -p docs/mobile-review-companion
for f in protocol.md runtime.md verification.md; do
  bk "docs/mobile-review-companion/$f"
  cp "$SB_SRC/docs/mobile-review-companion/$f" "docs/mobile-review-companion/$f"
done
```

可选 Mobile Companion runtime 源码（`runtime/server/`；只备份+覆盖源码文件，排除 `node_modules/`、`dist/`、`.vite/`，绝不删除用户已装依赖）：

```bash
# 1) 备份现有 runtime 源码（排除依赖/构建产物），避免把庞大的 node_modules 拷进备份
if [ -d runtime/server ]; then
  ( cd runtime/server && \
    find . -type d \( -name node_modules -o -name dist -o -name .vite \) -prune -o -type f -print ) \
    | while IFS= read -r f; do
        mkdir -p "$BK/runtime/server/$(dirname "$f")"
        cp "runtime/server/$f" "$BK/runtime/server/$f"
      done
fi
# 2) 覆盖式写入最新源码（同样排除依赖/构建产物；不触碰已存在的 node_modules）
( cd "$SB_SRC/runtime/server" && \
  find . -type d \( -name node_modules -o -name dist -o -name .vite \) -prune -o -type f -print ) \
  | while IFS= read -r f; do
      mkdir -p "runtime/server/$(dirname "$f")"
      cp "$SB_SRC/runtime/server/$f" "runtime/server/$f"
    done
```

> 以上覆盖了 `runtime/server/` 源码，但**没有**任何命令触及 `runtime/server/node_modules`、`apps/`、`.sandtable-runtime/` 或 `docs/sandtable/`。`CLAUDE.md` 不动（仍软链到 `AGENTS.md`）。

### 5. 清理

仅当步骤 2 是你自己 clone 的临时目录时：`rm -rf "$SB_SRC"`（用户提供的本地路径绝不删）。

### 6. 验证并诚实报告

```bash
for p in skills/using-sandtable/SKILL.md skills/triaging-feedback/SKILL.md skills/bugfix-with-evidence/SKILL.md AGENTS.md commands/sandtable-start.md templates; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（更新不完整）"
done
# 若项目启用了移动端命令，校验其随更新到位
if [ -e scripts/sandtable-mobile-start.sh ] || [ -e commands/sandtable-mobile-start.md ]; then
  for p in commands/sandtable-mobile-start.md scripts/sandtable-mobile-start.sh runtime/server/package.json runtime/server/src; do
    [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（移动端更新不完整）"
  done
fi
[ -d "$BK" ] && echo "原文件已备份到 $BK"
```

报告四点：
- **已覆盖并备份**：列出被覆盖的资产 + 备份目录 `$BK`（用户可据此找回自定义）。
- **新增**：本次新拷入、原先没有的资产（如新版新增的 skill/命令）。
- **未触碰**：显式声明 `docs/sandtable/`、`apps/`、`runtime/server/node_modules`、`.sandtable-runtime/` 零改动。
- **提示**：① 覆盖式更新**不自动清理**上游已删除/改名的旧资产（如有残留 stale 文件，按报告手动删）；② 可将 `.sandtable-backup/` 加入 `.gitignore` 或确认无误后删除；③ Cursor 用户重载窗口让规则/新 slash 生效，Codex 用户按本地插件流程重新启用；④ 若 `runtime/server/package.json` 有变动，更新后需 `npm --prefix runtime/server install` 同步依赖；`apps/` 不随本更新升级，需用户单独 `git pull` 仓库源。
