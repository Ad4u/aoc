#!/bin/sh

zig build -Doptimize=ReleaseFast

SOLVERS="$(ls -m ./src/solvers/ | tr -d '.zig \n')"

hyperfine -w 50 -M 100 \
--export-csv benchmark/solvers.csv \
--sort command \
-L solvers "$SOLVERS" './zig-out/bin/aoc {solvers}' 2> /dev/null

hyperfine -w 50 \
--export-csv benchmark/total.csv \
'./zig-out/bin/aoc'
