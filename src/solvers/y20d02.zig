const std = @import("std");

const Password = struct {
    min: u64,
    max: u64,
    char: u8,
    data: []const u8,

    fn is_valid_1(self: Password) bool {
        var count: u64 = 0;
        for (self.data) |c| {
            if (self.char == c) count += 1;
        }

        return (count <= self.max and count >= self.min);
    }

    fn is_valid_2(self: Password) bool {
        var count: u64 = 0;
        if (self.data[self.min - 1] == self.char) count += 1;
        if (self.data[self.max - 1] == self.char) count += 1;

        return count == 1;
    }

    fn from_line(line: []const u8) !Password {
        var iter = std.mem.tokenizeScalar(u8, line, ' ');
        const range_str = iter.next().?;
        const char = iter.next().?[0];
        const data = iter.next().?;

        var iter_range = std.mem.tokenizeScalar(u8, range_str, '-');
        const min = try std.fmt.parseInt(u64, iter_range.next().?, 10);
        const max = try std.fmt.parseInt(u64, iter_range.next().?, 10);

        return Password{ .min = min, .max = max, .char = char, .data = data };
    }
};

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]u64 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var num_valid_1: u64 = 0;
    var num_valid_2: u64 = 0;
    while (lines.next()) |line| {
        const password = try Password.from_line(line);
        if (password.is_valid_1()) num_valid_1 += 1;
        if (password.is_valid_2()) num_valid_2 += 1;
    }

    return .{ num_valid_1, num_valid_2 };
}

test "y20d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(.{ 1, 1 }, (try solve(alloc, "1-3 a: abcde")));
    try expectEqual(.{ 0, 0 }, (try solve(alloc, "1-3 b: cdefg")));
    try expectEqual(.{ 1, 0 }, (try solve(alloc, "2-9 c: ccccccccc")));
}
