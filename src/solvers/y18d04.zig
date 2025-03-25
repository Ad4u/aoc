const std = @import("std");
const Result = @import("../solvers.zig").Result;

const Guard = struct {
    total_asleep: u64 = 0,
    minutes_asleep: [60]u64 = @splat(0),

    fn mostAsleep(self: Guard) [2]u64 { // minute, freq
        var max_minute: u64 = 0;
        var max_freq: u64 = 0;
        for (self.minutes_asleep, 0..) |m, i| {
            if (m > max_freq) {
                max_minute = i;
                max_freq = self.minutes_asleep[i];
            }
        }

        return .{ max_minute, max_freq };
    }
};

fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var data = std.ArrayList([]const u8).init(alloc);
    defer data.deinit();

    var guards = std.AutoHashMap(u64, Guard).init(alloc);
    defer guards.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        try data.append(line);
    }

    std.mem.sort([]const u8, data.items, {}, lessThan);

    var current_guard_id: u64 = 0;
    var asleep_minute: usize = 0;
    var wakes_minutes: usize = 0;

    for (data.items) |line| {
        const idx_min = std.mem.indexOfScalar(u8, line, ':') orelse return error.BadInput;
        const minute = try std.fmt.parseInt(usize, line[idx_min + 1 .. idx_min + 3], 10);

        // Looking for the current guard id
        if (std.mem.indexOfScalar(u8, line, '#')) |g_start| {
            const g_end = std.mem.indexOfScalarPos(u8, line, g_start, ' ') orelse return error.BadInput;
            current_guard_id = try std.fmt.parseInt(u64, line[g_start + 1 .. g_end], 10);
            continue;
        }

        // Going asleep
        if (std.mem.indexOf(u8, line, "asleep")) |_| {
            asleep_minute = minute;
            continue;
        }

        // Waking up
        wakes_minutes = minute;
        const guard = try guards.getOrPutValue(current_guard_id, Guard{});
        for (asleep_minute..wakes_minutes) |m| {
            guard.value_ptr.total_asleep += 1;
            guard.value_ptr.minutes_asleep[m] += 1;
        }
    }

    // Part 1
    var guard_id_1: u64 = 0;
    var total_asleep_1: u64 = 0;
    var minute_1: u64 = 0;
    var iter_1 = guards.iterator();
    while (iter_1.next()) |entry| {
        if (entry.value_ptr.total_asleep > total_asleep_1) {
            total_asleep_1 = entry.value_ptr.total_asleep;
            minute_1 = entry.value_ptr.mostAsleep()[0];
            guard_id_1 = entry.key_ptr.*;
        }
    }
    const value_1 = guard_id_1 * minute_1;

    // Part 2
    var guard_id_2: u64 = 0;
    var max_asleep_2: u64 = 0;
    var minute_2: u64 = 0;
    var iter_2 = guards.iterator();
    while (iter_2.next()) |entry| {
        const m, const f = entry.value_ptr.mostAsleep();
        if (f > max_asleep_2) {
            max_asleep_2 = f;
            minute_2 = m;
            guard_id_2 = entry.key_ptr.*;
        }
    }
    const value_2 = guard_id_2 * minute_2;

    return Result.from(u64, .{ value_1, value_2 });
}

test "y18d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\[1518-11-01 00:00] Guard #10 begins shift
        \\[1518-11-01 00:05] falls asleep
        \\[1518-11-01 00:25] wakes up
        \\[1518-11-01 00:30] falls asleep
        \\[1518-11-01 00:55] wakes up
        \\[1518-11-01 23:58] Guard #99 begins shift
        \\[1518-11-02 00:40] falls asleep
        \\[1518-11-02 00:50] wakes up
        \\[1518-11-03 00:05] Guard #10 begins shift
        \\[1518-11-03 00:24] falls asleep
        \\[1518-11-03 00:29] wakes up
        \\[1518-11-04 00:02] Guard #99 begins shift
        \\[1518-11-04 00:36] falls asleep
        \\[1518-11-04 00:46] wakes up
        \\[1518-11-05 00:03] Guard #99 begins shift
        \\[1518-11-05 00:45] falls asleep
        \\[1518-11-05 00:55] wakes up
    ;

    try expectEqual(.{ 240, 4455 }, (try solve(alloc, input)).ints);
}
