const std = @import("std");

const Direction = enum(u8) {
    North,
    East,
    South,
    West,

    fn turn(self: *Direction, char: u8) !void {
        switch (char) {
            'R' => self.* = @enumFromInt((@intFromEnum(self.*) + 1) % 4),
            'L' => self.* = @enumFromInt((@intFromEnum(self.*) -% 1) % 4),
            else => return error.BadInput,
        }
    }
};

const Position = struct {
    x: i64 = 0,
    y: i64 = 0,

    fn moveOneBlock(self: *Position, direction: Direction) void {
        switch (direction) {
            .North => self.y += 1,
            .East => self.x += 1,
            .South => self.y -= 1,
            .West => self.x -= 1,
        }
    }

    inline fn blockDistance(self: Position) u64 {
        return @abs(self.x) + @abs(self.y);
    }
};

pub fn solve(alloc: std.mem.Allocator, input: []const u8) ![2]u64 {
    var visited = std.AutoHashMap(Position, void).init(alloc);
    defer visited.deinit();

    var direction = Direction.North;
    var position = Position{};
    try visited.put(position, {});
    var visited_twice: ?Position = null;

    var instructions = std.mem.tokenizeSequence(u8, input, ", ");
    while (instructions.next()) |ins| {
        const char = ins[0];
        const distance = try std.fmt.parseInt(usize, ins[1..], 10);

        try direction.turn(char);
        for (0..distance) |_| {
            position.moveOneBlock(direction);

            const entry = try visited.getOrPut(position);
            if (entry.found_existing and visited_twice == null) {
                visited_twice = position;
            }
        }
    }
    return .{ position.blockDistance(), (visited_twice orelse Position{}).blockDistance() };
}

test "y16d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(5, (try solve(alloc, "R2, L3"))[0]);
    try expectEqual(2, (try solve(alloc, "R2, R2, R2"))[0]);
    try expectEqual(12, (try solve(alloc, "R5, L5, R5, R3"))[0]);

    try expectEqual(4, (try solve(alloc, "R8, R4, R4, R8"))[1]);
}
