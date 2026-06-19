#!/usr/bin/env bash
# Sandtable 资产同步 / 校验（仅限本仓库维护，不安装到用户项目）。
#
# 单一真源 → 镜像（杜绝手工复制遗漏，如 mobile 命令漏装到某个 harness）：
#   zh commands: ./commands            -> .cursor/commands, plugins/sandtable/commands, .kiro/prompts
#   zh skills:   ./skills              -> plugins/sandtable/skills
#   en commands: ./locales/en/commands -> locales/en/.cursor/commands, locales/en/plugins/sandtable/commands, locales/en/.kiro/prompts
#   en skills:   ./locales/en/skills   -> locales/en/plugins/sandtable/skills
#
# 另：.kiro/steering/sandtable.md（中）与 locales/en/.kiro/steering/sandtable.md（英）是 Kiro CLI
#     始终加载的精简方法论基线（各 locale 自己的真实文件，等价 .cursor/rules/sandtable.mdc），
#     由本脚本校验存在性与 frontmatter（不镜像 commands）。
#
# 用法：
#   scripts/sandtable-sync.sh          # 同步：镜像 := 真源（覆盖）
#   scripts/sandtable-sync.sh --check  # 只校验：不一致/缺失则非零退出（CI 用）
#
# 注：镜像目录按约定只存放 Sandtable 资产；同步会以真源为准重建镜像。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
MODE="${1:-sync}"
fail=0

mirror() {
  local src="$1" dst="$2"
  if [[ ! -d "$src" ]]; then echo "  ! 真源缺失: $src"; fail=1; return; fi
  if [[ "$MODE" == "--check" ]]; then
    if diff -rq "$src" "$dst" >/dev/null 2>&1; then
      echo "  ✓ $dst"
    else
      echo "  ✗ 不一致: $dst （应镜像 $src）"
      diff -rq "$src" "$dst" 2>&1 | sed 's/^/      /' || true
      fail=1
    fi
  else
    rm -rf "$dst"; mkdir -p "$(dirname "$dst")"; cp -R "$src" "$dst"
    echo "  → $dst"
  fi
}

echo "[1/4] 镜像命令与技能（真源 → 镜像）"
mirror commands .cursor/commands
mirror commands plugins/sandtable/commands
mirror commands .kiro/prompts
mirror skills plugins/sandtable/skills
mirror locales/en/commands locales/en/.cursor/commands
mirror locales/en/commands locales/en/plugins/sandtable/commands
mirror locales/en/commands locales/en/.kiro/prompts
mirror locales/en/skills locales/en/plugins/sandtable/skills

echo "[2/4] 平台清单与结构校验"
if grep -q '"skills"' plugins/sandtable/.codex-plugin/plugin.json; then
  echo "  ✓ codex plugin 声明 skills"
else
  echo "  ✗ codex plugin 缺 skills 声明"; fail=1
fi
for d in skills plugins/sandtable/skills locales/en/skills locales/en/plugins/sandtable/skills; do
  if [[ -f "$d/SKILL.md" ]]; then
    echo "  ✗ 错放的顶层 $d/SKILL.md（skills 根下不应直接有 SKILL.md）"; fail=1
  fi
done

echo "[3/4] mobile 资产齐备校验"
for d in commands .cursor/commands plugins/sandtable/commands .kiro/prompts \
         locales/en/commands locales/en/.cursor/commands locales/en/plugins/sandtable/commands locales/en/.kiro/prompts; do
  for f in sandtable-mobile-start sandtable-mobile-status sandtable-mobile-stop sandtable-mobile-wait; do
    [[ -f "$d/$f.md" ]] || { echo "  ✗ 缺 $d/$f.md"; fail=1; }
  done
done
# Kiro CLI 始终加载基线：.kiro/steering/sandtable.md（中）与 locales/en/.kiro/steering/sandtable.md（英）
# 是各自 locale 的精简方法论基线（真实文件，含 frontmatter；非 commands 镜像、非符号链接）。
for f in .kiro/steering/sandtable.md locales/en/.kiro/steering/sandtable.md; do
  if [[ -f "$f" && ! -L "$f" ]] && head -1 "$f" | grep -q '^---'; then
    echo "  ✓ $f"
  else
    echo "  ✗ $f 应为真实的精简 steering 文件（含 YAML frontmatter，非符号链接）"; fail=1
  fi
done
for d in skills plugins/sandtable/skills locales/en/skills locales/en/plugins/sandtable/skills; do
  [[ -f "$d/mobile-companion/SKILL.md" ]] || { echo "  ✗ 缺 $d/mobile-companion/SKILL.md"; fail=1; }
done
[[ -x scripts/sandtable-mobile-notify.sh ]] || { echo "  ✗ 缺可执行 scripts/sandtable-mobile-notify.sh"; fail=1; }

echo "[4/4] 共享片段（_shared 单一真源）齐备校验"
for d in skills plugins/sandtable/skills locales/en/skills locales/en/plugins/sandtable/skills; do
  for f in prd-gate integrity-gate autopilot-coverage issue-grading; do
    [[ -f "$d/_shared/$f.md" ]] || { echo "  ✗ 缺 $d/_shared/$f.md"; fail=1; }
  done
done

if [[ "$fail" == "0" ]]; then echo "OK：全部一致/齐备"; else echo "FAIL：发现不一致或缺失（见上）"; fi
exit "$fail"
