const std = @import("std");

const LevelState = enum {
    increasing,
    decreasing,
};

fn isSafe(levels: std.ArrayList(i64)) bool {
    var state: ?LevelState = null;

    var iter = std.mem.window(i64, levels.items, 2, 1);

    while (iter.next()) |win| {
        const diff = win[0] - win[1];
        const diff_abs = @abs(diff);

        if (diff_abs == 0 or diff_abs > 3) return false;

        if (state != null) {
            if (diff < 0 and state == LevelState.decreasing) return false;
            if (diff > 0 and state == LevelState.increasing) return false;
        } else {
            if (diff < 0) state = LevelState.increasing;
            if (diff > 0) state = LevelState.decreasing;
        }
    }

    return true;
}

fn isSafeDampened(levels: std.ArrayList(i64)) !bool {
    var levels_clone = try levels.clone();
    defer levels_clone.deinit();

    for (0..levels.items.len) |i| {
        const removed = levels_clone.orderedRemove(i);
        if (isSafe(levels_clone)) {
            return true;
        }
        try levels_clone.insert(i, removed);
    }

    return false;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var safe: u64 = 0;
    var safe_dampened: u64 = 0;

    var levels = std.ArrayList(i64).init(alloc);
    defer levels.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        levels.clearRetainingCapacity();

        var iter = std.mem.tokenizeScalar(u8, line, ' ');
        while (iter.next()) |level| {
            try levels.append(try std.fmt.parseInt(i64, level, 10));
        }

        if (isSafe(levels)) safe += 1;
        if (try isSafeDampened(levels)) safe_dampened += 1;
    }

    return .{ safe, safe_dampened };
}

test "y24d02" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    try expectEqual(.{ 2, 4 }, (try solve(alloc, input)));
}
