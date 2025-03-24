const std = @import("std");
const Result = @import("../solvers.zig").Result;

pub fn solve(_: std.mem.Allocator, _: []const u8) !Result {
    return error.NotImplemented;
}

test "y18d04" {
    // const alloc = std.testing.allocator;
    // const expectEqual = std.testing.expectEqual;

    // const input =
    //     \\#1 @ 1,3: 4x4
    //     \\#2 @ 3,1: 4x4
    //     \\#3 @ 5,5: 2x2
    // ;

    // try expectEqual(4, (try solve(alloc, input)).ints[0]);
}
