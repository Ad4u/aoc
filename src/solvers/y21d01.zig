const std = @import("std");

fn countDirectIncreases(arr: std.ArrayList(u64)) u64 {
    var increases: u64 = 0;
    var win = std.mem.window(u64, arr.items, 2, 1);
    while (win.next()) |w| {
        increases += @intFromBool(w[1] > w[0]);
    }
    return increases;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var depths = std.ArrayList(u64).init(alloc);
    defer depths.deinit();

    var depths_avg = std.ArrayList(u64).init(alloc);
    defer depths_avg.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try depths.append(try std.fmt.parseInt(u64, line, 10));
    }

    var win = std.mem.window(u64, depths.items, 3, 1);
    while (win.next()) |w| {
        try depths_avg.append(w[0] + w[1] + w[2]);
    }

    return .{ countDirectIncreases(depths), countDirectIncreases(depths_avg) };
}

test "y20d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\199
        \\200
        \\208
        \\210
        \\200
        \\207
        \\240
        \\269
        \\260
        \\263
    ;

    try expectEqual(.{ 7, 5 }, (try solve(alloc, input)));
}
