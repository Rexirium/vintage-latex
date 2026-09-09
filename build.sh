#!/bin/sh
# SPDX-License-Identifier: CC-BY-SA-4.0
# Compile every example into build/. Run from the repository root.
# Usage: ./build.sh [path-to-fiziko] [example-name ...]
# Without a fiziko path (or MPINPUTS already set) the fiziko examples are skipped.
set -u
if [ "${1:-}" != "" ] && [ -d "$1" ]; then
  MPINPUTS="$(cd "$1" && pwd):"; export MPINPUTS; shift
fi
mkdir -p build
failed=""
for file in examples/*.tex examples/*.mp; do
  name=$(basename "${file%.*}")
  if [ "$#" -gt 0 ]; then
    case " $* " in *" $name "*) ;; *) continue ;; esac
  fi
  case "$name" in *fiziko*)
    if [ -z "${MPINPUTS:-}" ]; then echo "SKIP $name (MPINPUTS not set)"; continue; fi ;;
  esac
  case "$file" in
    *.tex) lualatex -interaction=nonstopmode -halt-on-error -output-directory=build "$file" > "build/$name.stdout.txt" 2>&1 ;;
    # TeX Live's mpost cannot read the mpx file its btex step writes when
    # -output-directory is used, so run it from inside build/ instead.
    *.mp)  (cd build && mpost -interaction=nonstopmode -halt-on-error "../$file") > "build/$name.stdout.txt" 2>&1 ;;
  esac
  if [ $? -eq 0 ]; then echo "OK   $name"; else echo "FAIL $name"; failed="$failed $name"; fi
done
if [ -n "$failed" ]; then echo "Failed:$failed" >&2; exit 1; fi
