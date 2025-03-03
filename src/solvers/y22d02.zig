const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn calcScore_1(line: []const u8) u64 {
    var score = line[2] - 'X' + 1;

    const delta = (line[2] - line[0] + 3 - 23) % 3;
    if (delta == 1) score += 6;
    if (delta == 0) score += 3;

    return score;
}

fn calcScore_2(line: []const u8) u64 {
    var delta = (line[2] + line[0] - 128 - 25) % 3;
    if (delta == 0) delta = 3;

    return delta + ((line[2] - 'X') * 3);
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var score_1: u64 = 0;
    var score_2: u64 = 0;
    while (lines.next()) |line| {
        score_1 += calcScore_1(line);
        score_2 += calcScore_2(line);
    }

    return Result.from(u64, .{ score_1, score_2 });
}

test "y22d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\A Y
        \\B X
        \\C Z
    ;

    try expectEqual(.{ 15, 12 }, (try solve(alloc, input)).ints);
}
