const std = @import("std");
const Result = @import("../solvers.zig").Result;

const Claim = struct {
    id: u64,
    left: u32,
    top: u32,
    width: u32,
    height: u32,

    fn fromLine(line: []const u8) !Claim {
        var iter = std.mem.tokenizeScalar(u8, line, ' ');

        const id = try std.fmt.parseInt(u64, iter.next().?[1..], 10);
        _ = iter.next();
        const corner_str = std.mem.trimRight(u8, iter.next().?, ":");
        var corner_iter = std.mem.tokenizeScalar(u8, corner_str, ',');
        const left = try std.fmt.parseInt(u32, corner_iter.next().?, 10);
        const top = try std.fmt.parseInt(u32, corner_iter.next().?, 10);

        const size_str = iter.next().?;
        var size_iter = std.mem.tokenizeScalar(u8, size_str, 'x');
        const width = try std.fmt.parseInt(u32, size_iter.next().?, 10);
        const height = try std.fmt.parseInt(u32, size_iter.next().?, 10);

        return Claim{ .id = id, .left = left, .top = top, .width = width, .height = height };
    }

    fn requestOnFabric(self: Claim, fabric: *[1000][1000]u32) void {
        for (self.left..self.left + self.width) |i| {
            for (self.top..self.top + self.height) |j| {
                fabric[j][i] += 1;
            }
        }
    }

    fn isUnique(self: Claim, fabric: [1000][1000]u32) bool {
        for (self.left..self.left + self.width) |i| {
            for (self.top..self.top + self.height) |j| {
                if (fabric[j][i] != 1) return false;
            }
        }
        return true;
    }
};

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var claims = std.ArrayList(Claim).init(alloc);
    defer claims.deinit();

    var fabric: [1000][1000]u32 = undefined; // Y, X
    for (&fabric) |*col| {
        @memset(col, 0);
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const claim = try Claim.fromLine(line);
        claim.requestOnFabric(&fabric);
        try claims.append(claim);
    }

    var overlap: u64 = 0;
    for (0..1000) |i| {
        for (0..1000) |j| {
            if (fabric[i][j] >= 2) overlap += 1;
        }
    }

    var unique: u64 = 0;
    for (claims.items) |claim| {
        if (claim.isUnique(fabric)) {
            unique = claim.id;
            break;
        }
    }
    return Result.from(u64, .{ overlap, unique });
}

test "y18d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\#1 @ 1,3: 4x4
        \\#2 @ 3,1: 4x4
        \\#3 @ 5,5: 2x2
    ;

    try expectEqual(.{ 4, 3 }, (try solve(alloc, input)).ints);
}
