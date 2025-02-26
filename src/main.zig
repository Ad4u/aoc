const std = @import("std");
const solvers = @import("solvers");

pub fn main() !void {
    // -- GP Allocator
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const alloc = gpa.allocator();
    // defer std.debug.assert(gpa.deinit() == .ok);

    // -- FB Allocator
    var buf: [1024 * 1024 * 8]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var alloc = fba.allocator();

    // -- Page Allocator
    // const alloc = std.heap.page_allocator;

    const outw = std.io.getStdOut().writer();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var requested_solver: ?[]const u8 = null;
    if (args.len == 2) {
        requested_solver = args[1];
    }

    // We need "continue" inside inline for loop to get rid of: break :loop;
    // https://github.com/ziglang/zig/issues/9524
    inline for (@typeInfo(solvers).Struct.decls) |d| {
        loop: {
            if (requested_solver != null and !std.mem.eql(u8, requested_solver.?, d.name)) {
                break :loop;
            }

            const file_name = try std.fmt.allocPrint(alloc, "inputs/{s}.txt", .{d.name});
            defer alloc.free(file_name);

            const file = std.fs.cwd().openFile(file_name, .{}) catch {
                try outw.print("{s} : Unable to open input file\n", .{d.name});
                break :loop;
            };

            const input_raw = try file.readToEndAlloc(alloc, try std.math.powi(usize, 2, 16));
            const input = std.mem.trim(u8, input_raw, "\n");
            defer alloc.free(input_raw);

            const results = @field(solvers, d.name).solve(alloc, input) catch |err| {
                try outw.print("{s} : Solver returned an error - {s}\n", .{ d.name, @errorName(err) });
                break :loop;
            };

            switch (@TypeOf(results)) {
                [2]std.ArrayList(u8) => {
                    try outw.print("{s} : {s} - {s}\n", .{ d.name, results[0].items, results[1].items });
                    for (results) |list| {
                        list.deinit();
                    }
                },
                else => try outw.print("{s} : {} - {}\n", .{ d.name, results[0], results[1] }),
            }
        }
    }
}
