const std = @import("std");
const Result = @import("../solvers.zig").Result;

const MAX_LINES = 1024;
const MAX_BITS = 16;

fn filterBits(bits: [MAX_LINES][MAX_BITS]u1, nlines: usize, nbits: usize, least_mode: bool) !usize {
    var kept: [MAX_LINES]bool = [_]bool{false} ** MAX_LINES;
    @memset(kept[0..nlines], true);

    var nkept = nlines;
    loop: for (0..nbits) |i| {
        var num_ones: u32 = 0;
        for (0..nlines) |j| {
            if (bits[j][i] == 1 and kept[j]) num_ones += 1;
        }

        const selected = (@as(f32, @floatFromInt(num_ones)) >= @as(f32, @floatFromInt(nkept)) / 2.0) != least_mode;
        const selected_bit = @intFromBool(selected);

        for (0..nlines) |j| {
            if (bits[j][i] != selected_bit and kept[j]) {
                kept[j] = false;
                nkept -= 1;
            }
            if (nkept == 1) {
                break :loop;
            }
        }
    }

    for (kept, 0..) |is_kept, i| {
        if (is_kept) return i;
    }

    return error.LogicError;
}

fn convertBitsToDecimal(bits: [MAX_BITS]u1, nbits: usize) u64 {
    var decimal: u64 = 0;
    for (0..nbits) |i| {
        decimal *= 2;
        decimal |= bits[i];
    }

    return decimal;
}

fn calcGammaEpsilonBits(bits: [MAX_LINES][MAX_BITS]u1, nlines: usize, nbits: usize) [2][MAX_BITS]u1 {
    var gamma_bits: [MAX_BITS]u1 = undefined;
    var epsilon_bits: [MAX_BITS]u1 = undefined;

    for (0..nbits) |i| {
        var num_ones: u32 = 0;
        for (0..nlines) |j| {
            if (bits[j][i] == 1) num_ones += 1;
        }
        if (num_ones >= nlines / 2) {
            gamma_bits[i] = 1;
            epsilon_bits[i] = 0;
        } else {
            gamma_bits[i] = 0;
            epsilon_bits[i] = 1;
        }
    }

    return .{ gamma_bits, epsilon_bits };
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var bits: [MAX_LINES][MAX_BITS]u1 = undefined; // Number, Bit

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var nlines: usize = 0;
    var nbits: usize = 0;
    while (lines.next()) |line| : (nlines += 1) {
        nbits = 0;
        for (line) |c| {
            switch (c) {
                '0' => bits[nlines][nbits] = 0,
                '1' => bits[nlines][nbits] = 1,
                else => return error.BadInput,
            }
            nbits += 1;
        }
    }

    const g_bits, const e_bits = calcGammaEpsilonBits(bits, nlines, nbits);
    const gamma = convertBitsToDecimal(g_bits, nbits);
    const epsilon = convertBitsToDecimal(e_bits, nbits);

    const oxygen_idx = try filterBits(bits, nlines, nbits, false);
    const carbon_idx = try filterBits(bits, nlines, nbits, true);

    const oxygen = convertBitsToDecimal(bits[oxygen_idx], nbits);
    const carbon = convertBitsToDecimal(bits[carbon_idx], nbits);

    return Result.from(u64, .{ gamma * epsilon, oxygen * carbon });
}

test "y21d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\00100
        \\11110
        \\10110
        \\10111
        \\10101
        \\01111
        \\00111
        \\11100
        \\10000
        \\11001
        \\00010
        \\01010
    ;

    try expectEqual(.{ 198, 230 }, (try solve(alloc, input)).ints);
}
