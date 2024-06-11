const std = @import("std");
const aids = @import("aids");
const core = @import("../core/core.zig");
const cmn = aids.cmn;
const Protocol = aids.Protocol;
const net = std.net;
const Action = core.Action;
const SharedData = core.SharedData;
const Peer = core.Peer;

fn collectRequest(in_conn: net.Server.Connection, sd: *SharedData, protocol: Protocol) void {
    const addr_str = cmn.address_as_str(in_conn.address);
    const stream = in_conn.stream;

    // TODO: find a way around the allocator
    const tmp_allocator = std.heap.page_allocator;
    const peer = Peer.construct(tmp_allocator, in_conn, protocol);
    const peer_str = std.fmt.allocPrint(tmp_allocator, "{s}|{s}", .{ peer.id, peer.username }) catch "format failed";
    sd.peerPoolAppend(peer) catch |err| {
        std.log.err("`comm-action::collectRequest::peerPoolAppend`: {any}", .{err});
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

fn collectRespone(sd: *SharedData, protocol: Protocol) void {
    const opt_peer_ref = core.PeerCore.peerRefFromId(sd.peer_pool, protocol.sender_id);
    if (opt_peer_ref) |peer_ref| {
        std.debug.print("peer `{s}` is alive\n", .{peer_ref.peer.username});
    } else {
        std.debug.print("Peer with id `{s}` does not exist!\n", .{protocol.sender_id});
    }
}

fn collectError() void {
    std.log.err("not implemented", .{});
}

fn transmitRequest() void {
    std.log.err("not implemented", .{});
}

fn transmitRespone() void {
    std.log.err("not implemented", .{});
}

fn transmitError() void {
    std.log.err("not implemented", .{});
}

pub const ACTION = Action{
    .collect = .{
        .request  = collectRequest,
        .response = collectRespone,
        .err      = collectError,
    },
    .transmit = .{
        .request  = transmitRequest,
        .response = transmitRespone,
        .err      = transmitError,
    },
};