const std = @import("std");
const Result = @import("../solvers.zig").Result;

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var trees: [512][32]bool = @splat(@splat(false)); // Y, X

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var height: usize = 0;
    var width: usize = 0;
    while (lines.next()) |line| : (height += 1) {
        width = 0;
        for (line) |c| {
            switch (c) {
                '.' => trees[height][width] = false,
                '#' => trees[height][width] = true,
                else => return error.BadInput,
            }
            width += 1;
        }
    }

    const move: [5]@Vector(2, usize) = .{ .{ 1, 1 }, .{ 3, 1 }, .{ 5, 1 }, .{ 7, 1 }, .{ 1, 2 } };

    var encounters: [5]usize = [_]usize{0} ** 5;

    var loop: usize = 0;
    while (loop < 5) : (loop += 1) {
        var position: @Vector(2, usize) = .{ 0, 0 };
        while (position[1] < height) {
            position += move[loop];
            if (trees[position[1]][position[0] % width]) encounters[loop] += 1;
        }
    }

    var mul: usize = 1;
    for (encounters) |e| {
        mul *= e;
    }

    return Result.from(usize, .{ encounters[1], mul });
}

test "y20d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\..##.......
        \\#...#...#..
        \\.#....#..#.
        \\..#.#...#.#
        \\.#...##..#.
        \\..#.##.....
        \\.#.#.#....#
        \\.#........#
        \\#.##...#...
        \\#...##....#
        \\.#..#...#.#
    ;

    try expectEqual(.{ 7, 336 }, (try solve(alloc, input)).ints);
}
