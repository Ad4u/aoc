const std = @import("std");
const Result = @import("../solvers.zig").Result;

const FORBIDDEN_PAIRS: [4][]const u8 = .{ "ab", "cd", "pq", "xy" };
const VOWELS: [5]u8 = .{ 'a', 'e', 'i', 'o', 'u' };

fn hasThreeVowels(str: []const u8) bool {
    var nvowels: u8 = 0;
    for (str) |c| {
        for (VOWELS) |v| {
            if (c == v) nvowels += 1;
        }
    }
    return nvowels >= 3;
}

fn hasPair(str: []const u8) bool {
    var wins = std.mem.window(u8, str, 2, 1);
    while (wins.next()) |w| {
        if (w[0] == w[1]) return true;
    }
    return false;
}

fn hasForbiddenPair(str: []const u8) bool {
    var wins = std.mem.window(u8, str, 2, 1);
    while (wins.next()) |w| {
        for (FORBIDDEN_PAIRS) |fp| {
            if (std.mem.eql(u8, w, fp)) return true;
        }
    }
    return false;
}

fn hasBridge(str: []const u8) bool {
    var wins = std.mem.window(u8, str, 3, 1);
    while (wins.next()) |w| {
        if (w[0] == w[2]) return true;
    }
    return false;
}

fn hasTwoPairs(str: []const u8) bool {
    for (0..str.len - 3) |i| {
        for (i + 2..str.len - 1) |j| {
            if (str[j] == str[i] and str[j + 1] == str[i + 1]) return true;
        }
    }
    return false;
}

fn isNice1(str: []const u8) bool {
    return hasThreeVowels(str) and hasPair(str) and !hasForbiddenPair(str);
}

fn isNice2(str: []const u8) bool {
    return hasBridge(str) and hasTwoPairs(str);
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var nice_1: u64 = 0;
    var nice_2: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (isNice1(line)) nice_1 += 1;
        if (isNice2(line)) nice_2 += 1;
    }

    return Result.from(u64, .{ nice_1, nice_2 });
}

test "y15d05" {
    const expect = std.testing.expect;

    try expect(isNice1("ugknbfddgicrmopn"));
    try expect(isNice1("aaa"));
    try expect(!isNice1("jchzalrnumimnmhp"));
    try expect(!isNice1("haegwjzuvuyypxyu"));
    try expect(!isNice1("dvszwmarrgswjxmb"));

    try expect(isNice2("qjhvhtzxzqqjkmpb"));
    try expect(isNice2("xxyxx"));
    try expect(!isNice2("uurcxstgmygtbstg"));
    try expect(!isNice2("ieodomkazucvgmuy"));
}
