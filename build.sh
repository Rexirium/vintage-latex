#!/bin/sh
# SPDX-License-Identifier: CC-BY-SA-4.0
# Compile every example into build/<name>/. Run from the repository root.
# Usage: ./build.sh [path-to-fiziko] [example-name ...]
# Without a fiziko path (or MPINPUTS already set) the fiziko examples are skipped.
set -u
pathsep=:
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) pathsep=';' ;; esac
if [ "${1:-}" != "" ] && [ -d "$1" ]; then
  fiziko_dir=$(cd "$1" && pwd)
  if [ "$pathsep" = ';' ]; then fiziko_dir=$(cygpath -m "$fiziko_dir"); fi
  MPINPUTS="$fiziko_dir$pathsep"; export MPINPUTS; shift
fi
mkdir -p build
failed=""
for file in examples/*/*.tex examples/*/*.mp; do
  [ -f "$file" ] || continue
  name=$(basename "${file%.*}")
  if [ "$#" -gt 0 ]; then
    case " $* " in *" $name "*) ;; *) continue ;; esac
  fi
  case "$name" in *fiziko*)
    if [ -z "${MPINPUTS:-}" ]; then echo "SKIP $name (MPINPUTS not set)"; continue; fi ;;
  esac
  outdir="build/$name"
  mkdir -p "$outdir" || exit 1
  case "$file" in
    *.tex) lualatex -interaction=nonstopmode -halt-on-error -output-directory="$outdir" "$file" > "$outdir/$name.stdout.txt" 2>&1 ;;
    # TeX Live's mpost cannot read the mpx file its btex step writes when
    # -output-directory is used, so run it from inside the example's directory.
    *.mp)  (
      source_dir=$(cd "$(dirname "$file")" && pwd) || exit 1
      if [ "$pathsep" = ';' ]; then source_dir=$(cygpath -m "$source_dir"); fi
      # Windows MetaPost can crash on parent paths; resolve the basename instead.
      MPINPUTS="$source_dir$pathsep${MPINPUTS:-}"; export MPINPUTS
      cd "$outdir" && mpost -interaction=nonstopmode -halt-on-error "$(basename "$file")"
    ) > "$outdir/$name.stdout.txt" 2>&1 ;;
  esac
  if [ $? -eq 0 ]; then echo "OK   $name"; else echo "FAIL $name"; failed="$failed $name"; fi
done
if [ -n "$failed" ]; then echo "Failed:$failed" >&2; exit 1; fi
