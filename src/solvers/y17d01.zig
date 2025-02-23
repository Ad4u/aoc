const std = @import("std");

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]u64 {
    var sum_1: u64 = 0;
    var sum_2: u64 = 0;

    for (input, 0..) |c, i| {
        const num = c - '0';

        if (c == input[(i + 1) % input.len]) {
            sum_1 += num;
        }

        if (c == input[(i + input.len / 2) % input.len]) {
            sum_2 += num;
        }
    }

    return .{ sum_1, sum_2 };
}

test "y17d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(3, (try solve(alloc, "1122"))[0]);
    try expectEqual(4, (try solve(alloc, "1111"))[0]);
    try expectEqual(0, (try solve(alloc, "1234"))[0]);
    try expectEqual(9, (try solve(alloc, "91212129"))[0]);

    try expectEqual(6, (try solve(alloc, "1212"))[1]);
    try expectEqual(0, (try solve(alloc, "1221"))[1]);
    try expectEqual(4, (try solve(alloc, "123425"))[1]);
    try expectEqual(12, (try solve(alloc, "123123"))[1]);
    try expectEqual(4, (try solve(alloc, "12131415"))[1]);
}
