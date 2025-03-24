const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn hasDuplicate(words: std.StringHashMap(u8)) bool {
    var val_iter = words.valueIterator();
    while (val_iter.next()) |val| if (val.* > 1) return true;
    return false;
}

fn isValid(a: std.mem.Allocator, line: []const u8) ![2]bool {
    var arena = std.heap.ArenaAllocator.init(a);
    defer arena.deinit();
    const alloc = arena.allocator();

    var words = std.StringHashMap(u8).init(alloc);
    var words_sorted = std.StringHashMap(u8).init(alloc);

    var iter = std.mem.tokenizeScalar(u8, line, ' ');
    while (iter.next()) |w| {
        const entry = try words.getOrPutValue(w, 0);
        entry.value_ptr.* += 1;

        const sorted_word = try std.mem.Allocator.dupe(alloc, u8, w);
        std.mem.sort(u8, sorted_word, {}, comptime std.sort.asc(u8));
        const entry_sorted = try words_sorted.getOrPutValue(sorted_word, 0);
        entry_sorted.value_ptr.* += 1;
    }

    const val1 = !hasDuplicate(words);
    const val2 = !hasDuplicate(words_sorted);

    return .{ val1, val2 };
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var total_1: u64 = 0;
    var total_2: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const val1, const val2 = try isValid(alloc, line);
        if (val1) total_1 += 1;
        if (val2) total_2 += 1;
    }

    return Result.from(u64, .{ total_1, total_2 });
}

test "y17d04" {
    const alloc = std.testing.allocator;
    const expect = std.testing.expect;

    try expect((try isValid(alloc, "aa bb cc dd ee"))[0]);
    try expect(!(try isValid(alloc, "aa bb cc dd aa"))[0]);
    try expect((try isValid(alloc, "aa bb cc dd aaa"))[0]);

    try expect((try isValid(alloc, "abcde fghij"))[1]);
    try expect(!(try isValid(alloc, "abcde xyz ecdab"))[1]);
    try expect((try isValid(alloc, "a ab abc abd abf abj"))[1]);
    try expect((try isValid(alloc, "iiii oiii ooii oooi oooo"))[1]);
    try expect(!(try isValid(alloc, "oiii ioii iioi iiio"))[1]);
}
