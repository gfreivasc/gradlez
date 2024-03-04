const std = @import("std");
const col = @import("collections.zig");
const mem = std.mem;

pub const GradleRuntime = struct {
    allocator: mem.Allocator,
    is_debug: bool,

    const Self = @This();

    pub fn runTasks(self: Self, modules: []const []const u8, tasks: []const []const u8) !void {
        // no tasks means nothing to do
        if (tasks.len < 1) {
            return;
        }
        var proc: std.ChildProcess = undefined;
        if (modules.len >= 1) {
            var execTasks = std.ArrayList([]const u8).init(self.allocator);
            const taskGroups = try col.associate([]const u8, []const u8, self.allocator, modules, tasks);
            for (taskGroups) |p| {
                var buf = try self.allocator.alloc(u8, 2 + p.l.len + p.r.len);
                const joined = try col.joinStr(self.allocator, &[_][]const u8{ p.l, p.r }, ":");
                buf[0] = ':';
                mem.copy(u8, buf[1..], joined);
                try execTasks.append(buf);
            }
            proc = try createGradleProcess(self, execTasks.items);
        } else {
            proc = try createGradleProcess(self, tasks);
        }
        const argvStr = try col.joinStr(self.allocator, proc.argv, " ");
        std.log.debug("Starting process {s}/{s}\n", .{ proc.cwd.?, argvStr });
        _ = try proc.spawnAndWait();
    }

    fn createGradleProcess(self: Self, args: []const []const u8) !std.ChildProcess {
        var buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const cwd = try std.process.getCwd(&buffer);
        const argv = try buildGradleArgv(self, args);
        var proc = std.ChildProcess.init(argv, self.allocator);
        proc.cwd = try resolveCwd(self, cwd);
        return proc;
    }

    fn buildGradleArgv(self: Self, args: []const []const u8) ![]const []const u8 {
        var buffer = std.ArrayList([]const u8).init(self.allocator);
        try buffer.append("bash");
        try buffer.append("gradlew");
        for (args) |arg| {
            try buffer.append(arg);
        }
        return buffer.items;
    }

    fn resolveCwd(self: Self, base: []const u8) ![]const u8 {
        if (self.is_debug) {
            return std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ base, "sample-gradle" });
        } else {
            return base;
        }
    }
};
