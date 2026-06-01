#!/usr/bin/env bash
#
# test-sandtable-init.sh — sandtable-init.sh 的黑盒测试
#
# 在隔离临时目录中运行，覆盖：生成 / 占位替换 / 全局复用 / 重复 / 非法输入。
#
set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INIT="$SCRIPT_DIR/sandtable-init.sh"
TODAY=$(date +%F)

WORK=$(mktemp -d)
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

# 在指定目录里运行 init，返回其退出码（不让 set -e 中断测试）。
run_init() {
	local dir="$1"
	shift
	(cd "$dir" && bash "$INIT" "$@") >/dev/null 2>&1
}

# ---------------------------------------------------------------------------
# 用例 1 + 2: 生成 & 占位替换
# ---------------------------------------------------------------------------
T1="$WORK/t1"
mkdir -p "$T1"
run_init "$T1" demo || fail "1: init demo 应当成功，退出码=$?"

ROOT="$T1/docs/sandtable"
FEAT="$ROOT/features/${TODAY}-demo"

# 2 个全局文件
for f in project.md constraints.md; do
	[[ -f "$ROOT/$f" ]] || fail "1: 缺少全局文件 $f"
done
# feature 下 5 个文件
for f in prd.md plan.md state.md journal.md questions.md; do
	[[ -f "$FEAT/$f" ]] || fail "1: 缺少 feature 文件 $f"
done
# rehearsals/ 目录
[[ -d "$FEAT/rehearsals" ]] || fail "1: 缺少 rehearsals/ 目录"

# 占位替换：feature 行
STATE="$FEAT/state.md"
feature_line=$(grep '^feature:' "$STATE" || true)
[[ "$feature_line" == "feature: ${TODAY}-demo" ]] \
	|| fail "2: feature 行不符: '$feature_line'"

# 无占位残留
if grep -q '<YYYY-MM-DD>' "$STATE"; then
	fail "2: state.md 残留 <YYYY-MM-DD>"
fi
if grep -q '<ISO8601>' "$STATE"; then
	fail "2: state.md 残留 <ISO8601>"
fi

# updated 行以时区 +HH:MM / -HH:MM 结尾
updated_line=$(grep '^updated:' "$STATE" || true)
if [[ ! "$updated_line" =~ [+-][0-9][0-9]:[0-9][0-9]$ ]]; then
	fail "2: updated 行时区格式不符: '$updated_line'"
fi

# ---------------------------------------------------------------------------
# 用例 3: 全局复用 —— 再建 demo2，project.md 内容不变（哈希一致），新增第二 feature
# ---------------------------------------------------------------------------
hash_before=$(shasum "$ROOT/project.md" | awk '{print $1}')
run_init "$T1" demo2 || fail "3: init demo2 应当成功，退出码=$?"
hash_after=$(shasum "$ROOT/project.md" | awk '{print $1}')
[[ "$hash_before" == "$hash_after" ]] \
	|| fail "3: project.md 被改动 ($hash_before != $hash_after)"
[[ -d "$ROOT/features/${TODAY}-demo2" ]] || fail "3: 未新增第二 feature 目录"

# ---------------------------------------------------------------------------
# 用例 4: 重复 —— 再 init demo 应失败（退出码非 0）
# ---------------------------------------------------------------------------
if run_init "$T1" demo; then
	fail "4: 重复 init demo 应失败，但退出码为 0"
fi

# ---------------------------------------------------------------------------
# 用例 5: 非法 / 空 / 缺参 —— 退出码都应为 2，且不产生对应 feature 目录
# ---------------------------------------------------------------------------
check_invalid() {
	local label="$1"
	shift
	local dir="$WORK/inv_$label"
	mkdir -p "$dir"
	local rc=0
	(cd "$dir" && bash "$INIT" "$@") >/dev/null 2>&1 || rc=$?
	[[ "$rc" -eq 2 ]] || fail "5: 输入[$label] 期望退出码 2，实得 $rc"
	# 不应生成任何 feature 目录
	if [[ -d "$dir/docs/sandtable/features" ]] \
		&& [[ -n "$(ls -A "$dir/docs/sandtable/features" 2>/dev/null)" ]]; then
		fail "5: 输入[$label] 不应产生 feature 目录"
	fi
}

check_invalid "slash"   "a/b"
check_invalid "amp"     "a&b"
check_invalid "pipe"    "a|b"
check_invalid "colon"   "a:b"
check_invalid "dotdot"  ".."
check_invalid "space"   "x y"
check_invalid "empty"   ""
# 无参（特殊处理，不能给参数）
{
	local_dir="$WORK/inv_noarg"
	mkdir -p "$local_dir"
	rc=0
	(cd "$local_dir" && bash "$INIT") >/dev/null 2>&1 || rc=$?
	[[ "$rc" -eq 2 ]] || fail "5: 无参 期望退出码 2，实得 $rc"
}

echo "ALL TESTS PASSED"
