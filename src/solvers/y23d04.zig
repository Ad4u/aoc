const std = @import("std");
const Result = @import("../solvers.zig").Result;

const Card = struct {
    draws: std.ArrayList(u8),
    winnings: std.ArrayList(u8),
    nmatch: u8,
    score: u64,
    copy: u64 = 1,

    fn fromLine(alloc: std.mem.Allocator, line: []const u8) !Card {
        const start = std.mem.indexOf(u8, line, ":");
        if (start == null) return error.BadInput;

        const sep = std.mem.indexOf(u8, line, "|");
        if (sep == null) return error.BadInput;

        const draws_str = line[start.? + 1 .. sep.?];
        const wins_str = line[sep.? + 1 ..];

        var draws = std.ArrayList(u8).init(alloc);
        var iter_draws = std.mem.tokenizeScalar(u8, draws_str, ' ');
        while (iter_draws.next()) |nstr| {
            try draws.append(try std.fmt.parseInt(u8, nstr, 10));
        }

        var winnings = std.ArrayList(u8).init(alloc);
        var iter_wins = std.mem.tokenizeScalar(u8, wins_str, ' ');
        while (iter_wins.next()) |nstr| {
            try winnings.append(try std.fmt.parseInt(u8, nstr, 10));
        }

        var nmatch: u8 = 0;
        var score: u64 = 0;

        for (draws.items) |nd| {
            for (winnings.items) |nw| {
                if (nd == nw) nmatch += 1;
            }
        }

        if (nmatch > 0) score = try std.math.powi(u64, 2, nmatch - 1);

        return Card{ .draws = draws, .winnings = winnings, .nmatch = nmatch, .score = score };
    }

    fn deinit(self: Card) void {
        self.draws.deinit();
        self.winnings.deinit();
    }
};

fn calcTotalCards(cards: std.ArrayList(Card)) u64 {
    for (cards.items, 0..) |card, i| {
        for (0..card.nmatch) |n| {
            cards.items[i + 1 + n].copy += card.copy;
        }
    }

    var total: u64 = 0;
    for (cards.items) |card| total += card.copy;
    return total;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var cards = std.ArrayList(Card).init(alloc);
    defer {
        for (cards.items) |card| card.deinit();
        cards.deinit();
    }

    var score: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const card = try Card.fromLine(alloc, line);
        score += card.score;
        try cards.append(card);
    }

    return Result.from(u64, .{ score, calcTotalCards(cards) });
}

test "y23d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;

    try expectEqual(.{ 13, 30 }, (try solve(alloc, input)).ints);
}
