Solutions for [Advent of Code](https://adventofcode.com) in Zig.

# Usage
Use Zig build script to generate the binary: `zig build -Doptimize=ReleaseFast`.

Without any argument, the binary will read all the input data in `./inputs` and run all the available solvers.

The binary accepts as argument the name of a solver (ie `y15d01` for year 2015 and day 1) to run only that solver

In all cases, the binary will output a csv file named `timings.csv` in the root folder with columns: `year,day,elapsed`.

To generate the graph and the markdown table from the `timings.csv` file, you need `Python` and `uv` installed, then and execute the `benchmark.py` script.

# Todos
- Use an argument parser to better handle requested solvers, benchmarks, outputs/inputs locations, etc:
  - [zig-clap](https://github.com/Hejsil/zig-clap)
  - [yazap](https://github.com/prajwalch/yazap)
  - [zig-args](https://github.com/ikskuh/zig-args)
- (?) Include the graph/md generation into the binary, getting rid of the Python/uv dependencies.
- (?) Auto-Download input files.

# Solvers with room for improvements
- y19d03: Use line segments instead of HashMaps of all visited locations

# Benchmark
![Benchmark graph](https://github.com/Ad4u/aoc/blob/master/graph.svg)
