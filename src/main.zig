const std = @import("std");
const io = @import("io.zig");
const run = @import("runtime.zig");
const fs = std.fs;
const heap = std.heap;
const mem = std.mem;
const testing = std.testing;

const PROC_IO_BUFFER_SIZE: usize = 50 * 1024;

pub fn main() !void {
    var allocator = heap.ArenaAllocator.init(heap.page_allocator);
    defer allocator.deinit();
    var proc = run.GradleRuntime{ .allocator = allocator.allocator(), .is_debug = true };
    try proc.runTasks(&[_][]const u8{"module-b"}, &[_][]const u8{ "clean", "build" });
}
