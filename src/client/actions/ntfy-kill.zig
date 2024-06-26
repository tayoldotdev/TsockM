const std = @import("std");
const aids = @import("aids");
const rl = @import("raylib");
const ui = @import("../ui/ui.zig");
const core = @import("../core/core.zig");
const ClientActions = @import("actions.zig");
const Message = @import("../ui/display.zig").Message;
const net = std.net;
const comm = aids.v2.comm;
const Action = aids.Stab.Action;
const SharedData = core.SharedData;

fn collectRequest(in_conn: ?net.Server.Connection, sd: *SharedData, protocol: comm.Protocol) void {
    _ = in_conn;
    ClientActions.GET_PEER.transmit.?.request(comm.TransmitionMode.UNICAST, sd, protocol.body);
    const collocator = std.heap.page_allocator;
    // maybe i should free the collocator ??
    const get_peer_resp = comm.collect(collocator, sd.client.stream) catch |err| {
        std.log.err("ntfy-kill::collectRequest: {any}", .{err});
        std.posix.exit(1);
    };
    get_peer_resp.dump(sd.client.log_level);
    var splits = std.mem.splitScalar(u8, get_peer_resp.body, '#');
    const un = splits.next().?;
    const hash = splits.rest();
    //I dont have to free the allocated mem because if i do message gets corrupted
    const msg_txt = std.fmt.allocPrint(collocator, "'{s}#{s}' has died", .{ un, hash }) catch |err| {
        std.log.err("ntfy-kill::collectRequest: {any}", .{err});
        std.posix.exit(1);
    };
    // TODO: death message not needed ??
    const death_msg = Message{
        .author = "[server]",
        .text = msg_txt,
        .text_color = rl.Color.red,
    };
    var death_popup = ui.SimplePopup.init(sd.client.font, .TOP_CENTER, sd.client.FPS * 3);
    death_popup.setTextColor(rl.Color.sky_blue);
    death_popup.text = msg_txt;
    _ = sd.popups.append(death_popup) catch 1;
    sd.pushMessage(death_msg) catch |err| {
        std.log.err("ntfy-kill::collectRequest: {any}", .{err});
        std.posix.exit(1);
    };
}

fn collectRespone(sd: *SharedData, protocol: comm.Protocol) void {
    _ = sd;
    _ = protocol;
    std.log.err("not implemented", .{});
}

fn collectError(_: *SharedData) void {
    std.log.err("not implemented", .{});
}

fn transmitRequest(_: comm.TransmitionMode, _: *SharedData, _: []const u8) void {
    std.log.err("not implemented", .{});
}

fn transmitRespone() void {
    std.log.err("not implemented", .{});
}

fn transmitError() void {
    std.log.err("not implemented", .{});
}

pub const ACTION = Action(SharedData){
    .collect = .{
        .request = collectRequest,
        .response = collectRespone,
        .err = collectError,
    },
    .transmit = .{
        .request = transmitRequest,
        .response = transmitRespone,
        .err = transmitError,
    },
    .internal = null,
};
