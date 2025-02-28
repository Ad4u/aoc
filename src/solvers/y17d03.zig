const std = @import("std");
const meta = std.meta;

const GRID_SIZE = 128;
const MID_IDX = GRID_SIZE / 2;
const GridType = [GRID_SIZE * GRID_SIZE]u32;

const Direction = enum(u2) {
    right,
    up,
    left,
    down,

    fn delta(self: Direction) @Vector(2, isize) {
        return switch (self) {
            .up => .{ 0, 1 },
            .down => .{ 0, -1 },
            .right => .{ 1, 0 },
            .left => .{ -1, 0 },
        };
    }
};

fn calcNewValue(grid: *GridType, position: @Vector(2, isize)) u64 {
    const x = @as(usize, @intCast(position[0] + MID_IDX));
    const y = @as(usize, @intCast(position[1] + MID_IDX));

    var new_value: u32 = 0;
    for (0..3) |i| {
        for (0..3) |j| {
            new_value += grid[(x + i - 1) * GRID_SIZE + (y + j - 1)];
        }
    }
    grid[x * GRID_SIZE + y] = new_value;
    return new_value;
}

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]u64 {
    // Part 1
    const target = try std.fmt.parseInt(u64, input, 10);
    var target_distance: ?u64 = null;
    var current: i64 = 1;

    // Part 2
    var larger_value: ?u64 = null;
    var grid: GridType = undefined;
    @memset(&grid, 0);
    grid[MID_IDX * GRID_SIZE + MID_IDX] = 1;

    // Variable for walking the square
    var position: @Vector(2, isize) = .{ 0, 0 };
    var direction = Direction.right;
    var distance: usize = 1;
    var mod: u1 = 0;

    loop: while (true) {
        const delta = direction.delta();

        // Advance forward the required distance
        for (0..distance) |_| {
            // Advance forward one position
            position += delta;

            // Check Part 1
            current += 1;
            if (current == target) {
                target_distance = @abs(position[0]) + @abs(position[1]);
            }

            // // Check Part 2
            if (larger_value == null) {
                const val = calcNewValue(&grid, position);
                if (val > target) {
                    larger_value = val;
                }
            }

            if (larger_value != null and target_distance != null) {
                break :loop;
            }
        }

        // Turn left
        direction = @enumFromInt(@intFromEnum(direction) +% 1);

        // Change distance to walk forward every 2 turns
        mod +%= 1;
        if (mod == 0) {
            distance +%= 1;
        }
    }

    return .{ target_distance.?, larger_value.? };
}

test "y17d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(3, (try solve(alloc, "12"))[0]);
    try expectEqual(2, (try solve(alloc, "23"))[0]);
    try expectEqual(31, (try solve(alloc, "1024"))[0]);

    try expectEqual(25, (try solve(alloc, "24"))[1]);
    try expectEqual(57, (try solve(alloc, "56"))[1]);
    try expectEqual(351, (try solve(alloc, "350"))[1]);
}
