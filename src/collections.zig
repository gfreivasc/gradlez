const std = @import("std");
const mem = std.mem;

pub fn joinStr(allocator: mem.Allocator, items: []const []const u8, separator: []const u8) ![]const u8 {
    var builder = std.ArrayList(u8).init(allocator);
    const count = items.len;
    for (items, 0..) |item, i| {
        try appendEach(u8, &builder, item);
        if (i < count - 1) {
            try appendEach(u8, &builder, separator);
        }
    }
    return builder.items;
}

pub fn appendEach(comptime T: type, list: *std.ArrayList(T), source: []const T) !void {
    for (source) |e| {
        try list.*.append(e);
    }
}

pub fn Pair(comptime Tl: type, comptime Tr: type) type {
    return struct { l: Tl, r: Tr };
}

pub fn associate(comptime Tl: type, comptime Tr: type, allocator: mem.Allocator, left: []const Tl, right: []const Tr) ![]Pair(Tl, Tr) {
    var list = std.ArrayList(Pair(Tl, Tr)).init(allocator);
    for (left) |le| {
        for (right) |re| {
            try list.append(Pair(Tl, Tr){ .l = le, .r = re });
        }
    }
    return list.items;
}

test "joinToStr" {
    const allocator = std.heap.page_allocator;
    var all = "all of them";
    const input = [_][]const u8{ "test", "one", "two", all };
    const output = try joinStr(allocator, &input, ", ");
    try std.testing.expect(mem.eql(u8, output, "test, one, two, all of them"));
}
