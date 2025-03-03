const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn calcDistance(pos: @Vector(2, i64)) u64 {
    return @abs(pos[0]) + @abs(pos[1]);
}

fn parseInstruction(instruction: []const u8) !struct { direction: @Vector(2, i64), distance: u64 } {
    var direction: @Vector(2, i64) = undefined;
    switch (instruction[0]) {
        'U' => direction = .{ 0, 1 },
        'D' => direction = .{ 0, -1 },
        'R' => direction = .{ 1, 0 },
        'L' => direction = .{ -1, 0 },
        else => return error.BadInput,
    }

    const distance = try std.fmt.parseInt(u64, instruction[1..], 10);

    return .{ .direction = direction, .distance = distance };
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var position: @Vector(2, i64) = .{ 0, 0 };

    var wire_1 = std.AutoHashMap(@Vector(2, i64), u64).init(alloc);
    var intersections = std.AutoHashMap(@Vector(2, i64), u64).init(alloc);
    defer wire_1.deinit();
    defer intersections.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var inst_wire_1 = std.mem.tokenizeScalar(u8, lines.next().?, ',');
    var step_1: u64 = 0;
    while (inst_wire_1.next()) |inst| {
        const parsed = try parseInstruction(inst);
        for (0..parsed.distance) |_| {
            step_1 += 1;
            position += parsed.direction;
            try wire_1.put(position, step_1);
        }
    }

    position = .{ 0, 0 };

    var inst_wire_2 = std.mem.tokenizeScalar(u8, lines.next().?, ',');
    var step_2: u64 = 0;
    while (inst_wire_2.next()) |inst| {
        const parsed = try parseInstruction(inst);
        for (0..parsed.distance) |_| {
            step_2 += 1;
            position += parsed.direction;

            const entry = try wire_1.getOrPut(position);
            if (entry.found_existing) {
                try intersections.put(position, entry.value_ptr.* + step_2);
            }
        }
    }

    var closest: u64 = std.math.maxInt(u64);
    var min_step: u64 = std.math.maxInt(u64);
    var intersect_iter = intersections.iterator();
    while (intersect_iter.next()) |entry| {
        const distance = calcDistance(entry.key_ptr.*);
        const step = entry.value_ptr.*;

        if (distance < closest) closest = distance;
        if (step < min_step) min_step = step;
    }

    return Result.from(u64, .{ closest, min_step });
}

test "y19d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input_1 =
        \\R75,D30,R83,U83,L12,D49,R71,U7,L72
        \\U62,R66,U55,R34,D71,R55,D58,R83
    ;

    const input_2 =
        \\R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
        \\U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
    ;

    try expectEqual(.{ 159, 610 }, (try solve(alloc, input_1)).ints);
    try expectEqual(.{ 135, 410 }, (try solve(alloc, input_2)).ints);
}
