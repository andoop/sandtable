# sandtable-init 脚手架脚本 改动计划

**目标:** 新增 `scripts/sandtable-init.sh`，从 `templates/` 一键脚手架出 `docs/sandtable/` 运行时目录。
**架构:** 单个 bash 脚本。相对自身定位 `templates/`；复制全局文件（存在即跳过）与 feature 文件（存在即报错）；对 state.md 做两处占位替换。
**对应 PRD:** prd.md
**推演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。

---

## 文件地图
- 创建 `scripts/sandtable-init.sh` — 职责：唯一的脚手架脚本（解析参数 → 复制模板 → 占位替换 → 打印结果）。
- 测试 `scripts/test-sandtable-init.sh` — 职责：黑盒验证脚本，覆盖 PRD 全部验收标准。
- 修改 `README.md` — 职责：在"安装/接入"补一句 init 用法。

---

### 任务 T1: 实现 sandtable-init.sh

**文件:**
- 创建: `scripts/sandtable-init.sh`

- [ ] 步骤1: 写脚本头、定位与参数校验
  - `#!/usr/bin/env bash` + `set -euo pipefail`
  - `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`；`PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"`；`TEMPLATES="${PLUGIN_ROOT}/templates"`
  - 用法函数：`usage(){ echo "usage: sandtable-init.sh <slug> [date]   (slug: [A-Za-z0-9-])" >&2; }`
  - 缺参/空 slug 守卫：`slug="${1:-}"`；`if [ -z "$slug" ]; then usage; exit 2; fi`
  - **slug 白名单校验**：`if ! printf '%s' "$slug" | grep -Eq '^[A-Za-z0-9-]+$'; then echo "error: slug 仅允许 [A-Za-z0-9-]: $slug" >&2; usage; exit 2; fi`（注意 `set -e` 下用 `if`，不要裸 `grep`）
  - 模板存在检查：`if [ ! -d "$TEMPLATES" ]; then echo "error: 找不到 templates，请从插件仓库内运行: $TEMPLATES" >&2; exit 1; fi`
  - `date_str="${2:-$(date +%F)}"`；`feature="${date_str}-${slug}"`
  - 目标根 = 当前工作目录：`DEST="$(pwd)/docs/sandtable"`
- [ ] 步骤2: 创建全局结构（幂等，不覆盖）
  - `mkdir -p "$DEST"`
  - 对 `project.md`、`constraints.md`：若 `"$DEST/<f>"` 不存在则 `cp "$TEMPLATES/<f>" "$DEST/<f>"` 并 echo "created"；存在则 echo "skip (exists)"。
- [ ] 步骤3: 创建 feature 目录（已存在则报错退出）
  - `FDIR="$DEST/features/$feature"`
  - 若 `-e "$FDIR"`（文件或目录皆算）：`echo "error: feature already exists: $FDIR" >&2; exit 1`
  - `mkdir -p "$FDIR/rehearsals"`
  - 复制 5 个模板：`prd.md plan.md state.md journal.md questions.md` → `cp "$TEMPLATES/<f>" "$FDIR/<f>"`
- [ ] 步骤4: 替换 state.md 占位
  - 时间戳并补冒号时区：`ts="$(date +%FT%T%z | sed -E 's/([0-9]{2})([0-9]{2})$/\1:\2/')"` → 形如 `2026-06-02T00:33:00+08:00`
  - 因 slug 已限定为 `[A-Za-z0-9-]`，`feature`/`ts` 均不含 sed 特殊字符（`&|/`）与 YAML 特殊字符（`:` 仅在时区，整体值安全），可安全替换。
  - 用临时文件替换（兼容 BSD/GNU，不用 `sed -i`）：
    - `sed "s|feature: <YYYY-MM-DD>-<slug>|feature: ${feature}|; s|updated: <ISO8601>|updated: ${ts}|" "$FDIR/state.md" > "$FDIR/state.md.tmp" && mv "$FDIR/state.md.tmp" "$FDIR/state.md"`
- [ ] 步骤5: 打印结果与下一步
  - 列出创建的文件；末尾提示：`下一步：在该项目里运行 /sandtable-recon 开始侦察。`
- [ ] 步骤6: `chmod +x scripts/sandtable-init.sh`

### 任务 T2: 黑盒验证脚本

**文件:**
- 创建: `scripts/test-sandtable-init.sh`

- [ ] 步骤1: 写测试脚本（在临时目录运行，断言验收标准）
  - `set -euo pipefail`；`tmp="$(mktemp -d)"`；`trap 'rm -rf "$tmp"' EXIT`
  - 解析被测脚本绝对路径：`INIT="$(cd "$(dirname "$0")" && pwd)/sandtable-init.sh"`
  - 用例1（生成）：`cd "$tmp" && "$INIT" demo`；断言 5+2 个文件存在、`rehearsals/` 存在。
  - 用例2（占位替换）：`grep -q "^feature: $(date +%F)-demo$" docs/sandtable/features/*/state.md`；`! grep -q "<YYYY-MM-DD>\|<ISO8601>" docs/sandtable/features/*/state.md`；`grep -Eq "^updated: .*[+-][0-9]{2}:[0-9]{2}$" docs/.../state.md`（时区带冒号）。
  - 用例3（全局复用）：再 `"$INIT" demo2`；断言只新增 feature 目录，`project.md` 内容哈希前后一致（未被改写）。
  - 用例4（重复报错）：`if "$INIT" demo; then echo FAIL; exit 1; fi`（同名 feature 应非 0 退出）。
  - 用例5（非法/空/缺参）：对 `a/b`、`a&b`、`a|b`、`a:b`、`..`、`"x y"`、`""`、无参 逐一断言**退出码=2** 且未新建对应 feature 目录。实现要点：`set +e; "$INIT" 'a/b'; rc=$?; set -e; [ "$rc" -eq 2 ]`。
  - 全部通过打印 `ALL TESTS PASSED`。
- [ ] 步骤2: 运行 `bash scripts/test-sandtable-init.sh`，预期 `ALL TESTS PASSED`
- [ ] 步骤3: `bash -n scripts/sandtable-init.sh`，预期无语法错误

### 任务 T3: README 增补用法

**文件:**
- 修改: `README.md`（"安装/接入"小节后）

- [ ] 步骤1: 增加一句：`快速初始化运行时目录：在目标项目根运行 scripts/sandtable-init.sh <需求 slug>`。仅一行，不展开。

## 自查（对照 PRD）
- PRD FR1–FR7 覆盖：T1 步骤1-5 全覆盖。✅
- 验收标准：由 T2 测试逐条断言。✅
- 占位扫描：步骤均给出具体命令，无 TBD。✅
- MUST NOT：无 --force、无交互、无硬编码正文、不动 templates/skills。✅
