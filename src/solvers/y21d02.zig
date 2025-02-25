const std = @import("std");

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]i64 {
    var position_1: [2]i64 = .{ 0, 0 }; //Depth, Horizontal
    var position_2: [3]i64 = .{ 0, 0, 0 }; //Depth, Horizontal, Aim

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const value = try std.fmt.parseInt(i64, &[_]u8{line[line.len - 1]}, 10);
        const instruction = line[0];

        switch (instruction) {
            'f' => {
                position_1[1] += value;
                position_2[0] += position_2[2] * value;
                position_2[1] += value;
            },
            'd' => {
                position_1[0] += value;
                position_2[2] += value;
            },
            'u' => {
                position_1[0] -= value;
                position_2[2] -= value;
            },
            else => return error.BadInput,
        }
    }

    return .{ position_1[0] * position_1[1], position_2[0] * position_2[1] };
}

test "y21d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\forward 5
        \\down 5
        \\forward 8
        \\up 3
        \\down 8
        \\forward 2
    ;

    try expectEqual(.{ 150, 900 }, (try solve(alloc, input)));
}
