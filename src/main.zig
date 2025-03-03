const std = @import("std");
pub const solvers = @import("solvers.zig");

const GREEN_CODE = "\x1b[32m";
const RED_CODE = "\x1b[31m";
const RESET_CODE = "\x1b[0m";

pub fn main() !void {
    // -- GP Allocator
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const alloc = gpa.allocator();
    // defer std.debug.assert(gpa.deinit() == .ok);

    // -- Page Allocator
    const alloc = std.heap.page_allocator;

    const outw = std.io.getStdOut().writer();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var requested_solver: ?[]const u8 = null;
    if (args.len == 2) {
        requested_solver = args[1];
    }

    for (solvers.List) |solver| {
        if (requested_solver != null and !std.mem.eql(u8, requested_solver.?, solver.name)) {
            continue;
        }

        const file_name = try std.fmt.allocPrint(alloc, "inputs/{s}.txt", .{solver.name});

        const file = std.fs.cwd().openFile(file_name, .{}) catch {
            try outw.print(RED_CODE ++ "{s} : Unable to open input file\n" ++ RESET_CODE, .{solver.name});
            continue;
        };
        alloc.free(file_name);

        const input_raw = try file.readToEndAlloc(alloc, try std.math.powi(usize, 2, 16));
        file.close();
        const input = std.mem.trim(u8, input_raw, "\n");

        const results = solver.func(alloc, input) catch |err| {
            try outw.print(RED_CODE ++ "{s} : Solver returned an error - {s}\n" ++ RESET_CODE, .{ solver.name, @errorName(err) });
            continue;
        };
        alloc.free(input_raw);

        switch (results) {
            .ints => |vals| try outw.print(GREEN_CODE ++ "{s} : {} - {}\n" ++ RESET_CODE, .{ solver.name, vals[0], vals[1] }),
            .strs => |vals| {
                try outw.print(GREEN_CODE ++ "{s} : {s} - {s}\n" ++ RESET_CODE, .{ solver.name, vals[0].items, vals[1].items });
                for (vals) |list| {
                    list.deinit();
                }
            },
        }
    }
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
