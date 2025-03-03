const std = @import("std");
const Result = @import("../solvers.zig").Result;

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var elfes = std.ArrayList(u64).init(alloc);
    defer elfes.deinit();

    var groups = std.mem.tokenizeSequence(u8, input, "\n\n");
    while (groups.next()) |group| {
        var calories: u64 = 0;
        var lines = std.mem.tokenizeScalar(u8, group, '\n');
        while (lines.next()) |line| {
            calories += try std.fmt.parseInt(u64, line, 10);
        }
        try elfes.append(calories);
    }

    std.mem.sort(u64, elfes.items, {}, comptime std.sort.desc(u64));

    return Result.from(u64, .{ elfes.items[0], elfes.items[0] + elfes.items[1] + elfes.items[2] });
}

test "y22d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\1000
        \\2000
        \\3000
        \\
        \\4000
        \\
        \\5000
        \\6000
        \\
        \\7000
        \\8000
        \\9000
        \\
        \\10000
    ;

    try expectEqual(.{ 24000, 45000 }, (try solve(alloc, input)).ints);
}
