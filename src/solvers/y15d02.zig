const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn parseLine(line: []const u8) ![3]u64 {
    var lengths: [3]u64 = undefined;

    var dims = std.mem.tokenizeScalar(u8, line, 'x');
    var i: usize = 0;
    while (dims.next()) |d| : (i += 1) {
        lengths[i] = try std.fmt.parseInt(u64, d, 10);
    }
    std.mem.sort(u64, &lengths, {}, comptime std.sort.asc(u64));
    return lengths;
}

fn calcSurface(l: [3]u64) u64 {
    return (l[0] * l[1] + l[1] * l[2] + l[2] * l[0]) * 2 + l[0] * l[1];
}

fn calcRibbon(l: [3]u64) u64 {
    return (l[0] + l[1]) * 2 + l[0] * l[1] * l[2];
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var total_surface: u64 = 0;
    var total_ribbon: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const lengths = try parseLine(line);
        total_surface += calcSurface(lengths);
        total_ribbon += calcRibbon(lengths);
    }

    return Result.from(u64, .{ total_surface, total_ribbon });
}

test "y15d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(.{ 58, 34 }, (try solve(alloc, "2x3x4")).ints);
    try expectEqual(.{ 43, 14 }, (try solve(alloc, "1x1x10")).ints);
}
