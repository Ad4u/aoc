const std = @import("std");
const Result = @import("../solvers.zig").Result;

fn calcFuel(mass: i64) i64 {
    return @divTrunc(mass, 3) - 2;
}

fn calcFuelAdded(mass: i64) i64 {
    var total_mass: i64 = 0;
    var new_mass = mass;
    while (true) {
        new_mass = calcFuel(new_mass);
        if (new_mass <= 0) {
            break;
        }
        total_mass += new_mass;
    }
    return total_mass;
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var total_fuel_wo: i64 = 0;
    var total_fuel_wi: i64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const module_mass = try std.fmt.parseInt(i64, line, 10);

        total_fuel_wo += calcFuel(module_mass);
        total_fuel_wi += calcFuelAdded(module_mass);
    }

    return Result.from(i64, .{ total_fuel_wo, total_fuel_wi });
}

test "y19d01" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    try expectEqual(2, (try solve(alloc, "12")).ints[0]);
    try expectEqual(.{ 2, 2 }, (try solve(alloc, "14")).ints);
    try expectEqual(.{ 654, 966 }, (try solve(alloc, "1969")).ints);
    try expectEqual(.{ 33583, 50346 }, (try solve(alloc, "100756")).ints);
}
