# 安装/上手像 superpowers 一样方便 改动计划

**目标:** 让用户用 superpowers 同款"市场一行装"接入 Sandtable，并提供让 AI 自助安装的说明。
**架构:** 单仓库新增一份 Claude Code `marketplace.json` + 一份面向 AI 的 `INSTALL.md`，再重写 README 安装小节并列四条路径。插件内容仍来自现有 `skills/ commands/ hooks/ templates/`，市场清单只"指路"，不复制正文。Cursor 市场清单经头脑预演判定在不破红线前提下不可用，已取消（见 PRD FR2）。
**对应 PRD:** prd.md（FR1、FR3、FR4；FR2 取消）
**推演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。重点攻击面：①Claude json 的 schema/字段与命名自洽、`source` 指向正确（github repo）②INSTALL.md 引用路径真实存在、所有写入带守卫不破坏用户文件、清理不误删、无占位符 ③README 命令字面与文件自洽、无过时描述、不夸大 Cursor。

## 文件地图
- 创建: `.claude-plugin/marketplace.json` —— Claude Code 市场清单（指向本仓自身）。
- 创建: `INSTALL.md`（仓库根）—— 面向 AI 的自助安装说明。
- 修改: `README.md:27-44`（安装/接入小节）—— 重写为四条路径。

---

### 任务 T1: Claude Code 市场清单
**文件:**
- 创建: `.claude-plugin/marketplace.json`

- [ ] 步骤1: 写入以下内容（owner 只留 name，避免空 email 触发 schema 校验；plugin `source` 用 github 源指向本仓自身，规避相对路径边界；plugin `name` 须与 `.claude-plugin/plugin.json` 的 `name`=`sandtable` 一致；**plugin 条目不写 `version`**——官方规定 `.claude-plugin/plugin.json` 的 version 恒为版本权威；两处都写只会让 marketplace 侧静默失效，故仅在 plugin.json 保留 version 单一来源。**更新模型（对标 superpowers）：维护者每次发版须递增 `.claude-plugin/plugin.json` 的 `version` 再 push，用户 `/plugin update sandtable` 才会拉新；只 push commit 而不 bump 不会触发更新——README 措辞须与此一致，禁止暗示"commit 即自动更新"**）：
```json
{
  "name": "sandtable",
  "owner": {
    "name": "sss"
  },
  "metadata": {
    "description": "Sandtable 沙盘推演驱动开发方法论插件"
  },
  "plugins": [
    {
      "name": "sandtable",
      "source": {
        "source": "github",
        "repo": "andoop/sandtable"
      },
      "description": "计划→预演→发现问题→修正→再预演的闭环开发方法论。强约束实事求是、不猜测、不捏造，状态可持久、换人换AI可续，子agent并行预演后择优落地。"
    }
  ]
}
```
- [ ] 步骤2: 验证 JSON 合法  运行: `python3 -m json.tool .claude-plugin/marketplace.json`  预期: 打印格式化 JSON，exit 0
- [ ] 步骤3: 若本机有 `claude` CLI，运行 `claude plugin validate .`  预期: PASS；无则在 journal 记"以 JSON 合法 + 官方 schema 字段比对为准"

### 任务 T2:（已取消）Cursor 市场清单
头脑预演判定：仓库根布局下 `source:"."` 官方零示例 + 社区报告 Cursor 2.6+ 静默拒绝根级 source；更稳写法需重构目录（破红线）。开发者 2026-06-02 决策 drop。Cursor 改由 README 的本地 symlink + 官方市场提交 + INSTALL.md 支持。**不创建 `.cursor-plugin/marketplace.json`。**

### 任务 T3: 面向 AI 的自助安装说明 INSTALL.md
**文件:**
- 创建: `INSTALL.md`

要求（红线）：只引用本仓真实存在的路径（`skills/`、`commands/`、`templates/`、`hooks/`、`AGENTS.md`、`.cursor/rules/sandtable.mdc`、`.cursor/commands/`、`scripts/sandtable-init.sh`）；明确"不覆盖用户已有同名文件，AGENTS.md 用追加/合并"；无 TBD/占位符。

- [ ] 步骤1: 写入以下内容（每一步写入前先判断目标是否存在，存在即跳过并上报，杜绝 `cp -R` 往已存在目录硬拷导致的嵌套/覆盖）：
````markdown
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

> 偏好用插件市场一行安装？见 `README.md` 的「安装 / 接入」。
````
- [ ] 步骤2: 自查 —— 文件内所有引用路径在 `/tmp/sandtable-src`（即本仓）真实存在；运行 `for p in skills templates commands scripts hooks AGENTS.md .cursor/rules/sandtable.mdc .cursor/commands scripts/sandtable-init.sh skills/using-sandtable/SKILL.md; do test -e "$p" && echo "ok $p" || echo "MISSING $p"; done`  预期: 全部 ok

### 任务 T4: 重写 README 安装小节
**文件:**
- 修改: `README.md:27-44`（整段「## 安装 / 接入」替换）

- [ ] 步骤1: 用以下内容替换现有 27-44 行的「## 安装 / 接入」整节（命令字面须与 T1/T2/T3 的名字自洽；删除过时的"四个命令"描述）：
```markdown
## 安装 / 接入

### Claude Code（最方便 · 插件市场一行装）

```bash
/plugin marketplace add andoop/sandtable
/plugin install sandtable@sandtable
```

装好即生效。维护者发布新版本（递增 `.claude-plugin/plugin.json` 的 `version` 并 push）后，用 `/plugin update sandtable` 升级。

### Cursor

- **可靠路径**：把本仓 `.cursor/` 拷进你的项目根——`.cursor/rules/sandtable.mdc`（`alwaysApply`）让方法论自动生效，`.cursor/commands/*.md` 提供 slash 命令；再拷 `skills/`、`templates/`。或直接让 AI 读 `INSTALL.md` 自助完成（见下）。
- **本地插件（试用）**：在仓库根 `ln -s "$(pwd)" ~/.cursor/plugins/local/sandtable` 后重载窗口，可获得 skills 与命令；但 `.cursor/rules/sandtable.mdc` 属项目级规则、不随本地插件加载，要"自动生效"仍需用上面拷 `.cursor/` 的方式。
- **官方市场**：在 cursor.com/marketplace/publish 提交审核后可被搜索安装。

### 让 AI 自助安装（任意 harness）

把这句话发给你的 agent：「阅读 https://github.com/andoop/sandtable 的 `INSTALL.md` 并据此把 Sandtable 安装进当前项目。」它会识别 harness、放置文件、且不覆盖你已有的文件。详见 `INSTALL.md`。

### 手工拷贝（兜底）

把 `.cursor/`、`skills/`、`templates/`、`commands/`、`hooks/`、`AGENTS.md` 拷进你的项目根（Claude Code 需 `hooks/` 才能在会话启动注入 `using-sandtable`）；或把整个 `sandtable/` 目录放进项目根。随后在项目根运行 `bash scripts/sandtable-init.sh <slug>` 脚手架出 `docs/sandtable/`（slug 用 kebab-case）。
```
- [ ] 步骤2: 检查 README 其余小节未被波及（仅替换该节），且不再出现"四个命令"字样  运行: `grep -n "四个命令" README.md`  预期: 无输出

### 任务 T5: 整体验证
- [ ] 步骤1: Claude json 合法  运行: `python3 -m json.tool .claude-plugin/marketplace.json`  预期: exit 0
- [ ] 步骤2: 命名自洽  运行: `grep -n '"name"' .claude-plugin/plugin.json .claude-plugin/marketplace.json`  预期: 均含 `sandtable`（marketplace 名 + plugin 名）
- [ ] 步骤3: INSTALL.md 路径自查（见 T3 步骤2）全部 ok；且确认未创建 `.cursor-plugin/marketplace.json`（`test ! -e .cursor-plugin/marketplace.json`）
- [ ] 步骤4: 现有插件未被破坏  运行: `python3 -m json.tool .claude-plugin/plugin.json && python3 -m json.tool .cursor-plugin/plugin.json && bash -n scripts/sandtable-init.sh`  预期: 均通过
- [ ] 步骤5: README 无过时描述  运行: `grep -n "四个命令" README.md`  预期: 无输出
```
