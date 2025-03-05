const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn mul(win: []const u8) !u64 {
    const slice1 = std.mem.sliceTo(win[4..], ',');
    const a = try std.fmt.parseInt(u64, slice1, 10);

    const slice2 = std.mem.sliceTo(win[5 + slice1.len ..], ')');
    const b = try std.fmt.parseInt(u64, slice2, 10);

    return a * b;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    // We need to extend a bit the input to take into account the edge case when
    // "mul(" is at the very end.
    var chars = std.ArrayList(u8).init(alloc);
    try chars.appendSlice(input);
    try chars.appendSlice("    ");
    defer chars.deinit();

    var total_1: u64 = 0;
    var total_2: u64 = 0;
    var enabled: bool = true;

    var iter = std.mem.window(u8, chars.items, 12, 1);
    var i: usize = 0;
    while (iter.next()) |win| : (i += 1) {
        if (std.mem.startsWith(u8, win, "do()")) enabled = true;
        if (std.mem.startsWith(u8, win, "don't()")) enabled = false;

        if (std.mem.startsWith(u8, win, "mul(")) {
            const result = mul(win) catch continue;

            total_1 += result;
            if (enabled) total_2 += result;
        }
    }

    return Result.from(u64, .{ total_1, total_2 });
}

test "y24d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input_1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    const input_2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    try expectEqual(161, (try solve(alloc, input_1)).ints[0]);
    try expectEqual(48, (try solve(alloc, input_2)).ints[1]);
}
