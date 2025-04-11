const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main_module = b.addModule("aoc", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const mvzr = b.dependency("mvzr", .{ .target = target, .optimize = optimize });

    const exe = b.addExecutable(.{
        .name = "aoc",
        .root_module = main_module,
    });
    exe.root_module.addImport("mvzr", mvzr.module("mvzr"));
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    const test_filters = b.option([]const []const u8, "test-filter", "Skip tests that do not match any filter") orelse &[0][]const u8{};
    const exe_unit_tests = b.addTest(.{ .root_module = main_module, .target = target, .optimize = optimize, .filters = test_filters });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    test_step.dependOn(&run_exe_unit_tests.step);

    const exe_check = b.addExecutable(.{
        .name = "aoc",
        .root_module = main_module,
    });
    const check = b.step("check", "Check if code compiles");
    check.dependOn(&exe_check.step);
}

fn fatal(err: anyerror) noreturn {
    std.debug.print("Error during build process: {s}", .{@errorName(err)});
    std.process.exit(1);
}
