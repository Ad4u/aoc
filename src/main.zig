const std = @import("std");
const solvers = @import("solvers");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);
    // var buf: [1_000_000]u8 = undefined;
    // var fba = std.heap.FixedBufferAllocator.init(&buf);
    // var alloc = fba.allocator();

    const outw = std.io.getStdOut().writer();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var requested_solver: ?[]const u8 = null;
    if (args.len == 2) {
        requested_solver = args[1];
    }

    var benchmark_file = try std.fs.cwd().createFile("benchmark/output.txt", .{});
    defer benchmark_file.close();

    var timer = try std.time.Timer.start();
    var total_time: u64 = 0;

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

            timer.reset();
            const results = @field(solvers, d.name).solve(alloc, input) catch |err| {
                try outw.print("{s} : Solver returned an error - {s}\n", .{ d.name, @errorName(err) });
                break :loop;
            };
            const solver_time = timer.read();
            total_time += solver_time;

            const fmt = switch (@TypeOf(results)) {
                [2][]const u8 => "{s} : {s} - {s}",
                else => "{s} : {} - {}",
            };
            try outw.print(fmt, .{ d.name, results[0], results[1] });
            try outw.print(" ({} us)\n", .{solver_time / std.time.ns_per_us});

            const bench_line = try std.fmt.allocPrint(alloc, "{s} {}\n", .{ d.name, solver_time / std.time.ns_per_us });
            defer alloc.free(bench_line);
            try benchmark_file.writeAll(bench_line);
        }
    }
    try outw.print("Total time : {} us\n", .{total_time / std.time.ns_per_us});
}
