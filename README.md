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
- Simplify benchmark analysis, improve graph visuals.

# Solvers with room for improvements
- y19d03: Use line segments instead of HashMaps of all visited locations

# Benchmark
![Benchmark graph](https://github.com/Ad4u/aoc/blob/master/benchmark/graph.svg)

|   Year |   Time (µs) |
|--------|-------------|
|   2015 |         228 |
|   2016 |         124 |
|   2017 |         241 |
|   2018 |        3173 |
|   2019 |       11355 |
|   2020 |         145 |
|   2021 |         173 |
|   2022 |         128 |
|   2023 |         390 |
|   2024 |         298 |

|   Year |   Day |   Time (µs) |
|--------|-------|-------------|
|   2015 |     1 |           9 |
|   2015 |     2 |          25 |
|   2015 |     3 |         194 |
|   2016 |     1 |          42 |
|   2016 |     2 |           9 |
|   2016 |     3 |          73 |
|   2017 |     1 |           2 |
|   2017 |     2 |          23 |
|   2017 |     3 |         216 |
|   2018 |     1 |        1061 |
|   2018 |     2 |        1792 |
|   2018 |     3 |         319 |
|   2019 |     1 |           2 |
|   2019 |     2 |        1734 |
|   2019 |     3 |        9619 |
|   2020 |     1 |          88 |
|   2020 |     2 |          46 |
|   2020 |     3 |          11 |
|   2021 |     1 |          74 |
|   2021 |     2 |           6 |
|   2021 |     3 |          94 |
|   2022 |     1 |          45 |
|   2022 |     2 |          12 |
|   2022 |     3 |          70 |
|   2023 |     1 |         279 |
|   2023 |     2 |          25 |
|   2023 |     3 |          86 |
|   2024 |     1 |         137 |
|   2024 |     2 |         108 |
|   2024 |     3 |          53 |
