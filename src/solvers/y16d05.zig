const std = @import("std");
const md5 = std.crypto.hash.Md5;
const Value = std.atomic.Value;
const Pool = std.Thread.Pool;
const Result = @import("../solvers.zig").Result;

const BM5: u128 = 0xffff_f000_0000_0000_0000_0000_0000_0000;

const FoundData = struct {
    counter: usize,
    char_5: u8,
    char_6: u8,
};

fn foundDataSort(_: void, a: FoundData, b: FoundData) bool {
    return a.counter < b.counter;
}

const Shared = struct {
    prefix: []const u8,
    done: Value(bool) = Value(bool).init(false),
    counter: Value(u64) = Value(u64).init(1000),
    mutex: std.Thread.Mutex = std.Thread.Mutex{},
    found: std.ArrayList(FoundData),
    pass_1: [8]u8 = @splat('_'),
    pass_2: [8]u8 = @splat('_'),

    fn passesOk(self: Shared) bool {
        if (std.mem.containsAtLeastScalar(u8, &self.pass_1, 1, '_')) return false;
        if (std.mem.containsAtLeastScalar(u8, &self.pass_2, 1, '_')) return false;
        return true;
    }

    fn fillPasses(self: *Shared) void {
        std.mem.sort(FoundData, self.found.items, {}, foundDataSort);

        if (self.found.items.len < 8) return;

        var b: [1]u8 = undefined;

        // Password 1
        for (self.found.items, 0..) |fd, i| {
            if (i > 7) continue;
            _ = std.fmt.bufPrint(&b, "{x}", .{fd.char_5}) catch unreachable;
            self.pass_1[i] = b[0];
        }

        // Password 2
        for (self.found.items) |fd| {
            const pos = fd.char_5;
            if (pos > 7) continue;
            if (self.pass_2[pos] != '_') continue;

            _ = std.fmt.bufPrint(&b, "{x}", .{fd.char_6 / 16}) catch unreachable;
            self.pass_2[pos] = b[0];
        }
    }
};

fn check_hash(buf: []u8, out: *[md5.digest_length]u8, n: usize, shared: *Shared) void {
    md5.hash(buf, out, .{});

    if (std.mem.readInt(u128, out, .big) & BM5 == 0) {
        shared.mutex.lock();
        defer shared.mutex.unlock();

        shared.found.append(FoundData{ .counter = n, .char_5 = out[2], .char_6 = out[3] }) catch unreachable;
        shared.fillPasses();

        if (shared.passesOk()) shared.done.store(true, std.builtin.AtomicOrder.monotonic);
    }
}

fn worker(shared: *Shared) void {
    var input_buffer: [32]u8 = undefined;
    var output_buffer: [md5.digest_length]u8 = undefined;
    while (!shared.done.load(std.builtin.AtomicOrder.unordered)) {
        const offset = shared.counter.fetchAdd(1000, std.builtin.AtomicOrder.monotonic);
        const slice = std.fmt.bufPrint(&input_buffer, "{s}{}", .{ shared.prefix, offset }) catch return;

        for (0..1000) |i| {
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
        .found = std.ArrayList(FoundData).init(alloc),
    };
    defer shared.found.deinit();

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

    var val1 = std.ArrayList(u8).init(alloc);
    var val2 = std.ArrayList(u8).init(alloc);
    try val1.appendSlice(&shared.pass_1);
    try val2.appendSlice(&shared.pass_2);

    return Result.from(std.ArrayList(u8), .{ val1, val2 });
}

test "y16d05" {
    const alloc = std.testing.allocator;
    const expectEqualStrings = std.testing.expectEqualStrings;

    const result = try solve(alloc, "abc");
    defer {
        for (result.strs) |list| list.deinit();
    }

    try expectEqualStrings("18f47a30", result.strs[0].items);
    try expectEqualStrings("05ace8e3", result.strs[1].items);
}
