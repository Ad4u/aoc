const std = @import("std");

const KEYPAD_NORM: [3][3]u8 = .{ .{ '1', '2', '3' }, .{ '4', '5', '6' }, .{ '7', '8', '9' } };
const KEYPAD_DIAM: [5][5]u8 = .{ .{ '0', '0', '1', '0', '0' }, .{ '0', '2', '3', '4', '0' }, .{ '5', '6', '7', '8', '9' }, .{ '0', 'A', 'B', 'C', '0' }, .{ '0', '0', 'D', '0', '0' } };

fn move(position: [2]usize, max: usize, ins: u8) ![2]usize {
    var new_position = position;
    switch (ins) {
        'U' => if (new_position[0] != 0) {
            new_position[0] -= 1;
        },
        'D' => if (new_position[0] != max) {
            new_position[0] += 1;
        },
        'L' => if (new_position[1] != 0) {
            new_position[1] -= 1;
        },
        'R' => if (new_position[1] != max) {
            new_position[1] += 1;
        },
        else => return error.BadInput,
    }
    return new_position;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]std.ArrayList(u8) {
    var code_1 = std.ArrayList(u8).init(alloc);
    var position_1: [2]usize = .{ 1, 1 }; // Row, Col
    var code_2 = std.ArrayList(u8).init(alloc);
    var position_2: [2]usize = .{ 2, 0 }; // Row, Col

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        for (line) |c| {
            position_1 = try move(position_1, 2, c);

            const test_position = try move(position_2, 4, c);
            if (KEYPAD_DIAM[test_position[0]][test_position[1]] != '0') {
                position_2 = test_position;
            }
        }

        try code_1.append(KEYPAD_NORM[position_1[0]][position_1[1]]);
        try code_2.append(KEYPAD_DIAM[position_2[0]][position_2[1]]);
    }

    return .{ code_1, code_2 };
}

test "y16d02" {
    const alloc = std.testing.allocator;
    const expectEqualStrings = std.testing.expectEqualStrings;
    const input =
        \\ULL
        \\RRDDD
        \\LURDL
        \\UUUUD
    ;

    const res_1, const res_2 = try solve(alloc, input);
    defer res_1.deinit();
    defer res_2.deinit();

    try expectEqualStrings("1985", res_1.items);
    try expectEqualStrings("5DB3", res_2.items);
}
