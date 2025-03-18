const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn parseLine(input: []const u8) ![4]u8 {
    var ranges: [4]u8 = undefined;
    var iter = std.mem.tokenizeAny(u8, input, "-,");
    var i: usize = 0;
    while (iter.next()) |str| : (i += 1) {
        ranges[i] = try std.fmt.parseInt(u8, str, 10);
    }

    return ranges;
}

fn doContain(r: [4]u8) bool {
    if (r[0] <= r[2] and r[1] >= r[3]) return true;
    if (r[0] >= r[2] and r[1] <= r[3]) return true;
    return false;
}

fn doOverlap(r: [4]u8) bool {
    // r[0] is always below r[1], same for r[2] and r[3]
    if (r[1] < r[2]) return false;
    if (r[0] > r[3]) return false;
    return true;
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var n_contain: u64 = 0;
    var n_overlap: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const ranges = try parseLine(line);
        if (doContain(ranges)) n_contain += 1;
        if (doOverlap(ranges)) n_overlap += 1;
    }

    return Result.from(u64, .{ n_contain, n_overlap });
}

test "y22d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\2-4,6-8
        \\2-3,4-5
        \\5-7,7-9
        \\2-8,3-7
        \\6-6,4-6
        \\2-6,4-8
    ;

    try expectEqual(.{ 2, 4 }, (try solve(alloc, input)).ints);
}
