const std = @import("std");

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var list_left = std.ArrayList(i64).init(alloc);
    var list_right = std.ArrayList(i64).init(alloc);
    defer list_left.deinit();
    defer list_right.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var rows = std.mem.tokenizeAny(u8, line, " ");
        try list_left.append(try std.fmt.parseInt(i64, rows.next().?, 10));
        try list_right.append(try std.fmt.parseInt(i64, rows.next().?, 10));
    }

    std.mem.sort(i64, list_left.items, {}, comptime std.sort.desc(i64));
    std.mem.sort(i64, list_right.items, {}, comptime std.sort.desc(i64));

    var distance: u64 = 0;
    for (0..list_left.items.len) |i| {
        distance += @abs(list_left.items[i] - list_right.items[i]);
    }

    var similary: i64 = 0;
    for (list_left.items) |left| {
        var num: i64 = 0;
        for (list_right.items) |right| {
            if (left == right) num += 1;
        }
        similary += num * left;
    }

    return .{ distance, @intCast(similary) };
}

test "y24d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    try expectEqual(.{ 11, 31 }, (try solve(alloc, input)));
}
