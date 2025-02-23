const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Generate solvers.zig main import
    const gen_solvers_exe = b.addExecutable(.{
        .name = "generate_solvers",
        .root_source_file = b.path("src/gen_solvers.zig"),
        .target = target,
        .optimize = optimize,
    });

    const gen_solvers_step = b.addRunArtifact(gen_solvers_exe);
    const output_solvers = gen_solvers_step.addOutputFileArg("src/solvers.zig");

    const test_step = b.step("test", "Run unit tests");

    // Imports all solvers module
    var imports_array = std.ArrayList(std.Build.Module.Import).init(b.allocator);
    const cwd_dir = std.fs.cwd();
    for (15..25) |year| {
        for (1..25) |day| {
            const file_name = std.fmt.allocPrint(b.allocator, "y{}d{:0>2}", .{ year, day }) catch |err| fatal(err);
            const file_path = std.fmt.allocPrint(b.allocator, "src/solvers/{s}.zig", .{file_name}) catch |err| fatal(err);
            cwd_dir.access(file_path, .{}) catch continue;

            const mod = b.createModule(.{ .root_source_file = b.path(file_path), .target = target, .optimize = optimize });
            imports_array.append(.{ .name = file_name, .module = mod }) catch |err| fatal(err);
            gen_solvers_step.addArg(file_name);

            // Tests
            const exe_unit_tests = b.addTest(.{ .root_source_file = b.path(file_path), .target = target, .optimize = optimize });
            const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
            test_step.dependOn(&run_exe_unit_tests.step);
        }
    }
    const imports = imports_array.toOwnedSlice() catch |err| fatal(err);

    exe.root_module.addAnonymousImport("solvers", .{ .root_source_file = output_solvers, .imports = imports });
}

fn fatal(err: anyerror) noreturn {
    std.debug.print("Error during build process: {s}", .{@errorName(err)});
    std.process.exit(1);
}
