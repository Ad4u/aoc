const std = @import("std");

fn searchDouble(entries: std.ArrayList(u64)) !u64 {
    for (0..entries.items.len) |i| {
        for (i + 1..entries.items.len) |j| {
            if (entries.items[i] + entries.items[j] == 2020) {
                return entries.items[i] * entries.items[j];
            }
        }
    }
    return error.LogicError;
}

fn searchTriple(entries: std.ArrayList(u64)) !u64 {
    for (0..entries.items.len) |i| {
        for (i + 1..entries.items.len) |j| {
            for (j + 1..entries.items.len) |k| {
                if (entries.items[i] + entries.items[j] + entries.items[k] == 2020) {
                    return entries.items[i] * entries.items[j] * entries.items[k];
                }
            }
        }
    }
    return error.LogicError;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var entries = std.ArrayList(u64).init(alloc);
    defer entries.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try entries.append(try std.fmt.parseInt(u64, line, 10));
    }

    const expense_double = try searchDouble(entries);
    const expense_triple = try searchTriple(entries);

    return .{ expense_double, expense_triple };
}

test "y20d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\1721
        \\979
        \\366
        \\299
        \\675
        \\1456
    ;

    try expectEqual(.{ 514579, 241861950 }, (try solve(alloc, input)));
}
