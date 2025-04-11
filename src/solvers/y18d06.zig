const std = @import("std");
const Result = @import("../solvers.zig").Result;
const lower = std.ascii.toLower;

const Coords = @Vector(2, usize);

fn dist(p1: Coords, p2: Coords) usize {
    const xdist = @abs(@as(i32, @intCast(p1[0])) - @as(i32, @intCast(p2[0])));
    const ydist = @abs(@as(i32, @intCast(p1[1])) - @as(i32, @intCast(p2[1])));
    return xdist + ydist;
}

fn calcBoundingBox(points: std.AutoHashMap(usize, Coords)) [4]usize { // xmin, xmax, ymin, ymax
    var xmin: usize = std.math.maxInt(usize);
    var xmax: usize = 0;
    var ymin: usize = std.math.maxInt(usize);
    var ymax: usize = 0;

    var iter = points.iterator();
    while (iter.next()) |e| {
        const x, const y = e.value_ptr.*;

        if (xmin > x) xmin = x;
        if (xmax < x) xmax = x;
        if (ymin > y) ymin = y;
        if (ymax < y) ymax = y;
    }

    return .{ xmin, xmax, ymin, ymax };
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var points = std.AutoHashMap(usize, Coords).init(alloc);
    defer points.deinit();

    var counts = std.AutoHashMap(usize, usize).init(alloc); // index, count
    defer counts.deinit();

    var infinite = std.AutoHashMap(usize, void).init(alloc);
    defer infinite.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        var iter = std.mem.tokenizeSequence(u8, line, ", ");
        const xstr = iter.next() orelse return error.BadInput;
        const ystr = iter.next() orelse return error.BadInput;
        const x = try std.fmt.parseInt(usize, xstr, 10);
        const y = try std.fmt.parseInt(usize, ystr, 10);

        const p = Coords{ x, y };
        try points.putNoClobber(i, p);
    }

    const xmin, const xmax, const ymin, const ymax = calcBoundingBox(points);

    for (ymin..ymax + 1) |y| {
        for (xmin..xmax + 1) |x| {
            var min_dist: usize = std.math.maxInt(usize);
            var idx: usize = undefined;

            var iter = points.iterator();
            while (iter.next()) |e| {
                const d = dist(Coords{ x, y }, e.value_ptr.*);
                if (min_dist > d) {
                    min_dist = d;
                    idx = e.key_ptr.*;
                }
            }
            const entry = try counts.getOrPutValue(idx, 0);
            entry.value_ptr.* += 1;

            if (x == xmin or x == xmax or y == ymin or y == ymax) {
                try infinite.put(idx, {});
            }
        }
    }

    var counts_iter = counts.iterator();
    while (counts_iter.next()) |e| {
        std.debug.print("idx: {}\tcount: {}\n", .{ e.key_ptr.*, e.value_ptr.* });
    }
    var inf_iter = infinite.iterator();
    while (inf_iter.next()) |e| {
        std.debug.print("idx inf: {}\n", .{e.key_ptr.*});
    }

    return Result.from(usize, .{ 0, 0 });
}

test "y18d06" {
    const alloc = std.testing.allocator;
    // const expectEqual = std.testing.expectEqual;

    const input =
        \\1, 1
        \\1, 6
        \\8, 3
        \\3, 4
        \\5, 5
        \\8, 9
    ;

    _ = try solve(alloc, input);
    // try expectEqual(.{ 10, 4 }, (try solve(alloc, input)).ints);
}
