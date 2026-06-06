# 插件更新机制 · 改动计划

**目标:** 新建 `UPDATE.md`（AI 驱动更新指南）+ README"如何更新"节 + INSTALL 指引，让已安装用户把方法论资产升级到最新，覆盖前备份，硬保护 `docs/sandtable/`。

**架构:** 镜像 `INSTALL.md` 范式（单文件含中英官方提示词 + AI 指令、零依赖 bash），语义相反：覆盖方法论资产（同步到最新），绝不碰 `docs/sandtable/`，覆盖前备份到 `.sandtable-backup/<ts>/`。

**对应 PRD:** prd.md  **对应 tests:** tests.md（TC1–TC8）
**推演要求:** 由头脑预演、红蓝对抗逐条推演（实现为文档，impl 预演=按计划誊写 + 自检）。

## 文件地图
| 文件 | 职责 |
|------|------|
| `UPDATE.md` | **新建** · AI 驱动更新指南（核心交付物）|
| `README.md` | 加"如何更新"节 + 两条官方更新提示词 |
| `INSTALL.md` | 末尾加一行：已安装用户更新见 `UPDATE.md` |

---

### 任务 T1: 新建 `UPDATE.md`

**文件:** 创建 `UPDATE.md`

- [ ] 步骤1: 写入以下完整内容：

````markdown
# 把已安装的 Sandtable 更新到最新

## 官方可复制更新提示词（只有这两条）

中文官方更新提示词：

> 阅读 https://github.com/andoop/sandtable/blob/main/UPDATE.md ，并据此按中文把当前项目里已安装的 Sandtable 更新到最新。

English official update prompt:

> Read https://github.com/andoop/sandtable/blob/main/UPDATE.md and use it to update the already-installed Sandtable in the current project to the latest, in English.

两条都只走同一个 `UPDATE.md` 路径；差别只在用户贴的这条官方提示词正文是什么语言。仅支持中文与英文。

---

## 给 AI 的更新指令

你是一个 coding agent。请把用户当前项目里**已安装**的 Sandtable**方法论资产**升级到最新（命令在项目根执行）。

### 0. 先判断更新语言（硬门禁）

读取用户本回合实际贴的那句话，空白归一化后与上面两条官方更新提示词正文**完全相等匹配**：
- 命中中文：设 `SB_LOCALE=zh`
- 命中英文：设 `SB_LOCALE=en`

带任何包装/混合/改写 → **不得猜测**，先澄清或要求用户重发官方正文。

### 1. 更新铁律（严格遵守）

- **最高红线：绝不读写/覆盖/删除 `docs/sandtable/` 下任何内容**（用户的战役记忆，含 `project.md`/`constraints.md`/`lessons.md`/`features/**`）。更新只动方法论资产。
- **覆盖前先备份**：覆盖任一已存在资产前，先把原文件/目录备份到 `./.sandtable-backup/<时间戳>/`（镜像相对路径），再写最新版本。
- **同步到最新**：方法论资产采用"覆盖已存在 + 补齐新增文件"，不像安装那样跳过。`AGENTS.md` 在更新中**可覆盖**（先备份）。`CLAUDE.md` 软链不动。
- **外科手术式**：只更新下面列出的资产；不碰 `docs/sandtable/`、不碰清单外文件（如 `scripts/test-sandtable-init.sh`）。
- **零依赖**：只用 POSIX sh/bash + coreutils；JSON 不依赖 jq/python/node。
- **诚实报告**：任一核心资产同步失败/源缺失，报"更新不完整"。

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

语言相关·目录资产（备份后覆盖式叠加）：

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

语言相关·文件资产（备份后覆盖）：

```bash
bk AGENTS.md;                       cp "$LANG_SRC/AGENTS.md" AGENTS.md
mkdir -p .cursor/rules
bk .cursor/rules/sandtable.mdc;     cp "$LANG_SRC/.cursor/rules/sandtable.mdc" .cursor/rules/sandtable.mdc
mkdir -p scripts
bk scripts/sandtable-init.sh;       cp "$LANG_SRC/scripts/sandtable-init.sh" scripts/sandtable-init.sh
mkdir -p hooks
bk hooks/run-hook.cmd;              cp "$LANG_SRC/hooks/run-hook.cmd" hooks/run-hook.cmd
bk hooks/session-start;             cp "$LANG_SRC/hooks/session-start" hooks/session-start
```

共享机器资产（始终从仓库根，备份后覆盖）：

```bash
bk hooks/hooks.json;                cp "$SB_SRC/hooks/hooks.json" hooks/hooks.json
bk hooks/hooks-cursor.json;         cp "$SB_SRC/hooks/hooks-cursor.json" hooks/hooks-cursor.json
mkdir -p plugins/sandtable/.codex-plugin .agents/plugins
bk plugins/sandtable/.codex-plugin/plugin.json; cp "$SB_SRC/plugins/sandtable/.codex-plugin/plugin.json" plugins/sandtable/.codex-plugin/plugin.json
bk .agents/plugins/marketplace.json;            cp "$SB_SRC/.agents/plugins/marketplace.json" .agents/plugins/marketplace.json
```

> 注意：以上**没有**任何命令触及 `docs/sandtable/`。`CLAUDE.md` 不动（仍软链到 AGENTS.md）。

### 5. 清理

仅当步骤 2 是你自己 clone 的临时目录时：`rm -rf "$SB_SRC"`（用户提供的本地路径绝不删）。

### 6. 验证并诚实报告

```bash
for p in skills/using-sandtable/SKILL.md skills/triaging-feedback/SKILL.md skills/bugfix-with-evidence/SKILL.md AGENTS.md commands/sandtable-start.md templates; do
  [ -e "./$p" ] && echo "ok ./$p" || echo "MISSING ./$p（更新不完整）"
done
[ -d "$BK" ] && echo "原文件已备份到 $BK"
```
报告三栏：**已覆盖并备份**（列文件 + 备份目录）、**新增**（本次新拷入、原先没有的）、**未触碰**（声明 `docs/sandtable/` 零改动）。Cursor 用户提示重载窗口；Codex 用户按本地插件流程重新启用。
````

- [ ] 步骤2: 人工核对覆盖 TC1–TC5、TC7、TC8（覆盖+新增、保护 docs/sandtable、备份、语言匹配、AGENTS 可覆盖、零依赖、诚实报告）。

---

### 任务 T2: README"如何更新"节

**文件:** 修改 `README.md`

- [ ] 步骤1: 在"## Quickstart"或命令入口附近新增一节：

```markdown
## 更新（已安装用户）

已安装 Sandtable 的项目要升级到最新方法论资产，把下面官方提示词之一**原样**发给你的 AI（与安装对称；更新只覆盖方法论资产，**绝不触碰**你的 `docs/sandtable/` 战役记忆，覆盖前自动备份）：

中文：

> 阅读 https://github.com/andoop/sandtable/blob/main/UPDATE.md ，并据此按中文把当前项目里已安装的 Sandtable 更新到最新。

English：

> Read https://github.com/andoop/sandtable/blob/main/UPDATE.md and use it to update the already-installed Sandtable in the current project to the latest, in English.

细节见 [`UPDATE.md`](UPDATE.md)。重跑安装提示词无法更新（安装器"已存在即跳过"）。
```

- [ ] 步骤2: 验证引用 TC6：README 含两条官方更新提示词 + 指向 UPDATE.md。

---

### 任务 T3: INSTALL.md 指引

**文件:** 修改 `INSTALL.md`

- [ ] 步骤1: 文件末尾（最后一段提示之后）加一行：

```markdown
> 已经装过 Sandtable、想升级到最新？不要重跑本安装（安装器"已存在即跳过"无法更新）。改用 [`UPDATE.md`](UPDATE.md) 的官方更新提示词。
```

- [ ] 步骤2: 验证引用 TC6：INSTALL.md 末尾含指向 UPDATE.md 的更新指引。

---

## 全局验证（VERIFY）
- [ ] TC1–TC8 人工核对：UPDATE.md 语义（覆盖+新增/备份/保护 docs/sandtable/语言匹配/AGENTS 可覆盖/零依赖/诚实报告）齐备。
- [ ] `UPDATE.md` 的 bash 片段 `bash -n` 思维核对无语法错误（命令为示例，关键看逻辑：bk 备份在 cp 之前、无任何 `docs/sandtable` 写入）。
- [ ] README + INSTALL 接入到位，两条官方更新提示词文案与 UPDATE.md 顶部一致。
- [ ] 符合 constraints：零依赖、不毁 docs/sandtable、外科手术式、单一事实来源（提示词正文三处一致）。
