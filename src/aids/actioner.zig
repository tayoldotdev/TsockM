const std = @import("std");
const comm = @import("aids.zig").v2.comm;

pub fn Action(comptime T: type) type {
    return struct {
        collect: ?struct {
            request: *const fn (?std.net.Server.Connection, *T, comm.Protocol) void,
            response: *const fn (*T, comm.Protocol) void,
            err: *const fn (*T) void,
        },
        transmit: ?struct {
            request: *const fn (comm.TransmitionMode, *T, []const u8) void,
            response: *const fn () void,
            err: *const fn () void,
        },
        internal: ?*const fn (*T) void,
    };
}

pub const Act = enum(u8) {
    COMM,
    COMM_END,
    MSG,
    GET_PEER,
    NTFY_KILL,
    NONE,
    CLEAN_PEER_POOL,
};

pub fn parseAct(act: comm.Act) Act {
    return switch (act) {
        .COMM => Act.COMM,
        .COMM_END => Act.COMM_END,
        .MSG => Act.MSG,
        .GET_PEER => Act.GET_PEER,
        .NTFY_KILL => Act.NTFY_KILL,
        .NONE => Act.NONE,
    };
}

pub fn Actioner(comptime T: type) type {
    return struct {
        actions: std.AutoHashMap(Act, Action(T)),
        pub fn init(allocator: std.mem.Allocator) Actioner(T) {
            const actions = std.AutoHashMap(Act, Action(T)).init(allocator);
            return Actioner(T){
                .actions = actions,
            };
        }
        pub fn add(self: *@This(), caller: Act, act: Action(T)) void {
            self.actions.put(caller, act) catch |err| {
                std.log.err("`core::Actioner::add`: {any}\n", .{err});
                std.posix.exit(1);
            };
        }
        pub fn get(self: *@This(), caller: Act) ?Action(T) {
            return self.actions.get(caller);
        }
        pub fn deinit(self: *@This()) void {
            self.actions.deinit();
        }
    };
}

test "Act-len" {
    try std.testing.expectEqual(7, std.meta.fields(Act).len);
}

test "parseAct" {
    try std.testing.expectEqual(Act.NONE, parseAct(.NONE));
    try std.testing.expectEqual(Act.MSG, parseAct(.MSG));
    try std.testing.expectEqual(Act.COMM, parseAct(.COMM));
    try std.testing.expectEqual(Act.COMM_END, parseAct(.COMM_END));
    try std.testing.expectEqual(Act.GET_PEER, parseAct(.GET_PEER));
    try std.testing.expectEqual(Act.NTFY_KILL, parseAct(.NTFY_KILL));
}
