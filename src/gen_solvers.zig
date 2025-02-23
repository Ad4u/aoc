const std = @import("std");

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = try std.process.argsAlloc(arena);

    const output_file_path = args[1];
    var output_file = std.fs.cwd().createFile(output_file_path, .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ output_file_path, @errorName(err) });
    };
    defer output_file.close();

    const solvers = args[2..];
    const output_writer = output_file.writer();
    for (solvers) |s| {
        output_writer.print("pub const {s} = @import(\"{s}\");\n", .{ s, s }) catch |err| {
            fatal("unable to write to '{s}': {s}", .{ output_file_path, @errorName(err) });
        };
    }

    return std.process.cleanExit();
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
