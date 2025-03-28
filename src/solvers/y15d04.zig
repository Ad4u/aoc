const std = @import("std");
const md5 = std.crypto.hash.Md5;
const Value = std.atomic.Value;
const Pool = std.Thread.Pool;
const Result = @import("../solvers.zig").Result;

const BM5: u128 = 0xffff_f000_0000_0000_0000_0000_0000_0000;
const BM6: u128 = 0xffff_ff00_0000_0000_0000_0000_0000_0000;

const Shared = struct {
    prefix: []const u8,
    done: Value(bool) = Value(bool).init(false),
    counter: Value(u64) = Value(u64).init(1000),
    first: Value(u64) = Value(u64).init(std.math.maxInt(u64)),
    second: Value(u64) = Value(u64).init(std.math.maxInt(u64)),
};

fn check_hash(buf: []u8, out: *[md5.digest_length]u8, n: usize, shared: *Shared) void {
    md5.hash(buf, out, .{});

    if (std.mem.readInt(u128, out, .big) & BM5 == 0) {
        _ = shared.first.fetchMin(n, std.builtin.AtomicOrder.acquire);
    }

    if (std.mem.readInt(u128, out, .big) & BM6 == 0) {
        _ = shared.second.fetchMin(n, std.builtin.AtomicOrder.monotonic);
        shared.done.store(true, std.builtin.AtomicOrder.monotonic);
    }
}

fn worker(shared: *Shared) void {
    var input_buffer: [32]u8 = undefined;
    var output_buffer: [md5.digest_length]u8 = undefined;
    while (!shared.done.load(std.builtin.AtomicOrder.unordered)) {
        const offset = shared.counter.fetchAdd(1000, std.builtin.AtomicOrder.monotonic);
        const slice = std.fmt.bufPrint(&input_buffer, "{s}{}", .{ shared.prefix, offset }) catch return;

        for (0..1000) |i| {
            // std.debug.print("i: {}\n", .{i});
            slice[slice.len - 3] = '0' + @as(u8, @intCast(i / 100));
            slice[slice.len - 2] = '0' + @as(u8, @intCast((i / 10) % 10));
            slice[slice.len - 1] = '0' + @as(u8, @intCast(i % 10));

            check_hash(slice, &output_buffer, offset + i, shared);
        }
    }
}

pub fn solve(alloc: std.mem.Allocator, input: []const u8) !Result {
    var pool: Pool = undefined;
    try pool.init(Pool.Options{ .allocator = alloc });
    defer pool.deinit();

    var wait_group: std.Thread.WaitGroup = undefined;
    wait_group.reset();

    var shared = Shared{
        .prefix = input,
    };

    var input_buffer: [32]u8 = undefined;
    var output_buffer: [md5.digest_length]u8 = undefined;
    for (0..1000) |i| {
        const slice = try std.fmt.bufPrint(&input_buffer, "{s}{}", .{ shared.prefix, i });
        check_hash(slice, &output_buffer, i, &shared);
    }

    for (0..std.Thread.getCpuCount() catch 1) |_| {
        pool.spawnWg(&wait_group, worker, .{&shared});
    }
    pool.waitAndWork(&wait_group);

    const val1 = shared.first.load(std.builtin.AtomicOrder.unordered);
    const val2 = shared.second.load(std.builtin.AtomicOrder.unordered);

    return Result.from(u64, .{ val1, val2 });
}

test "y15d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(609043, (try solve(alloc, "abcdef")).ints[0]);
    try expectEqual(1048970, (try solve(alloc, "pqrstuv")).ints[0]);
}
