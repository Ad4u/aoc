#!/bin/bash

zig build run -Doptimize=ReleaseFast -- bench
./analyze_benchmark.py
