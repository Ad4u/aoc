const std = @import("std");
const Result = @import("../solvers.zig").Result;

const words = [_]struct { []const u8, u64 }{ .{ "one", 1 }, .{ "two", 2 }, .{ "three", 3 }, .{ "four", 4 }, .{ "five", 5 }, .{ "six", 6 }, .{ "seven", 7 }, .{ "eight", 8 }, .{ "nine", 9 } };

fn getCalibrationDigits(line: []const u8) !u64 {
    var first_digit: ?u64 = null;
    var last_digit: ?u64 = null;

    for (0..line.len) |i| {
        const digit = std.fmt.parseInt(u64, &[_]u8{line[i]}, 10) catch continue;
        if (first_digit == null) {
            first_digit = digit;
        }
        last_digit = digit;
    }

    return (first_digit orelse 0) * 10 + (last_digit orelse 0);
}

fn getCalibrationLetters(line: []const u8) !u64 {
    var first_digit: ?u64 = null;
    var last_digit: ?u64 = null;

    for (0..line.len) |i| {
        for (words) |word| {
            if (std.mem.startsWith(u8, line[i..], word[0])) {
                const letter_digit = word[1];
                if (first_digit == null) {
                    first_digit = letter_digit;
                }
                last_digit = letter_digit;
            }
        }

        const digit = std.fmt.parseInt(u64, &[_]u8{line[i]}, 10) catch continue;
        if (first_digit == null) {
            first_digit = digit;
        }

        last_digit = digit;
    }

    return (first_digit orelse return error.BadInput) * 10 + (last_digit orelse return error.BadInput);
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var total_calibration_digits: u64 = 0;
    var total_calibration_letters: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        total_calibration_digits += try getCalibrationDigits(line);
        total_calibration_letters += try getCalibrationLetters(line);
    }

    return Result.from(u64, .{ total_calibration_digits, total_calibration_letters });
}

test "y23d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input_digit =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;

    const input_letters =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;

    try expectEqual(142, (try solve(alloc, input_digit)).ints[0]);
    try expectEqual(281, (try solve(alloc, input_letters)).ints[1]);
}
