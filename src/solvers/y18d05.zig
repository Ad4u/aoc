const std = @import("std");
const Result = @import("../solvers.zig").Result;
const lower = std.ascii.toLower;

fn swapCase(c: u8) u8 {
    return c ^ 0x20;
}

fn improve(alloc: std.mem.Allocator, mol: []const u8) !usize {
    var min: u64 = std.math.maxInt(usize);
    for ('a'..'z') |c| {
        const new_mol = try alloc.dupe(u8, mol);
        defer alloc.free(new_mol);

        std.mem.replaceScalar(u8, new_mol, @intCast(c), '.');
        std.mem.replaceScalar(u8, new_mol, swapCase(@intCast(c)), '.');

        const reduced = reduce(new_mol);
        if (reduced < min) min = reduced;
    }

    return min;
}

fn reduce(mol: []const u8) usize {
    var new_mol: [65536]u8 = @splat('.');

    var i: usize = 0;
    for (mol) |c| {
        if (c == '.') continue;

        if (i == 0) {
            new_mol[0] = c;
            i += 1;
            continue;
        }

        if (c == swapCase(new_mol[i - 1])) {
            new_mol[i - 1] = ' ';
            i -= 1;
        } else {
            new_mol[i] = c;
            i += 1;
        }
    }

    return i;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    const reacted_len = reduce(input);
    const min_len = try improve(alloc, input);

    return Result.from(usize, .{ reacted_len, min_len });
}

test "y18d05" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input = "dabAcCaCBAcCcaDA";

    try expectEqual(.{ 10, 4 }, (try solve(alloc, input)).ints);
}
