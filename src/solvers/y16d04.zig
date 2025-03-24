const std = @import("std");
const Result = @import("../solvers.zig").Result;

const LetterCount = struct {
    letter: u8,
    freq: u8,

    fn lessThan(_: void, a: LetterCount, b: LetterCount) bool {
        if (a.freq > b.freq) return true;
        if (a.freq == b.freq and a.letter < b.letter) return true;
        return false;
    }
};

const Room = struct {
    letters: [128]u8,
    length: usize,
    id: u64,
    checksum: [5]u8,
    calc_checksum: [5]u8,
    is_valid: bool,
    decrypted: [128]u8,

    fn fromLine(line: []const u8) !Room {
        var letters: [128]u8 = @splat(0);
        var decrypted: [128]u8 = @splat(0);
        var checksum: [5]u8 = @splat(0);
        var calc_checksum: [5]u8 = @splat(0);

        const length = std.mem.lastIndexOf(u8, line, "-") orelse return error.BadInput;
        for (0..length) |i| letters[i] = line[i];

        const id_sep = std.mem.indexOf(u8, line, "[") orelse return error.BadInput;
        const id = try std.fmt.parseInt(u32, line[length + 1 .. id_sep], 10);

        for (0..5) |i| checksum[i] = line[id_sep + 1 + i];

        var counts: [26]LetterCount = undefined;
        for (0..26) |i| {
            counts[i].letter = @intCast('a' + i);
            counts[i].freq = 0;
        }

        for (0..length) |i| {
            const c = line[i];
            if (c == '-') continue;
            counts[c - 'a'].freq += 1;
        }
        std.mem.sort(LetterCount, &counts, {}, LetterCount.lessThan);

        for (0..5) |i| {
            calc_checksum[i] = counts[i].letter;
        }

        for (0..length) |i| {
            if (letters[i] == '-') decrypted[i] = ' ' else {
                decrypted[i] = 'a' + @as(u8, @intCast((@as(u32, @intCast(letters[i] - 'a')) + id) % 26));
            }
        }

        return Room{ .letters = letters, .length = length, .id = id, .checksum = checksum, .calc_checksum = calc_checksum, .is_valid = std.mem.eql(u8, &checksum, &calc_checksum), .decrypted = decrypted };
    }
};

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var sectors_sum: u64 = 0;
    var storage_id: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const room = try Room.fromLine(line);
        if (room.is_valid) sectors_sum += room.id;
        if (std.mem.indexOf(u8, &room.decrypted, "north") != null) storage_id = room.id;
    }
    return Result.from(u64, .{ sectors_sum, storage_id });
}

test "y16d04" {
    const expect = std.testing.expect;

    try expect((try Room.fromLine("aaaaa-bbb-z-y-x-123[abxyz]")).is_valid);
    try expect((try Room.fromLine("a-b-c-d-e-f-g-h-987[abcde]")).is_valid);
    try expect((try Room.fromLine("not-a-real-room-404[oarel]")).is_valid);
    try expect(!(try Room.fromLine("totally-real-room-200[decoy]")).is_valid);
}
