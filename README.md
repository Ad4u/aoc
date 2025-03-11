Solutions for [Advent of Code](https://adventofcode.com) in Zig.

# Usage
Use Zig build script to generate the binary: `zig build -Doptimize=ReleaseFast`.

Without any argument, the binary will read all the input data in `./inputs` and run all the available solvers.

The binary accepts the following arguments:
- The name of a solver (ie `y15d01` for year 2015 and day 1) to run only that solver
- `bench` to silence the solvers' output and run them 100 times

In all cases, the binary will output a csv file named `timings.csv` in `./benchmark` with columns: `year,day,elapsed`.

To generate markdown documents and svg, you need `Python` with `uv` installed, and execute the `analyze_benchmark.py` script.

# Todos
- Use an argument parser to better handle requested solvers, benchmarks, outputs/inputs locations, etc:
  - [zig-clap](https://github.com/Hejsil/zig-clap)
  - [yazap](https://github.com/prajwalch/yazap)
  - [zig-args](https://github.com/ikskuh/zig-args)
- Include the graph/md generation into the binary, getting rid of the Python/uv dependencies.
- Include exported markdowns in readme file.

# Solvers with room for improvements
- y19d03: Use line segments instead of HashMaps of all visited locations

# Benchmarks
<details>
<summary>All years</summary> 
![All years benchmark graph](https://github.com/Ad4u/aoc/blob/master/benchmark/total.svg)
</details>

## 2015
![2015 benchmark graph](https://github.com/Ad4u/aoc/blob/master/benchmark/2015.svg)

## 2016
![2016 benchmark graph](https://github.com/Ad4u/aoc/blob/master/benchmark/2016.svg)

## 2017
![2017 benchmark graph](https://github.com/Ad4u/aoc/blob/master/benchmark/2017.svg)
