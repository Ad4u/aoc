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

    var timings = std.StringHashMap(std.ArrayList(u64)).init(alloc);
    defer {
        var iter = timings.valueIterator();
        while (iter.next()) |list| list.deinit();
        timings.deinit();
    }

    var timer = try std.time.Timer.start();

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

            var entry = timings.getOrPutValue(solver.name, std.ArrayList(u64).init(alloc)) catch |err| {
                try outw.print(CODES.RED ++ "Error when adding timing array for {s}: {s}" ++ CODES.RESET, .{ solver.name, @errorName(err) });
                continue;
            };
            entry.value_ptr.append(elapsed) catch |err| {
                try outw.print(CODES.RED ++ "Error when adding timing entry for {s}: {s} " ++ CODES.RESET, .{ solver.name, @errorName(err) });
                continue;
            };

            if (!bench_mode) try results.show(solver.name, elapsed, outw);
            results.clear();

            if (bench_mode) try outw.print("\r{s} - run {}/{}    \x00", .{ solver.name, i + 1, nruns });
        }
    }

    if (bench_mode) try outw.print("\n", .{});

    exportTimings(timings, nruns, "benchmark/timings.csv") catch |err| {
        try outw.print(CODES.RED ++ "Error when exporting timings: {s}" ++ CODES.RESET, .{@errorName(err)});
    };
}

// Very inefficient way to export to CSV. TODO: improve it.
fn exportTimings(timings: std.StringHashMap(std.ArrayList(u64)), nruns: usize, filepath: []const u8) !void {
    const timings_file = try std.fs.cwd().createFile(filepath, .{});
    defer timings_file.close();

    // Header
    var first_header = true;
    for (solvers.List) |solver| {
        if (!timings.contains(solver.name)) continue;

        if (!first_header) try timings_file.writeAll(",");
        try timings_file.writeAll(solver.name);
        first_header = false;
    }
    try timings_file.writeAll("\n");

    // Timings
    var buf: [64]u8 = undefined;
    for (0..nruns) |i| {
        var first_timing = true;
        for (solvers.List) |solver| {
            if (!timings.contains(solver.name)) continue;

            if (!first_timing) try timings_file.writeAll(",");
            const time = timings.get(solver.name).?.items[i];
            const time_str = try std.fmt.bufPrint(&buf, "{}", .{time / 1000});
            try timings_file.writeAll(time_str);
            first_timing = false;
        }
        try timings_file.writeAll("\n");
    }
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
