const std = @import("std");

fn processOpCode(intcode: *std.ArrayList(usize), cursor: *usize) !void {
    const instruction = intcode.items[cursor.*];
    const input_1_idx = intcode.items[cursor.* + 1];
    const input_2_idx = intcode.items[cursor.* + 2];
    const output_idx = intcode.items[cursor.* + 3];

    switch (instruction) {
        1 => {
            intcode.items[output_idx] = intcode.items[input_1_idx] + intcode.items[input_2_idx];
        },
        2 => {
            intcode.items[output_idx] = intcode.items[input_1_idx] * intcode.items[input_2_idx];
        },
        else => return error.BadInput,
    }
    cursor.* += 4;
}

fn runIntCode(intcode: *std.ArrayList(usize), noun: usize, verb: usize) !usize {
    intcode.items[1] = noun;
    intcode.items[2] = verb;

    var cursor: usize = 0;
    while (intcode.items[cursor] != 99) {
        try processOpCode(intcode, &cursor);
    }

    return intcode.items[0];
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]usize {
    var intcode = std.ArrayList(usize).init(alloc);
    defer intcode.deinit();

    var iter = std.mem.tokenizeScalar(u8, input, ',');
    while (iter.next()) |str| {
        try intcode.append(try std.fmt.parseInt(usize, str, 10));
    }

    var intcode_part_1 = try intcode.clone();
    defer intcode_part_1.deinit();
    const part_1 = try runIntCode(&intcode_part_1, 12, 2);

    var part_2: usize = 0;
    const output_match: usize = 19690720;
    for (0..100) |noun| {
        for (0..100) |verb| {
            var temp_intcode = try intcode.clone();
            defer temp_intcode.deinit();
            if (output_match == try runIntCode(&temp_intcode, noun, verb)) {
                part_2 = 100 * noun + verb;
            }
        }
    }

    return .{ part_1, part_2 };
}

test "y19d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input = "1,9,10,3,2,3,11,0,99,30,40,50";
    var intcode = std.ArrayList(usize).init(alloc);
    defer intcode.deinit();

    var iter = std.mem.tokenizeScalar(u8, input, ',');
    while (iter.next()) |str| {
        try intcode.append(try std.fmt.parseInt(usize, str, 10));
    }

    try expectEqual(3500, try runIntCode(&intcode, 9, 10));
}
