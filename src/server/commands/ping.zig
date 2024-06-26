const std = @import("std");
const aids = @import("aids");
const core = @import("../core/core.zig");
const cmn = aids.cmn;
const net = std.net;
const comm = aids.v2.comm;
const SharedData = core.SharedData;
const Peer = core.Peer;

const str_allocator = std.heap.page_allocator;

fn printCmdUsage() void {
    std.debug.print("usage: :ping <flag>\n", .{});
    std.debug.print("FLAGS:\n", .{});
    std.debug.print("    * all .......... ping all peers\n", .{});
    std.debug.print("    * <peer_id> .... id of the peer to ping\n", .{});
}

pub fn executor(cmd: ?[]const u8, cd: ?core.sc.CommandData) void {
    var split = std.mem.splitBackwardsScalar(u8, cmd.?, ' ');
    if (split.next()) |arg| {
        if (std.mem.eql(u8, arg, cmd.?)) {
            std.log.err("missing flag", .{});
            printCmdUsage();
            return;
        }
        // TODO: connecton to server actions
        if (std.mem.eql(u8, arg, "all")) {
            for (cd.?.sd.peer_pool.items, 0..) |peer, pid| {
                const reqp = comm.Protocol{
                    .type = .REQ, // type
                    .action = .COMM, // action
                    .status = .OK, // status
                    .origin = .SERVER,
                    .sender_id = "", // sender_id
                    .src_addr = cd.?.sd.server.address_str, // src_address
                    .dest_addr = peer.conn_address_str, // dst address
                    .body = "check?", // body
                };
                reqp.dump(aids.Logging.Level.DEV);
                // TODO: I don't know why but i must send 2 requests to determine the status of the stream
                _ = reqp.transmit(peer.stream()) catch 1;
                const status = reqp.transmit(peer.stream()) catch 1;
                if (status == 1) {
                    // TODO: Put htis into cd.?.sd ??
                    cd.?.sd.peer_pool.items[pid].alive = false;
                }
            }
        } else {
            var found: bool = false;
            for (cd.?.sd.peer_pool.items, 0..) |peer, pid| {
                if (std.mem.eql(u8, peer.id, arg)) {
                    const reqp = comm.Protocol{
                        .type = .REQ,
                        .action = .COMM,
                        .status = .OK,
                        .origin = .SERVER,
                        .sender_id = "",
                        .src_addr = cd.?.sd.server.address_str,
                        .dest_addr = peer.conn_address_str,
                        .body = "check?",
                    };
                    reqp.dump(aids.Logging.Level.DEV);
                    // TODO: I don't know why but i must send 2 requests to determine the status of the stream
                    _ = reqp.transmit(peer.stream()) catch 1;
                    const status = reqp.transmit(peer.stream()) catch 1;
                    if (status == 1) {
                        // TODO: Put htis into cd.?.sd ??
                        cd.?.sd.peer_pool.items[pid].alive = false;
                    }
                    found = true;
                }
            }
            if (!found) {
                std.debug.print("Peer with id `{s}` was not found!\n", .{arg});
            }
        }
    }
}

pub const COMMAND = aids.Stab.Command(core.sc.CommandData){
    .executor = executor,
};
