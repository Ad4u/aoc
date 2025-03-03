const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn calcChecksum(line: []const u8) !u64 {
    var max: u64 = 0;
    var min: u64 = std.math.maxInt(u64);

    var entries = std.mem.tokenizeAny(u8, line, " \t");
    while (entries.next()) |entry| {
        const num = try std.fmt.parseInt(u64, entry, 10);
        if (num > max) max = num;
        if (num < min) min = num;
    }

    return max - min;
}

fn calcRem(line: []const u8) !u64 {
    var outer = std.mem.tokenizeAny(u8, line, " \t");

    while (outer.next()) |out_entry| {
        const out_num = try std.fmt.parseInt(u64, out_entry, 10);
        var inner = std.mem.tokenizeAny(u8, line, " \t");
        while (inner.next()) |inn_entry| {
            const inn_num = try std.fmt.parseInt(u64, inn_entry, 10);
            if (out_num != inn_num and @rem(out_num, inn_num) == 0) {
                return if (out_num > inn_num) @divExact(out_num, inn_num) else @divExact(inn_num, out_num);
            }
        }
    }
    return 0; // We could return LogicError but then tests are not running
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var total_checksum: u64 = 0;
    var total_rem: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        total_checksum += try calcChecksum(line);
        total_rem += try calcRem(line);
    }

    return Result.from(u64, .{ total_checksum, total_rem });
}

test "y17d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input_1 =
        \\5 1 9 5
        \\7 5 3
        \\2 4 6 8
    ;

    const input_2 =
        \\5 9 2 8
        \\9 4 7 3
        \\3 8 6 5
    ;

    try expectEqual(18, (try solve(alloc, input_1)).ints[0]);
    try expectEqual(9, (try solve(alloc, input_2)).ints[1]);
}
