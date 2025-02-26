const std = @import("std");

fn arePossible(dims: [3][3]u64) [2]u64 {
    var hori: u64 = 0;
    var vert: u64 = 0;

    for (0..3) |i| {
        if (dims[i][0] + dims[i][1] > dims[i][2] and
            dims[i][1] + dims[i][2] > dims[i][0] and
            dims[i][2] + dims[i][0] > dims[i][1])
        {
            hori += 1;
        }
    }

    for (0..3) |i| {
        if (dims[0][i] + dims[1][i] > dims[2][i] and
            dims[1][i] + dims[2][i] > dims[0][i] and
            dims[2][i] + dims[0][i] > dims[1][i])
        {
            vert += 1;
        }
    }

    return .{ hori, vert };
}

pub fn solve(_: std.mem.Allocator, input: []const u8) ![2]u64 {
    var possible_hori: u64 = 0;
    var possible_vert: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var block: [3][3]u64 = .{ .{ 0, 0, 0 }, .{ 0, 0, 0 }, .{ 0, 0, 0 } }; // row, col
    var line_mod: usize = 0;
    while (lines.next()) |line| {
        var iter = std.mem.tokenizeScalar(u8, line, ' ');
        block[line_mod][0] = try std.fmt.parseInt(u64, iter.next().?, 10);
        block[line_mod][1] = try std.fmt.parseInt(u64, iter.next().?, 10);
        block[line_mod][2] = try std.fmt.parseInt(u64, iter.next().?, 10);
        line_mod += 1;

        if (line_mod == 3) {
            line_mod = 0;

            const possible = arePossible(block);
            possible_hori += possible[0];
            possible_vert += possible[1];
        }
    }

    return .{ possible_hori, possible_vert };
}

test "y16d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;
    const input =
        \\101 301 501
        \\102 302 502
        \\103 303 503
        \\201 401 601
        \\202 402 602
        \\203 403 603
    ;

    try expectEqual(.{ 3, 6 }, try solve(alloc, input));
}
