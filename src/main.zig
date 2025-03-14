const std = @import("std");
pub const solvers = @import("solvers.zig");

pub const CODES = struct {
    pub const GREEN = "\x1b[32m";
    pub const RED = "\x1b[31m";
    pub const RESET = "\x1b[0m";
};

pub fn main() !void {
    // -- GP Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    // -- Page Allocator
    // const alloc = std.heap.page_allocator;

    const outw = std.io.getStdOut().writer();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    // Use Zig-Clap for parsing ?
    var requested_solver: ?[]const u8 = null; // Run only one solver
    if (args.len >= 2) requested_solver = args[1];

    const timing_file = std.fs.cwd().createFile("timings.csv", .{}) catch {
        try outw.print(CODES.RED ++ "Unable to open input timings file\n" ++ CODES.RESET, .{});
        std.process.exit(1);
    };
    defer timing_file.close();
    try timing_file.writeAll("year,day,elapsed\n");

    var timer = try std.time.Timer.start();
    var total_time: u64 = 0;
    var buf: [64]u8 = undefined; // Buffer to write new line to timing_file

    for (solvers.List) |solver| {
        if (requested_solver != null and !std.mem.eql(u8, requested_solver.?, solver.name)) {
            continue;
        }

        const file_name = try std.fmt.allocPrint(alloc, "inputs/{s}.txt", .{solver.name});
        defer alloc.free(file_name);

        const file = std.fs.cwd().openFile(file_name, .{}) catch {
            try outw.print(CODES.RED ++ "{s} : Unable to open input file\n" ++ CODES.RESET, .{solver.name});
            continue;
        };
        defer file.close();

        const input_raw = try file.readToEndAlloc(alloc, try std.math.powi(usize, 2, 16));
        const input = std.mem.trim(u8, input_raw, "\n");
        defer alloc.free(input_raw);

        timer.reset();
        var results = solver.func(alloc, input) catch |err| {
            try outw.print(CODES.RED ++ "{s} : Solver returned an error - {s}\n" ++ CODES.RESET, .{ solver.name, @errorName(err) });
            continue;
        };
        const elapsed = timer.read();
        total_time += elapsed;

        const line = try std.fmt.bufPrint(&buf, "{s},{s},{}\n", .{ solver.name[1..3], solver.name[4..], elapsed });
        try timing_file.writeAll(line);

        try results.show(solver.name, elapsed, outw);
        results.clear();
    }

    try outw.print("Total time: {} ms\n", .{total_time / 1_000_000});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
