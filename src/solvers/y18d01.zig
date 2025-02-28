const std = @import("std");

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]i64 {
    var twice_frequency: i64 = 0;
    var final_frequency: i64 = 0;

    const visited_len = 1024 * 1024;
    var visited: [visited_len * 2]bool = [_]bool{false} ** (visited_len * 2);
    visited[visited_len] = true;

    var first_loop = true;
    loop: while (true) {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            const value = try std.fmt.parseInt(i64, line, 10);
            if (first_loop) final_frequency += value;

            twice_frequency += value;

            const idx = @as(usize, @intCast(visited_len + twice_frequency));
            if (visited[idx]) break :loop;

            visited[idx] = true;
        }
        first_loop = false;
    }

    return .{ final_frequency, twice_frequency };
}

test "y18d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(.{ 0, 0 }, (try solve(alloc, "+1\n-1")));
    try expectEqual(.{ 4, 10 }, (try solve(alloc, "+3\n+3\n+4\n-2\n-4")));
    try expectEqual(.{ 4, 5 }, (try solve(alloc, "-6\n+3\n+8\n+5\n-6")));
    try expectEqual(.{ 1, 14 }, (try solve(alloc, "+7\n+7\n-2\n-7\n-4")));
}
