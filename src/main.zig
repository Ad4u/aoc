const std = @import("std");
pub const solvers = @import("solvers.zig");

pub const CODES = struct {
    pub const GREEN = "\x1b[32m";
    pub const RED = "\x1b[31m";
    pub const RESET = "\x1b[0m";
};

const BENCH_RUNS = 100;

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
    var bench_mode: bool = false; // Silence result output (for benchmark)
    for (args) |arg| {
        for (solvers.List) |solver| {
            if (std.mem.eql(u8, arg, solver.name)) requested_solver = arg;
        }
        if (std.mem.eql(u8, arg, "bench")) bench_mode = true;
    }

    const nruns: usize = if (bench_mode) BENCH_RUNS else 1;

    const timing_file = std.fs.cwd().createFile("benchmark/timings.csv", .{}) catch {
        try outw.print(CODES.RED ++ "Unable to open input timings file\n" ++ CODES.RESET, .{});
        std.process.exit(1);
    };
    defer timing_file.close();
    try timing_file.writeAll("year,day,elapsed\n");

    var timer = try std.time.Timer.start();
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

        for (0..nruns) |i| {
            timer.reset();
            var results = solver.func(alloc, input) catch |err| {
                try outw.print(CODES.RED ++ "{s} : Solver returned an error - {s}\n" ++ CODES.RESET, .{ solver.name, @errorName(err) });
                continue;
            };
            const elapsed = timer.read();

            const line = try std.fmt.bufPrint(&buf, "{s},{s},{}\n", .{ solver.name[1..3], solver.name[4..], elapsed });
            try timing_file.writeAll(line);

            if (!bench_mode) try results.show(solver.name, elapsed, outw);
            results.clear();

            if (bench_mode) try outw.print("\r{s} - run {}/{}    \x00", .{ solver.name, i + 1, nruns });
        }
    }

    if (bench_mode) try outw.print("\n", .{});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
