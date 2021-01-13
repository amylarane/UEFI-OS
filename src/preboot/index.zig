const std = @import("std");
const efi = @import("../efi/index.zig");

const Allocator = std.mem.Allocator;
const Writer = efi.console.Writer;

var allocator: *Allocator = undefined;
var writer: Writer = undefined;

pub fn init() !void {
    allocator = efi.memory.getAllocator(2048);
    writer = efi.console.getWriter(allocator);

    efi.console.setup_screen();
}

pub fn end() !void {}

pub fn get_writer() Writer {
    return writer;
}

pub fn get_allocator() *Allocator {
    return allocator;
}
