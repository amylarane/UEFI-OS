const std = @import("std");

const console = @import("efi/output/console.zig");
const memory = @import("efi/memory.zig");
const uefi = std.os.uefi;

const Allocator = std.mem.Allocator;
const Writer = console.Writer;

var allocator: *Allocator = undefined;
var writer: Writer = undefined;

pub fn init_preboot() void {
    console.setup_screen();

    allocator = memory.getAllocator(8192);
    writer = console.getWriter(allocator);
}

pub fn main() noreturn {
    init_preboot();

    printBootMessage();

    eventLoop();
}

pub fn printBootMessage() void {
    try writer.print("Hello World!\n\n\r", .{});
    try writer.print("Options:\r\n", .{});
    try writer.print("    Press 'r' to reboot\r\n", .{});
    try writer.print("    Press 's' to shutdown\r\n", .{});
}

pub fn eventLoop() noreturn {
    while (true) {
        try console.writeAtPosition(writer, 40, 0, "{}", .{uefi.system_table.runtime_services.*.getTime()});

        const Reset = @import("efi/boot_manager/reset.zig").Reset;
        const reset = Reset.init(std.os.uefi.system_table.con_in.?.getKey());

        if (reset.shouldReset) {
            memory.deleteAllocator(allocator);
            reset.reset();
        }
    }
}
