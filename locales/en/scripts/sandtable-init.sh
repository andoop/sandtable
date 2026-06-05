#!/usr/bin/env bash
#
# sandtable-init.sh - initialize the sandtable workspace in the current working directory
#
# Usage: sandtable-init.sh <slug> [date]
#   <slug>  required, only [A-Za-z0-9-] allowed
#   [date]  optional, defaults to `date +%F` (YYYY-MM-DD)
#
set -euo pipefail

usage() {
	cat >&2 <<'EOF'
Usage: sandtable-init.sh <slug> [date]
  <slug>  required, only characters [A-Za-z0-9-] are allowed (no spaces, / : & | . or non-ASCII text)
  [date]  optional, format YYYY-MM-DD, defaults to today
EOF
}

# Current ISO8601 time, with a colon in the timezone suffix.
now_iso8601() {
	local ts
	ts=$(date +%Y-%m-%dT%H:%M:%S%z)
	printf '%s:%s\n' "${ts:0:${#ts}-2}" "${ts: -2}"
}

main() {
	if [[ $# -lt 1 || $# -gt 2 ]]; then
		usage
		exit 2
	fi

	local slug="$1"
	local date="${2:-$(date +%F)}"

	if [[ ! "$slug" =~ ^[A-Za-z0-9-]+$ ]]; then
		usage
		exit 2
	fi

	local script_dir templates_dir
	script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
	templates_dir="$(dirname "$script_dir")/templates"

	if [[ ! -d "$templates_dir" ]]; then
		echo "Error: templates directory does not exist: $templates_dir" >&2
		exit 1
	fi

	local root="docs/sandtable"
	local feature_dir="$root/features/${date}-${slug}"

	if [[ -e "$feature_dir" ]]; then
		echo "Error: feature already exists: $feature_dir (existing content will not be overwritten)" >&2
		exit 1
	fi

	mkdir -p "$root"

	local created=()
	local skipped=()
	local f
	for f in project.md constraints.md; do
		if [[ -e "$root/$f" ]]; then
			skipped+=("$root/$f")
		else
			cp "$templates_dir/$f" "$root/$f"
			created+=("$root/$f")
		fi
	done

	mkdir -p "$feature_dir"
	mkdir -p "$feature_dir/rehearsals"
	created+=("$feature_dir/")
	created+=("$feature_dir/rehearsals/")

	for f in prd.md tests.md plan.md state.md journal.md questions.md; do
		cp "$templates_dir/$f" "$feature_dir/$f"
		created+=("$feature_dir/$f")
	done

	local updated
	updated=$(now_iso8601)
	local state_file="$feature_dir/state.md"
	local tmp
	tmp=$(mktemp)
	sed \
		-e "s|^feature: .*|feature: ${date}-${slug}|" \
		-e "s|^updated: .*|updated: ${updated}|" \
		"$state_file" >"$tmp"
	mv "$tmp" "$state_file"

	echo "Initialized sandtable workspace: ${date}-${slug}"
	echo
	echo "Created / reused:"
	for f in ${created[@]+"${created[@]}"}; do
		echo "  + $f"
	done
	for f in ${skipped[@]+"${skipped[@]}"}; do
		echo "  = $f (already exists, skipped)"
	done
	echo
	echo "Next step: run /sandtable-recon to start reconnaissance."
}

main "$@"
