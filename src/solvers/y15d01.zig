const std = @import("std");
const Result = @import("../solvers.zig").Result;

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var floor: i64 = 0;
    var basement_idx: ?i64 = null;

    for (input, 0..) |c, idx| {
        switch (c) {
            '(' => floor += 1,
            ')' => floor -= 1,
            else => return error.BadInput,
        }
        if (basement_idx == null and floor < 0) {
            basement_idx = @intCast(idx + 1);
        }
    }

    return Result.from(i64, .{ floor, basement_idx orelse 0 });
}

test "y15d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(0, (try solve(alloc, "(())")).ints[0]);
    try expectEqual(0, (try solve(alloc, "()()")).ints[0]);
    try expectEqual(3, (try solve(alloc, "(((")).ints[0]);
    try expectEqual(3, (try solve(alloc, "(()(()(")).ints[0]);
    try expectEqual(3, (try solve(alloc, "))(((((")).ints[0]);
    try expectEqual(-1, (try solve(alloc, "())")).ints[0]);
    try expectEqual(-1, (try solve(alloc, "))(")).ints[0]);
    try expectEqual(-3, (try solve(alloc, ")))")).ints[0]);
    try expectEqual(-3, (try solve(alloc, ")())())")).ints[0]);

    try expectEqual(1, (try solve(alloc, ")")).ints[1]);
    try expectEqual(5, (try solve(alloc, "()())")).ints[1]);
}
