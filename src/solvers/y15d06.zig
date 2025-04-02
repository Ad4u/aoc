const std = @import("std");
const mvzr = @import("mvzr");
const Result = @import("../solvers.zig").Result;

const ON = "turn on ";
const OFF = "turn off ";
const TOG = "toggle ";

const REG_NUMS = mvzr.compile("[0-9]+") orelse @compileError("Regex compile error at y15d06");

const Action = enum {
    on,
    off,
    toggle,
};

const Command = struct {
    action: Action,
    rect: [4]u32,

    fn fromLine(line: []const u8) !Command {
        var action: Action = undefined;
        var rect: [4]u32 = undefined;

        if (std.mem.startsWith(u8, line, ON)) {
            action = Action.on;
        }
        if (std.mem.startsWith(u8, line, OFF)) {
            action = Action.off;
        }
        if (std.mem.startsWith(u8, line, TOG)) {
            action = Action.toggle;
        }

        var iter = REG_NUMS.iterator(line);
        var i: usize = 0;
        while (iter.next()) |m| : (i += 1) {
            rect[i] = try std.fmt.parseInt(u32, m.slice, 10);
        }

        return Command{ .action = action, .rect = rect };
    }

    fn apply(self: Command, arr_b: *[1000 * 1000]bool, arr_i: *[1000 * 1000]u64) void {
        for (self.rect[0]..self.rect[2] + 1) |x| {
            for (self.rect[1]..self.rect[3] + 1) |y| {
                const i = 1000 * y + x;
                switch (self.action) {
                    .on => {
                        arr_b[i] = true;
                        arr_i[i] += 1;
                    },
                    .off => {
                        arr_b[i] = false;
                        arr_i[i] -|= 1;
                    },
                    .toggle => {
                        arr_b[i] = !arr_b[i];
                        arr_i[i] += 2;
                    },
                }
            }
        }
    }
};

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var array_b: [1000 * 1000]bool = @splat(false);
    var array_i: [1000 * 1000]u64 = @splat(0);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const cmd = try Command.fromLine(line);
        cmd.apply(&array_b, &array_i);
    }

    var lights: u64 = 0;
    var brightness: u64 = 0;
    for (0..1_000_000) |i| {
        if (array_b[i]) lights += 1;
        brightness += array_i[i];
    }

    return Result.from(u64, .{ lights, brightness });
}

test "y15d06" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(1_000_000, (try solve(alloc, "turn on 0,0 through 999,999")).ints[0]);
    try expectEqual(1_000, (try solve(alloc, "turn on 0,0 through 999,0")).ints[0]);
    try expectEqual(4, (try solve(alloc, "turn on 499,499 through 500,500")).ints[0]);

    try expectEqual(1, (try solve(alloc, "turn on 0,0 through 0,0")).ints[1]);
    try expectEqual(2_000_000, (try solve(alloc, "toggle 0,0 through 999,999")).ints[1]);
}
