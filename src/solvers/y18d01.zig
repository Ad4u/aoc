const std = @import("std");

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]i64 {
    var twice_frequency: i64 = 0;
    var final_frequency: i64 = 0;

    var frequency_list = std.ArrayList(i64).init(alloc);
    defer frequency_list.deinit();

    var visited_frequencies = std.AutoHashMap(i64, void).init(alloc);
    defer visited_frequencies.deinit();
    try visited_frequencies.put(twice_frequency, {});

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try frequency_list.append(try std.fmt.parseInt(i64, line, 10));
    }

    var i: usize = 0;
    while (true) : (i += 1) {
        const frequency_change = frequency_list.items[i % frequency_list.items.len];

        if (i < frequency_list.items.len) {
            final_frequency += frequency_change;
        }

        twice_frequency += frequency_change;
        const entry = try visited_frequencies.getOrPut(twice_frequency);
        if (entry.found_existing) break;
    }

    return .{ final_frequency, twice_frequency };
}

test "y18d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(.{ 0, 0 }, (try solve(alloc, "+1\n-1")));
    try expectEqual(.{ 4, 10 }, (try solve(alloc, "+3\n+3\n+4\n-2\n-4")));
    try expectEqual(.{ 4, 5 }, (try solve(alloc, "-6\n+3\n+8\n+5\n-6")));
    try expectEqual(.{ 1, 14 }, (try solve(alloc, "+7\n+7\n-2\n-7\n-4")));
}
