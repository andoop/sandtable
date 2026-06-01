# 记忆日志 · Journal（只增不改）

## 2026-06-02 00:25 · [决策] 自举立项
- 背景：用户要求用 Sandtable 自身流程改进自身，作为示例。
- 内容：选定需求 = `scripts/sandtable-init.sh`，在目标项目里从 `templates/` 一键脚手架出 `docs/sandtable/` 运行时目录。
- 依据/来源：`docs/sandtable/project.md`（现状指出缺脚手架）。

## 2026-06-02 00:25 · [决策] 实兵推演隔离方式据实调整
- 背景：`implementation-rehearsal` 要求每个实现预演用独立 git worktree。
- 内容：经确认本仓 `git rev-parse` 失败（非 git 仓库），改用隔离临时目录（如 `/tmp/sandtable-rehearse-N`）作为各实现子 agent 的独立工作区，互不污染；胜出方案再落地到真实 `scripts/`。
- 依据/来源：`git rev-parse --is-inside-work-tree` 退出码 128。

## 2026-06-02 00:27 · [推演] RECON 情报简报
- 已确认事实：
  - `templates/` 共 7 个文件：project.md, constraints.md, prd.md, plan.md, state.md, journal.md, questions.md〔来源：`ls templates`〕
  - 占位符仅出现在 `templates/state.md`：`feature: <YYYY-MM-DD>-<slug>`（第2行）、`updated: <ISO8601>`（第5行）〔来源：`grep` 命中〕
  - prd/plan 的 `<需求名>`、journal 的 `<YYYY-MM-DD HH:MM>` 属"内容骨架"，留给开发者填，初始化不替换。
  - 现有脚本风格：`hooks/session-start` 用 `set -euo pipefail` + `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"`；`hooks/run-hook.cmd` 用 bash 启动。〔来源：已读这两文件〕
- 文件归类：
  - 全局（复制到 `docs/sandtable/`，存在即跳过）：project.md, constraints.md
  - 按需求（复制到 `docs/sandtable/features/<id>/`）：prd.md, plan.md, state.md, journal.md, questions.md
  - 仅 `state.md` 需替换 `feature`→<id>、`updated`→当前 ISO8601。
- 未知/待澄清：无阻塞项（脚本参数形态属设计决策，在 OBJECTIVES 定）。

## 2026-06-02 00:34 · [推演] 头脑预演 + 红蓝对抗（对计划）— 均上报
- 头脑预演 ANOMALY：`set -u` 下缺参直接 `slug="$1"` 会 unbound 退出码1，违背 plan「缺参打印用法 + exit 2」。
- 红蓝对抗 BREACH（已亲自核实）：
  - 致命#1 sed 替换串含 `&` 被特殊解释（`echo 'feature: <slug>' | sed 's|<slug>|a&b|'` → `a<slug>b`，已复现）。
  - 致命#2 slug 含 `|` 撞 sed 分隔符 → 语法错误 + 半成品目录无法自愈。
  - 致命#3 slug 含 `/`/`..` → 目录落错路径，feature 名与磁盘不符。
  - 严重#4 macOS `date +%FT%T%z`=`+0800`（无冒号），与方法论示例 `+08:00` 不一致（已复现）。
  - 严重#5 slug 含 `:` → YAML frontmatter 可能误解析。
  - #6 空 slug、#7 符号链接调用 TEMPLATES 解析错、#8 同名普通文件占位、#9 T2 不覆盖这些输入。
- 依据/来源：两子 agent 战报 + 本机 `date`/`sed` 复现。

## 2026-06-02 00:35 · [决策] 修正方案（收口为最简设计）
- slug 白名单：仅 `[A-Za-z0-9-]`，非法（含空格/`/`/`:`/`&`/`|`/`.`/中文等）报错 + exit 2。一举消除 #1#2#3#5#6 整类破绽，且无需到处转义（极简/外科手术式）。
- 缺参守卫：`[ $# -ge 1 ]` 且 `[ -n "$slug" ]`，否则用法 + exit 2（对齐 hooks/run-hook.cmd）。
- 时间戳：`date +%FT%T%z` 后用 sed 给时区补冒号，产出 `+08:00`（对齐方法论示例）。
- feature 存在判定改用 `-e`（文件或目录皆算存在）→ 报错 exit 1，修复 #8。
- TEMPLATES 缺失前置检查：`[ -d "$TEMPLATES" ]` 否则清晰报错 exit 1（缓解 #7，非兜底而是明确前置校验）。symlink 完整支持列为非目标(YAGNI)。
- T2 增补用例：非法/空/缺参 → 报错；合法 slug 的 updated 含 `:` 时区冒号；同名重复报错。
- 待开发者拍板：slug 是否必须英文 kebab（中文需求名写进 prd 标题）。已记 questions.md，并采用「英文 kebab」为推荐默认，不阻塞推进。

## 2026-06-02 00:42 · [推演] 实兵推演 A/B + 复盘择优
- 并行 2 个实现子 agent（隔离 /tmp/sandtable-rehearse-1、-2），均返回 DONE + ALL TESTS PASSED。
- 主 agent 不轻信，亲自：①各重跑 T2 → 均全绿 ②中立探针用红军原始破绽输入（a&b / a/b / a|b / a:b / .. / "x y" / 空 / 缺参）直接打两脚本 → 均 exit 2 且零 feature 残留；happy path 时区均 `+08:00`。破绽 HELD。
- 评分：正确性 A=B；红线 A=B；报告准确性 B>A（A 把跳过的全局文件误列入"created"）；健壮性 B>A（bash 内建正则、无子进程、兼容 bash 3.2、锚定 `^updated:`）。
- 择优：B。依据/来源：/tmp/probe.sh 输出 + 两脚本全文比对。

## 2026-06-02 00:43 · [完成] 落地 + 真实验证
- 落地 B 的两脚本到 `scripts/`，README 增补一行 init 用法（kebab-case 提示）。
- 真实仓库验证：`bash -n` ok；`bash scripts/test-sandtable-init.sh` → ALL TESTS PASSED；shellcheck 未安装（如实记录）。
- 旁见（未处理，超本需求范围）：`README.md` 安装小节仍写"四个命令"，实际已 12 个——留待单独的 refine，遵守外科手术式不顺手改。
