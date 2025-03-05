const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn hasEdgeSymbol(grid: [256][256]u8, gears: *std.AutoHashMap([2]usize, [2]?u64), row: usize, start: usize, end: usize, num: u64) !bool {
    var found_symbol: bool = false;

    for (row - 1..row + 2) |j| {
        for (start - 1..end + 1) |i| {
            const c = grid[j][i];

            if (c != '.' and !std.ascii.isDigit(c)) {
                // A gear is found around the number, it is a part
                found_symbol = true;

                // Also, we register that number to the gear
                const entry = try gears.getOrPut(.{ j, i });

                if (entry.found_existing) {
                    entry.value_ptr.*[1] = num;
                } else {
                    entry.value_ptr.*[0] = num;
                    entry.value_ptr.*[1] = null;
                }
            }
        }
    }

    return found_symbol;
}

fn scanGrid(grid: [256][256]u8, gears: *std.AutoHashMap([2]usize, [2]?u64), nrows: usize, ncols: usize) !u64 {
    var total: u64 = 0;

    var start: ?usize = null;
    var end: ?usize = null;
    for (1..nrows + 1) |row| {
        for (1..ncols + 2) |col| {
            const c = grid[row][col];

            if (std.ascii.isDigit(c)) {
                if (start == null) { // New number
                    start = col;
                }
            } else {
                if (start != null) { // End of number
                    end = col;
                }
            }

            if (start != null and end != null) {
                const start_nn = start.?;
                const end_nn = end.?;
                const num = try std.fmt.parseInt(u64, grid[row][start_nn..end_nn], 10);
                if (try hasEdgeSymbol(grid, gears, row, start_nn, end_nn, num)) {
                    total += num;
                }

                start = null;
                end = null;
            }
        }
    }

    return total;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var nrows: usize = 0;
    var ncols: usize = 0;

    // This is the input grid
    var grid: [256][256]u8 = undefined; // Row, Col
    for (&grid) |*row| {
        @memset(row, '.');
    }

    // Hashmap to keep track for gears positions and adjacent numbers
    var gears = std.AutoHashMap([2]usize, [2]?u64).init(alloc);
    defer gears.deinit();

    // Populate grid
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| : (nrows += 1) {
        ncols = 0;
        for (line) |c| {
            grid[nrows + 1][ncols + 1] = c; // The grid is shifted by one for edge cases
            ncols += 1;
        }
    }

    // Scan grid for numbers
    // Check if number is surrouned by a gear
    // If yes, keep it as part number and insert/update gears entry
    const sum_parts = try scanGrid(grid, &gears, nrows, ncols);

    // Iterate gears to calculate part 2
    var sum_ratios: u64 = 0;
    var gears_iter = gears.iterator();
    while (gears_iter.next()) |entry| {
        const gear = entry.value_ptr.*;
        if (gear[1] != null) sum_ratios += gear[0].? * gear[1].?;
    }

    return Result.from(u64, .{ sum_parts, sum_ratios });
}

test "y23d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;

    try expectEqual(.{ 4361, 467835 }, (try solve(alloc, input)).ints);
}
