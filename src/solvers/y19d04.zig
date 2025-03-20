const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn isValid(num: u64) [2]bool {
    var digits: [6]u8 = undefined;
    var val = num;

    var i: usize = 5;
    while (true) : (i -= 1) {
        digits[i] = @intCast(val % 10);
        val /= 10;
        if (i == 0) break;
    }

    var has_pair = false;
    var has_double_only = false;

    var prev: u8 = digits[0];
    var span: u8 = 1;

    var j: usize = 1;
    while (j < 6) : (j += 1) {
        const curr = digits[j];
        if (curr < prev) return .{ false, false };

        if (prev == curr) {
            span += 1;
            has_pair = true;
        } else {
            if (span == 2) has_double_only = true;
            span = 1;
        }

        prev = curr;
    }

    const valid_1 = has_pair;
    const valid_2 = has_double_only or span == 2;

    return .{ valid_1, valid_2 };
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    const sep_idx = std.mem.indexOf(u8, input, "-") orelse return error.BadInput;
    const lower = try std.fmt.parseInt(u64, input[0..sep_idx], 10);
    const upper = try std.fmt.parseInt(u64, input[sep_idx + 1 ..], 10);

    var total_1: u64 = 0;
    var total_2: u64 = 0;

    for (lower..upper + 1) |n| {
        const val1, const val2 = isValid(n);
        if (val1) total_1 += 1;
        if (val2) total_2 += 1;
    }

    return Result.from(u64, .{ total_1, total_2 });
}

test "y19d04" {
    // const alloc = std.testing.allocator;
    const expect = std.testing.expect;

    try expect(isValid(111111)[0]);
    try expect(!isValid(223450)[0]);
    try expect(!isValid(123789)[0]);

    try expect(isValid(112233)[1]);
    try expect(!isValid(123444)[1]);
    try expect(isValid(111122)[1]);

    try expect(!isValid(111111)[1]);
}
