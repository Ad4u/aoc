const std = @import("std");
const Result = @import("../solvers.zig").Result;

const GRID_SIZE: usize = 160 * 160;
const DIRECTIONS: [8]@Vector(2, isize) = .{ .{ 1, 0 }, .{ 1, 1 }, .{ 0, 1 }, .{ -1, 1 }, .{ -1, 0 }, .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 } };

const Grid = struct {
    data: [GRID_SIZE]u8,
    width: usize,
    height: usize,

    fn fromInput(input: []const u8) Grid {
        var data: [GRID_SIZE]u8 = [_]u8{'.'} ** GRID_SIZE;

        var height: usize = 0;
        var width: usize = 0;
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            if (width == 0) width = line.len;
            var i: usize = 0;
            for (line) |c| {
                data[i + width * height] = c;
                i += 1;
            }
            height += 1;
        }

        return Grid{ .data = data, .width = width, .height = height };
    }

    fn getGridValue(self: Grid, pos: @Vector(2, isize)) !u8 {
        if (pos[0] < 0 or pos[1] < 0 or pos[0] >= self.width or pos[1] >= self.height) return error.OutOfBounds;
        const i: usize = @intCast(pos[0]);
        const j: usize = @intCast(pos[1]);
        return self.data[i + j * self.width];
    }

    fn countAtPosition(self: Grid, pos: @Vector(2, isize)) u64 {
        var n: u64 = 0;
        var buffer: [4]u8 = undefined;

        for (DIRECTIONS) |dir| {
            @memset(&buffer, '.');
            var i: usize = 0;
            var shift: @Vector(2, isize) = .{ 0, 0 };
            while (i < 4) : (i += 1) {
                buffer[i] = self.getGridValue(pos + shift) catch continue;
                shift += dir;
            }
            if (std.mem.eql(u8, &buffer, "XMAS")) {
                n += 1;
            }
        }

        return n;
    }

    fn countWords(self: Grid) u64 {
        var total: u64 = 0;

        for (0..self.width) |i| {
            for (0..self.height) |j| {
                const pos: @Vector(2, isize) = .{ @intCast(i), @intCast(j) };
                total += self.countAtPosition(pos);
            }
        }

        return total;
    }

    fn countCrosses(self: Grid) u64 {
        var total: u64 = 0;

        var buffer: [3]u8 = undefined;

        for (0..self.width) |i| {
            for (0..self.height) |j| {
                @memset(&buffer, '.');
                const pos: @Vector(2, isize) = .{ @intCast(i), @intCast(j) };
                const middle_char = self.getGridValue(pos) catch continue;
                if (middle_char != 'A') continue;

                const ul = pos + @Vector(2, isize){ -1, 1 };
                const ur = pos + @Vector(2, isize){ 1, 1 };
                const dl = pos + @Vector(2, isize){ -1, -1 };
                const dr = pos + @Vector(2, isize){ 1, -1 };

                const ulc = self.getGridValue(ul) catch continue;
                const urc = self.getGridValue(ur) catch continue;
                const dlc = self.getGridValue(dl) catch continue;
                const drc = self.getGridValue(dr) catch continue;

                if (!((ulc == 'M' and drc == 'S') or (ulc == 'S' and drc == 'M'))) continue;
                if (!((urc == 'M' and dlc == 'S') or (urc == 'S' and dlc == 'M'))) continue;

                total += 1;
            }
        }

        return total;
    }
};

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    const grid = Grid.fromInput(input);

    const nwords = grid.countWords();
    const ncrosses = grid.countCrosses();
    return Result.from(u64, .{ nwords, ncrosses });
}

test "y24d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    try expectEqual(.{ 18, 9 }, (try solve(alloc, input)).ints);
}
