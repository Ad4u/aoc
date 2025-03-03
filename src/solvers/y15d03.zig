const std = @import("std");
const Result = @import("../solvers.zig").Result;

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var santa_alone = std.AutoHashMap([2]i64, void).init(alloc);
    defer santa_alone.deinit();

    var santa_robo = std.AutoHashMap([2]i64, void).init(alloc);
    defer santa_robo.deinit();

    var position_santa_alone: [2]i64 = .{ 0, 0 }; // X, Y
    var position_santa: [2]i64 = .{ 0, 0 }; // X, Y
    var position_robo: [2]i64 = .{ 0, 0 }; // X, Y

    try santa_alone.put(position_santa_alone, {});
    try santa_robo.put(position_santa, {});

    for (input, 0..) |char, i| {
        var position: *[2]i64 = undefined;
        switch (i % 2) {
            0 => position = &position_santa,
            1 => position = &position_robo,
            else => unreachable,
        }

        switch (char) {
            '<' => {
                position_santa_alone[0] -= 1;
                position.*[0] -= 1;
            },
            '>' => {
                position_santa_alone[0] += 1;
                position.*[0] += 1;
            },
            '^' => {
                position_santa_alone[1] += 1;
                position.*[1] += 1;
            },
            'v' => {
                position_santa_alone[1] -= 1;
                position.*[1] -= 1;
            },
            else => return error.BadInput,
        }

        try santa_alone.put(position_santa_alone, {});
        try santa_robo.put(position.*, {});
    }

    return Result.from(i64, .{ santa_alone.count(), santa_robo.count() });
}

test "y15d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(2, (try solve(alloc, ">")).ints[0]);
    try expectEqual(4, (try solve(alloc, "^>v<")).ints[0]);
    try expectEqual(2, (try solve(alloc, "^v^v^v^v^v")).ints[0]);

    try expectEqual(3, (try solve(alloc, "^v")).ints[1]);
    try expectEqual(3, (try solve(alloc, "^>v<")).ints[1]);
    try expectEqual(11, (try solve(alloc, "^v^v^v^v^v")).ints[1]);
}
