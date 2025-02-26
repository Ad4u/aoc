#!/bin/sh

zig build -Doptimize=ReleaseFast

SOLVERS="$(ls -m ./src/solvers/ | tr -d '.zig \n')"

hyperfine -w 50 -M 100 \
--export-csv benchmark/bench.csv \
--sort command \
-L solvers "$SOLVERS" './zig-out/bin/aoc {solvers}' 2> /dev/null
