const std = @import("std");

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]i64 {
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

    return .{ floor, basement_idx orelse 0 };
}

test "y15d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(0, (try solve(alloc, "(())"))[0]);
    try expectEqual(0, (try solve(alloc, "()()"))[0]);
    try expectEqual(3, (try solve(alloc, "((("))[0]);
    try expectEqual(3, (try solve(alloc, "(()(()("))[0]);
    try expectEqual(3, (try solve(alloc, "))((((("))[0]);
    try expectEqual(-1, (try solve(alloc, "())"))[0]);
    try expectEqual(-1, (try solve(alloc, "))("))[0]);
    try expectEqual(-3, (try solve(alloc, ")))"))[0]);
    try expectEqual(-3, (try solve(alloc, ")())())"))[0]);

    try expectEqual(1, (try solve(alloc, ")"))[1]);
    try expectEqual(5, (try solve(alloc, "()())"))[1]);
}
