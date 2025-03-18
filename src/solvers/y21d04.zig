const std = @import("std");
const Result = @import("../solvers.zig").Result;

const Board = struct {
    numbers: [25]u8,
    drawed: [25]bool = @splat(false),
    already_completed: bool = false,

    fn fromBlock(block: []const u8) !Board {
        var numbers: [25]u8 = undefined;

        var lines = std.mem.tokenizeScalar(u8, block, '\n');
        var i: usize = 0;
        while (lines.next()) |line| {
            var iter = std.mem.tokenizeScalar(u8, line, ' ');
            while (iter.next()) |nstr| : (i += 1) {
                numbers[i] = try std.fmt.parseInt(u8, nstr, 10);
            }
        }

        return Board{ .numbers = numbers };
    }

    fn processDraw(self: *Board, num: u8) void {
        for (self.numbers, 0..) |sn, i| {
            if (sn == num) self.drawed[i] = true;
        }
    }

    fn checkRow(self: Board, n: usize) bool {
        const start_idx = n * 5;
        var completed = true;
        for (0..5) |i| {
            completed = completed and self.drawed[start_idx + i];
        }

        return completed;
    }

    fn checkCol(self: Board, n: usize) bool {
        var completed = true;
        for (0..5) |i| {
            completed = completed and self.drawed[n + i * 5];
        }

        return completed;
    }

    fn isComplete(self: Board) bool {
        for (0..5) |i| {
            if (self.checkRow(i) or self.checkCol(i)) return true;
        }

        return false;
    }

    fn checkSum(self: *Board) ?u64 {
        if (!self.isComplete()) return null;

        self.already_completed = true;

        var sum: u64 = 0;
        for (0..25) |i| {
            if (!self.drawed[i]) sum += self.numbers[i];
        }

        return sum;
    }
};

fn parseDraws(alloc: std.mem.Allocator, line: []const u8) !std.ArrayList(u8) {
    var draws = std.ArrayList(u8).init(alloc);
    var iter = std.mem.tokenizeScalar(u8, line, ',');
    while (iter.next()) |nstr| {
        try draws.append(try std.fmt.parseInt(u8, nstr, 10));
    }

    return draws;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var blocks = std.mem.tokenizeSequence(u8, input, "\n\n");

    const draws_str = blocks.next() orelse return error.BadInput;
    const draws = try parseDraws(alloc, draws_str);
    defer draws.deinit();

    var boards = std.ArrayList(Board).init(alloc);
    defer boards.deinit();

    while (blocks.next()) |block| {
        try boards.append(try Board.fromBlock(block));
    }

    var scores = std.ArrayList(u64).init(alloc);
    defer scores.deinit();

    for (draws.items) |draw| {
        for (boards.items) |*board| {
            if (board.already_completed) continue;

            board.processDraw(draw);
            const board_sum = board.checkSum();
            if (board_sum) |sum| {
                try scores.append(sum * draw);
            }
        }
    }

    return Result.from(u64, .{ scores.items[0], scores.items[scores.items.len - 1] });
}

test "y21d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
        \\
        \\22 13 17 11  0
        \\ 8  2 23  4 24
        \\21  9 14 16  7
        \\ 6 10  3 18  5
        \\ 1 12 20 15 19
        \\
        \\ 3 15  0  2 22
        \\ 9 18 13 17  5
        \\19  8  7 25 23
        \\20 11 10 24  4
        \\14 21 16 12  6
        \\
        \\14 21 17 24  4
        \\10 16 15  9 19
        \\18  8 23 26 20
        \\22 11 13  6  5
        \\ 2  0 12  3  7
    ;

    try expectEqual(.{ 4512, 1924 }, (try solve(alloc, input)).ints);
}
