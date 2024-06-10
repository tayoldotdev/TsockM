const std = @import("std");
const aids = @import("aids");
const core = @import("../core/core.zig");
const cmn = aids.cmn;
const Protocol = aids.Protocol;
const net = std.net;
const Action = core.Action;
const SharedData = core.SharedData;
const Peer = core.Peer;

fn onRequest(in_conn: net.Server.Connection, sd: *SharedData, protocol: Protocol) void {
    const addr_str = cmn.address_as_str(in_conn.address);
    const stream = in_conn.stream;

    // TODO: find a way around the allocator
    const tmp_allocator = std.heap.page_allocator;
    const peer = Peer.construct(tmp_allocator, in_conn, protocol);
    const peer_str = std.fmt.allocPrint(tmp_allocator, "{s}|{s}", .{ peer.id, peer.username }) catch "format failed";
    sd.peerPoolAppend(peer) catch |err| {
        std.log.err("`comm-action::onRequest::peerPoolAppend`: {any}", .{err});
        std.posix.exit(1);
    };
    const resp = Protocol.init(
        Protocol.Typ.RES,       // type
        Protocol.Act.COMM,      // action
        Protocol.StatusCode.OK, // status code
        "server",               // sender id
        sd.server.address_str,  // sender address
        addr_str,               // reciever address
        peer_str,               // body
    );
    resp.dump(sd.server.log_level);
    _ = Protocol.transmit(stream, resp);
}

fn onResponse() void {
    std.log.err("not implemented", .{});
}

fn onError() void {
    std.log.err("not implemented", .{});
}

pub const COMM_ACTION = Action{
    .onRequest = onRequest,
    .onResponse = onResponse,
    .onError = onError,
};
