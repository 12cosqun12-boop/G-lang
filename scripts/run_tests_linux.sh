#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
G="$ROOT/bin/linux-x86_64/g"
BUILD="$ROOT/build-linux"
mkdir -p "$BUILD" "$ROOT/build"
fail=0
cd "$ROOT"
for src in "$ROOT"/tests/*.g; do
  name=$(basename "$src" .g)
  out="$BUILD/$name"
  "$G" "$src" "$out"
  chmod +x "$out"
  if [ -f "$ROOT/tests/$name.args" ]; then
    # shellcheck disable=SC2046
    "$out" $(cat "$ROOT/tests/$name.args") > "$BUILD/$name.actual"
  else
    "$out" > "$BUILD/$name.actual"
  fi
  if cmp -s "$BUILD/$name.actual" "$ROOT/tests/$name.expected"; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    fail=1
  fi
done
exit "$fail"
