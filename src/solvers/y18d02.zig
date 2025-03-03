const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn analyseLine(alloc: std.mem.Allocator, line: []const u8) ![2]bool {
    var has_two = false;
    var has_three = false;

    var map = std.AutoHashMap(u8, u8).init(alloc);
    defer map.deinit();

    for (line) |c| {
        const entry = try map.getOrPutValue(c, 0);
        entry.value_ptr.* += 1;
    }

    var values = map.valueIterator();
    while (values.next()) |n| {
        if (n.* == 2) has_two = true;
        if (n.* == 3) has_three = true;
    }

    return .{ has_two, has_three };
}

fn calcCommon(alloc: std.mem.Allocator, input: []const u8) !std.ArrayList(u8) {
    var common_letters = std.ArrayList(u8).init(alloc);

    var outer = std.mem.tokenizeScalar(u8, input, '\n');
    while (outer.next()) |outer_line| {
        var inner = std.mem.tokenizeScalar(u8, input, '\n');
        while (inner.next()) |inner_line| {
            var diffs: usize = 0;
            for (0..outer_line.len) |i| {
                if (outer_line[i] != inner_line[i]) diffs += 1;
            }

            if (diffs == 1) {
                for (0..outer_line.len) |i| {
                    if (outer_line[i] == inner_line[i]) {
                        try common_letters.append(outer_line[i]);
                    }
                }
                return common_letters;
            }
        }
    }

    return error.LogicError;
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var list_1 = std.ArrayList(u8).init(alloc);

    var two: u64 = 0;
    var three: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const has_two, const has_three = try analyseLine(alloc, line);
        two += @intFromBool(has_two);
        three += @intFromBool(has_three);
    }
    try list_1.writer().print("{}", .{two * three});

    return Result.from(std.ArrayList(u8), .{ list_1, try calcCommon(alloc, input) });
}

test "y18d02" {
    const alloc = std.testing.allocator;
    const expectEqualStrings = std.testing.expectEqualStrings;

    const input_1 =
        \\abcdef
        \\bababc
        \\abbcde
        \\abcccd
        \\aabcdd
        \\abcdee
        \\ababab
    ;

    const input_2 =
        \\abcde
        \\fghij
        \\klmno
        \\pqrst
        \\fguij
        \\axcye
        \\wvxyz
    ;

    const res_1 = (try solve(alloc, input_1));
    const res_2 = (try solve(alloc, input_2));

    try expectEqualStrings("12", res_1.strs[0].items);
    try expectEqualStrings("fgij", res_2.strs[1].items);

    for (res_1.strs, res_2.strs) |r1, r2| {
        r1.deinit();
        r2.deinit();
    }
}
