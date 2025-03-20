const std = @import("std");
const CODES = @import("utils.zig").CODES;

pub const Result = union(enum) {
    ints: [2]i64,
    strs: [2]std.ArrayList(u8),

    pub fn from(comptime T: type, values: [2]T) Result {
        switch (T) {
            u64, i64, usize => {
                const val1: i64 = @intCast(values[0]);
                const val2: i64 = @intCast(values[1]);
                return Result{ .ints = .{ val1, val2 } };
            },
            std.ArrayList(u8) => return Result{ .strs = values },
            else => unreachable,
        }
    }

    pub fn clear(self: Result) void {
        if (self == Result.strs) for (self.strs) |list| list.deinit();
    }

    pub fn show(self: Result, name: []const u8, elapsed: u64, outw: std.fs.File.Writer) !void {
        switch (self) {
            .ints => |vals| try outw.print(CODES.GREEN ++ "{s} : {} - {} ({} µs)\n" ++ CODES.RESET, .{ name, vals[0], vals[1], elapsed / 1000 }),
            .strs => |vals| {
                try outw.print(CODES.GREEN ++ "{s} : {s} - {s} ({} µs)\n" ++ CODES.RESET, .{ name, vals[0].items, vals[1].items, elapsed / 1000 });
            },
        }
    }
};

pub const Solver = struct {
    name: []const u8,
    func: *const fn (std.mem.Allocator, []const u8) anyerror!Result,
};

pub const y15d01 = @import("solvers/y15d01.zig");
pub const y15d02 = @import("solvers/y15d02.zig");
pub const y15d03 = @import("solvers/y15d03.zig");

pub const y16d01 = @import("solvers/y16d01.zig");
pub const y16d02 = @import("solvers/y16d02.zig");
pub const y16d03 = @import("solvers/y16d03.zig");

pub const y17d01 = @import("solvers/y17d01.zig");
pub const y17d02 = @import("solvers/y17d02.zig");
pub const y17d03 = @import("solvers/y17d03.zig");

pub const y18d01 = @import("solvers/y18d01.zig");
pub const y18d02 = @import("solvers/y18d02.zig");
pub const y18d03 = @import("solvers/y18d03.zig");

pub const y19d01 = @import("solvers/y19d01.zig");
pub const y19d02 = @import("solvers/y19d02.zig");
pub const y19d03 = @import("solvers/y19d03.zig");
pub const y19d04 = @import("solvers/y19d04.zig");

pub const y20d01 = @import("solvers/y20d01.zig");
pub const y20d02 = @import("solvers/y20d02.zig");
pub const y20d03 = @import("solvers/y20d03.zig");
pub const y20d04 = @import("solvers/y20d04.zig");

pub const y21d01 = @import("solvers/y21d01.zig");
pub const y21d02 = @import("solvers/y21d02.zig");
pub const y21d03 = @import("solvers/y21d03.zig");
pub const y21d04 = @import("solvers/y21d04.zig");

pub const y22d01 = @import("solvers/y22d01.zig");
pub const y22d02 = @import("solvers/y22d02.zig");
pub const y22d03 = @import("solvers/y22d03.zig");
pub const y22d04 = @import("solvers/y22d04.zig");

pub const y23d01 = @import("solvers/y23d01.zig");
pub const y23d02 = @import("solvers/y23d02.zig");
pub const y23d03 = @import("solvers/y23d03.zig");
pub const y23d04 = @import("solvers/y23d04.zig");

pub const y24d01 = @import("solvers/y24d01.zig");
pub const y24d02 = @import("solvers/y24d02.zig");
pub const y24d03 = @import("solvers/y24d03.zig");
pub const y24d04 = @import("solvers/y24d04.zig");

pub const List = [_]Solver{
    Solver{ .name = "y15d01", .func = y15d01.solve },
    Solver{ .name = "y15d02", .func = y15d02.solve },
    Solver{ .name = "y15d03", .func = y15d03.solve },

    Solver{ .name = "y16d01", .func = y16d01.solve },
    Solver{ .name = "y16d02", .func = y16d02.solve },
    Solver{ .name = "y16d03", .func = y16d03.solve },

    Solver{ .name = "y17d01", .func = y17d01.solve },
    Solver{ .name = "y17d02", .func = y17d02.solve },
    Solver{ .name = "y17d03", .func = y17d03.solve },

    Solver{ .name = "y18d01", .func = y18d01.solve },
    Solver{ .name = "y18d02", .func = y18d02.solve },
    Solver{ .name = "y18d03", .func = y18d03.solve },

    Solver{ .name = "y19d01", .func = y19d01.solve },
    Solver{ .name = "y19d02", .func = y19d02.solve },
    Solver{ .name = "y19d03", .func = y19d03.solve },
    Solver{ .name = "y19d04", .func = y19d04.solve },

    Solver{ .name = "y20d01", .func = y20d01.solve },
    Solver{ .name = "y20d02", .func = y20d02.solve },
    Solver{ .name = "y20d03", .func = y20d03.solve },
    Solver{ .name = "y20d04", .func = y20d04.solve },

    Solver{ .name = "y21d01", .func = y21d01.solve },
    Solver{ .name = "y21d02", .func = y21d02.solve },
    Solver{ .name = "y21d03", .func = y21d03.solve },
    Solver{ .name = "y21d04", .func = y21d04.solve },

    Solver{ .name = "y22d01", .func = y22d01.solve },
    Solver{ .name = "y22d02", .func = y22d02.solve },
    Solver{ .name = "y22d03", .func = y22d03.solve },
    Solver{ .name = "y22d04", .func = y22d04.solve },

    Solver{ .name = "y23d01", .func = y23d01.solve },
    Solver{ .name = "y23d02", .func = y23d02.solve },
    Solver{ .name = "y23d03", .func = y23d03.solve },
    Solver{ .name = "y23d04", .func = y23d04.solve },

    Solver{ .name = "y24d01", .func = y24d01.solve },
    Solver{ .name = "y24d02", .func = y24d02.solve },
    Solver{ .name = "y24d03", .func = y24d03.solve },
    Solver{ .name = "y24d04", .func = y24d04.solve },
};
