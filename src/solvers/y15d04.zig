const std = @import("std");
const md5 = std.crypto.hash.Md5;
const Result = @import("../solvers.zig").Result;

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var val1: ?u64 = null;
    var val2: ?u64 = null;

    const bm5: u128 = 0xffff_f000_0000_0000_0000_0000_0000_0000;
    const bm6: u128 = 0xffff_ff00_0000_0000_0000_0000_0000_0000;

    var input_buffer: [100]u8 = undefined;
    var output_buffer: [md5.digest_length]u8 = undefined;

    var i: u64 = 0;
    while (true) : (i += 1) {
        md5.hash(try std.fmt.bufPrint(&input_buffer, "{s}{}", .{ input, i }), &output_buffer, .{});

        if (std.mem.readInt(u128, &output_buffer, .big) & bm5 == 0 and val1 == null) {
            val1 = i;
        }
        if (std.mem.readInt(u128, &output_buffer, .big) & bm6 == 0 and val2 == null) {
            val2 = i;
        }

        if (val1 != null and val2 != null) break;
    }

    return Result.from(u64, .{ val1.?, val2.? });
}

test "y15d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(609043, (try solve(alloc, "abcdef")).ints[0]);
    try expectEqual(1048970, (try solve(alloc, "pqrstuv")).ints[0]);
}
