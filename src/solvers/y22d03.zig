const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn findCommonItem(line: []const u8) !u8 {
    const size = line.len;

    for (line[0 .. size / 2]) |c1| {
        for (line[size / 2 ..]) |c2| {
            if (c1 == c2) return c1;
        }
    }

    return error.BadInput;
}

fn calcPriority(item: u8) u8 {
    switch (std.ascii.isUpper(item)) {
        false => return 1 + item - 'a',
        true => return 27 + item - 'A',
    }
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var items = std.AutoHashMap(u8, [3]bool).init(alloc);
    defer items.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var total_priority_1: u64 = 0;
    var total_priority_2: u64 = 0;
    var i: usize = 0;
    while (lines.next()) |line| {
        // Part 1
        const common_item = try findCommonItem(line);
        const item_priority: u64 = @intCast(calcPriority(common_item));
        total_priority_1 += item_priority;

        // Part 2
        for (line) |c| {
            const entry = try items.getOrPutValue(c, .{ false, false, false });
            entry.value_ptr.*[i % 3] = true;
        }

        // Check for common item every 3 lines
        i += 1;
        if (i % 3 == 0) {
            var vals = items.iterator();
            while (vals.next()) |entry| {
                if (std.mem.eql(bool, entry.value_ptr, &[3]bool{ true, true, true })) {
                    const badge_priority: u64 = @intCast(calcPriority(entry.key_ptr.*));
                    total_priority_2 += badge_priority;
                }
            }
            items.clearRetainingCapacity();
        }
    }

    return Result.from(u64, .{ total_priority_1, total_priority_2 });
}

test "y22d03" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\vJrwpWtwJgWrhcsFMMfFFhFp
        \\jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        \\PmmdzqPrVvPwwTWBwg
        \\wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        \\ttgJtRGJQctTZtZT
        \\CrZsJsPPZsGzwwsLwLmpwMDw
    ;

    try expectEqual(.{ 157, 70 }, (try solve(alloc, input)).ints);
}
