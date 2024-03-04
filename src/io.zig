const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const fs = std.fs;
const mem = std.mem;

pub fn StdIn(
    allocator: mem.Allocator,
) In {
    const reader = io.getStdIn().reader();
    return In{ .allocator = allocator, .reader = reader };
}

pub const In = struct {
    allocator: mem.Allocator,
    reader: fs.File.Reader,

    const Self = @This();

    pub fn readInt(self: Self, comptime T: type, buf: []u8) !T {
        const r = (try self.reader.readUntilDelimiterOrEof(buf, '\n')).?;
        return fmt.parseInt(T, r, 10);
    }

    pub fn readLine(self: Self, buf: []u8) ![]const u8 {
        const r = (try self.reader.readUntilDelimiterOrEof(buf, '\n')).?;
        const slice = try self.allocator.alloc(u8, r.len);
        mem.copy(u8, slice, r);
        return slice;
    }
};
