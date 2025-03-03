const std = @import("std");
const Result = @import("../solvers.zig").Result;

const RED_MAX: u64 = 12;
const GREEN_MAX: u64 = 13;
const BLUE_MAX: u64 = 14;

const BagColor = enum {
    red,
    green,
    blue,
};

fn parseLine(line: []const u8) ![5]u64 { // Id, Red, Green, Blue, Possible (Part 1)
    var red: u64 = 0;
    var green: u64 = 0;
    var blue: u64 = 0;
    var possible: u64 = 1;

    var iter = std.mem.tokenizeAny(u8, line, " :,;");

    _ = iter.next();
    const id = try std.fmt.parseInt(u64, iter.next().?, 10);

    while (iter.peek()) |_| {
        const value = try std.fmt.parseInt(u64, iter.next().?, 10);
        const color = std.meta.stringToEnum(BagColor, iter.next().?) orelse return error.BadInput;
        switch (color) {
            .red => {
                if (value > red) red = value;
                if (value > RED_MAX) possible = 0;
            },
            .green => {
                if (value > green) green = value;
                if (value > GREEN_MAX) possible = 0;
            },
            .blue => {
                if (value > blue) blue = value;
                if (value > BLUE_MAX) possible = 0;
            },
        }
    }

    return .{ id, red, green, blue, possible };
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var sum: u64 = 0;
    var power: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const game = try parseLine(line);
        if (game[4] != 0) sum += game[0];
        power += game[1] * game[2] * game[3];
    }

    return Result.from(u64, .{ sum, power });
}

test "y23d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;

    try expectEqual(.{ 8, 2286 }, (try solve(alloc, input)).ints);
}
