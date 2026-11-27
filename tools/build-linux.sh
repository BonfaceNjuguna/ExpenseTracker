#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
framework=$(cd "${LAMBDANATIVE_DIR:-$repo/../lambdanative}" && pwd)
output="$repo/.local-build/linux"
mkdir -p "$output" "$framework/apps/ExpenseTracker"
cp -a "$repo/ExpenseTracker/." "$framework/apps/ExpenseTracker/"
python3 "$repo/tools/patch-linux-scroll.py" "$framework"
cd "$framework"
./configure ExpenseTracker linux debug
make > "$output/build.log" 2>&1 || { tail -n 100 "$output/build.log"; exit 1; }
version=$(head -n 1 "$repo/ExpenseTracker/VERSION")
archive="${XDG_CACHE_HOME:-$HOME/.cache}/lambdanative/packages/ExpenseTracker-$version-linux.zip"
unzip -oq "$archive" -d "$output"
echo "Built: $output/ExpenseTracker/ExpenseTracker"
echo "Run: $output/ExpenseTracker/ExpenseTracker"
