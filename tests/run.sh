#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
framework="${LAMBDANATIVE_DIR:-../lambdanative}"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
cp "$framework/modules/sqlite/sqlite.scm" "$test_tmp/sqlite.scm"
# Use system SQLite where development headers are installed. An existing
# LambdaNative Linux build also supplies the header needed for local checks.
if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists sqlite3; then
  sqlite_cflags=$(pkg-config --cflags sqlite3)
  sqlite_libs=$(pkg-config --libs sqlite3)
else
  mkdir -p "$test_tmp/include"
  cp "${XDG_CACHE_HOME:-$HOME/.cache}/lambdanative/linux-debug/include/sqlite3.h" "$test_tmp/include/"
  sqlite_cflags="-I$test_tmp/include"
  sqlite_libs='-l:libsqlite3.so.0'
fi
gsc -dynamic -cc-options "$sqlite_cflags" -ld-options "$sqlite_libs" \
  -o "$test_tmp/sqlite.o1" "$test_tmp/sqlite.scm" > "$test_tmp/compile.log" 2>&1 || {
  cat "$test_tmp/compile.log"
  exit 1
}
EXPENSE_TEST_SQLITE="$test_tmp/sqlite.o1" EXPENSE_TEST_DIRECTORY="$test_tmp/data" \
  gsi -e '(with-exception-catcher (lambda (e) (display-exception e) (exit 1)) (lambda () (load "tests/startup.scm")))'
