const std = @import("std");
const Result = @import("../solvers.zig").Result;

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var counts: [8][26]u32 = @splat(@splat(0));

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        for (line, 0..) |c, i| {
            counts[i][c - 'a'] += 1;
        }
    }

    var word_max: [8]u8 = undefined;
    var word_min: [8]u8 = undefined;

    for (counts, 0..) |col, i| {
        var max: u32 = 0;
        var min: u32 = std.math.maxInt(u32);

        for (col, 0..) |count, c| {
            if (count > max and count > 0) {
                max = count;
                word_max[i] = @as(u8, @intCast(c)) + 'a';
            }
            if (count < min and count > 0) {
                min = count;
                word_min[i] = @as(u8, @intCast(c)) + 'a';
            }
        }
    }

    var list_1 = std.ArrayList(u8).init(alloc);
    var list_2 = std.ArrayList(u8).init(alloc);

    try list_1.appendSlice(&word_max);
    try list_2.appendSlice(&word_min);

    return Result.from(std.ArrayList(u8), .{ list_1, list_2 });
}

test "y16d06" {
    const alloc = std.testing.allocator;
    const expectEqualStrings = std.testing.expectEqualStrings;

    const input =
        \\eedadn
        \\drvtee
        \\eandsr
        \\raavrd
        \\atevrs
        \\tsrnev
        \\sdttsa
        \\rasrtv
        \\nssdts
        \\ntnada
        \\svetve
        \\tesnvt
        \\vntsnd
        \\vrdear
        \\dvrsen
        \\enarar
    ;

    const result = try solve(alloc, input);
    defer {
        for (result.strs) |list| list.deinit();
    }

    try expectEqualStrings("easter", result.strs[0].items[0..6]);
    try expectEqualStrings("advent", result.strs[1].items[0..6]);
}
