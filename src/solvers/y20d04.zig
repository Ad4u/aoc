const std = @import("std");
const Result = @import("../solvers.zig").Result;

const EYE_COLORS: [7][]const u8 = .{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };

const Passport = struct {
    byr: ?[]const u8 = null,
    iyr: ?[]const u8 = null,
    eyr: ?[]const u8 = null,
    hgt: ?[]const u8 = null,
    hcl: ?[]const u8 = null,
    ecl: ?[]const u8 = null,
    pid: ?[]const u8 = null,
    cid: ?[]const u8 = null,

    fn fromBlock(block: []const u8) !Passport {
        var passport = Passport{};

        var seqs = std.mem.tokenizeAny(u8, block, " \n");
        while (seqs.next()) |seq| {
            const sep_idx_opt = std.mem.indexOf(u8, seq, ":");
            if (sep_idx_opt == null) return error.BadInput;
            const i = sep_idx_opt.?;

            if (std.mem.eql(u8, seq[0..i], "byr")) passport.byr = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "iyr")) passport.iyr = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "eyr")) passport.eyr = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "hgt")) passport.hgt = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "hcl")) passport.hcl = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "ecl")) passport.ecl = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "pid")) passport.pid = seq[i + 1 ..];
            if (std.mem.eql(u8, seq[0..i], "cid")) passport.cid = seq[i + 1 ..];
        }

        return passport;
    }

    fn hasFields(self: Passport) bool {
        if (self.byr == null) return false;
        if (self.iyr == null) return false;
        if (self.eyr == null) return false;
        if (self.hgt == null) return false;
        if (self.hcl == null) return false;
        if (self.ecl == null) return false;
        if (self.pid == null) return false;

        return true;
    }

    fn isValid(self: Passport) !bool {
        if (!self.hasFields()) return false;

        // BYR
        const byr = try std.fmt.parseInt(u32, self.byr.?, 10);
        if (byr < 1920 or byr > 2002) return false;

        // IYR
        const iyr = try std.fmt.parseInt(u32, self.iyr.?, 10);
        if (iyr < 2010 or iyr > 2020) return false;

        // EYR
        const eyr = try std.fmt.parseInt(u32, self.eyr.?, 10);
        if (eyr < 2020 or eyr > 2030) return false;

        // HGT
        const i = self.hgt.?.len - 2;
        const unit = self.hgt.?[i..];
        const value_str = self.hgt.?[0..i];
        const value = std.fmt.parseInt(u32, value_str, 10) catch return false;
        if (std.mem.eql(u8, unit, "in")) {
            if (value < 59 or value > 76) return false;
        } else if (std.mem.eql(u8, unit, "cm")) {
            if (value < 150 or value > 193) return false;
        } else return false;

        // HCL
        if (self.hcl.?[0] != '#') return false;
        for (self.hcl.?[1..]) |c| if (!std.ascii.isHex(c)) return false;

        // ECL
        var found = false;
        for (EYE_COLORS) |color| {
            if (std.mem.eql(u8, color, self.ecl.?)) {
                found = true;
                continue;
            }
        }
        if (!found) return false;

        // PID
        if (self.pid.?.len != 9) return false;
        for (self.pid.?) |c| if (!std.ascii.isDigit(c)) return false;

        return true;
    }
};

pub fn solve(_: std.mem.Allocator, input: []const u8) !Result {
    var blocks = std.mem.tokenizeSequence(u8, input, "\n\n");

    var n_fields: u64 = 0;
    var n_valids: u64 = 0;

    var i: usize = 0;
    while (blocks.next()) |block| : (i += 1) {
        const p = try Passport.fromBlock(block);
        if (p.hasFields()) n_fields += 1;
        if (try p.isValid()) n_valids += 1;
    }

    return Result.from(usize, .{ n_fields, n_valids });
}

test "y20d04" {
    const alloc = std.testing.allocator;
    const expectEqual = std.testing.expectEqual;

    const input =
        \\ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
        \\byr:1937 iyr:2017 cid:147 hgt:183cm
        \\
        \\iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
        \\hcl:#cfa07d byr:1929
        \\
        \\hcl:#ae17e1 iyr:2013
        \\eyr:2024
        \\ecl:brn pid:760753108 byr:1931
        \\hgt:179cm
        \\
        \\hcl:#cfa07d eyr:2025 pid:166559648
        \\iyr:2011 ecl:brn hgt:59in
    ;

    const all_invalid =
        \\eyr:1972 cid:100
        \\hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
        \\
        \\iyr:2019
        \\hcl:#602927 eyr:1967 hgt:170cm
        \\ecl:grn pid:012533040 byr:1946
        \\
        \\hcl:dab227 iyr:2012
        \\ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
        \\
        \\hgt:59cm ecl:zzz
        \\eyr:2038 hcl:74454a iyr:2023
        \\pid:3556412378 byr:2007
    ;

    const all_valid =
        \\pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
        \\hcl:#623a2f
        \\
        \\eyr:2029 ecl:blu cid:129 byr:1989
        \\iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
        \\
        \\hcl:#888785
        \\hgt:164cm byr:2001 iyr:2015 cid:88
        \\pid:545766238 ecl:hzl
        \\eyr:2022
        \\
        \\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    ;

    try expectEqual(2, (try solve(alloc, input)).ints[0]);
    try expectEqual(0, (try solve(alloc, all_invalid)).ints[1]);
    try expectEqual(4, (try solve(alloc, all_valid)).ints[1]);
}
