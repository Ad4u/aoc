const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn run_2(arr: std.ArrayList(i32)) u64 {
    var i: i32 = 0;
    var n: u64 = 0;

    while (true) : (n += 1) {
        if (i >= arr.items.len) break;

        const offset = arr.items[@intCast(i)];
        const shift: i32 = if (offset >= 3) -1 else 1;
        arr.items[@intCast(i)] += shift;
        i += offset;
    }

    return n;
}

fn run_1(arr: std.ArrayList(i32)) u64 {
    var i: i32 = 0;
    var n: u64 = 0;

    while (true) : (n += 1) {
        if (i >= arr.items.len) break;

        const offset = arr.items[@intCast(i)];
        arr.items[@intCast(i)] += 1;
        i += offset;
    }

    return n;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var arr_1 = std.ArrayList(i32).init(alloc);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const n = try std.fmt.parseInt(i32, line, 10);
        try arr_1.append(n);
    }
    var arr_2 = try arr_1.clone();
    defer arr_1.deinit();
    defer arr_2.deinit();

    const steps_1 = run_1(arr_1);
    const steps_2 = run_2(arr_2);

    return Result.from(u64, .{ steps_1, steps_2 });
}

test "y17d05" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\0
        \\3
        \\0
        \\1
        \\-3
    ;

    try expectEqual(.{ 5, 10 }, (try solve(alloc, input)).ints);
}
