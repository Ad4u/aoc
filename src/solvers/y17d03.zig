const std = @import("std");

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]u64 {
    const target = try std.fmt.parseInt(i64, input, 10);
    var size: i64 = 3;

    while (size * size < target) {
        size += 2;
    }

    const b = size - 1;
    const c = size - 2;

    const edge_dist = @abs(@divTrunc(c, 2) - @rem((target - c * c - 1), b));

    const dist = (@abs(@divTrunc(b, 2))) + edge_dist;

    return .{ dist, 0 };
}

test "y17d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(3, (try solve(alloc, "12"))[0]);
    try expectEqual(2, (try solve(alloc, "23"))[0]);
    try expectEqual(31, (try solve(alloc, "1024"))[0]);
}
