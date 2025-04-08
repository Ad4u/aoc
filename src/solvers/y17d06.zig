const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn reallocate(banks: *[16]u8, m: u8) void {
    const max = std.mem.max(u8, banks);
    const imax = std.mem.indexOfScalar(u8, banks, max).?;

    banks[imax] = 0;
    for (imax + 1..imax + max + 1) |i| {
        banks[i % m] += 1;
    }
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var banks: [16]u8 = @splat(0);
    var banks_loop: [16]u8 = undefined;
    var saved_banks = std.AutoHashMap([16]u8, void).init(alloc);
    defer saved_banks.deinit();

    var iter = std.mem.tokenizeScalar(u8, input, '\t');
    var i: usize = 0;
    while (iter.next()) |nstr| : (i += 1) {
        banks[i] = try std.fmt.parseInt(u8, nstr, 10);
    }
    try saved_banks.putNoClobber(banks, {});

    var n: usize = 1;
    while (true) : (n += 1) {
        reallocate(&banks, 16);
        const res = try saved_banks.getOrPut(banks);
        if (res.found_existing) {
            @memcpy(&banks_loop, &banks);
            break;
        }
    }

    var m: usize = 1;
    while (true) : (m += 1) {
        reallocate(&banks, 16);
        if (std.mem.eql(u8, &banks, &banks_loop)) break;
    }

    return Result.from(usize, .{ n, m });
}

test "y17d06" {
    const expectEqualSlices = std.testing.expectEqualSlices;

    var banks: [16]u8 = @splat(0);
    const input: [4]u8 = .{ 0, 2, 7, 0 };
    @memcpy(banks[0..4], &input);

    reallocate(&banks, 4);
    try expectEqualSlices(u8, &[4]u8{ 2, 4, 1, 2 }, banks[0..4]);

    reallocate(&banks, 4);
    try expectEqualSlices(u8, &[4]u8{ 3, 1, 2, 3 }, banks[0..4]);

    reallocate(&banks, 4);
    try expectEqualSlices(u8, &[4]u8{ 0, 2, 3, 4 }, banks[0..4]);

    reallocate(&banks, 4);
    try expectEqualSlices(u8, &[4]u8{ 1, 3, 4, 1 }, banks[0..4]);
}
