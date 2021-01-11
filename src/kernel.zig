const std = @import("std");

const console = @import("efi/output/console.zig");
const memory = @import("efi/memory.zig");
const interrupts = @import("platform/interrupts/idt.zig");
const uefi = std.os.uefi;

const Allocator = std.mem.Allocator;
const Writer = console.Writer;

const GlobalDescriptorTable = @import("platform/interrupts/gdt.zig").GlobalDescriptorTable;

pub fn main() noreturn {    
    console.setup_screen();
    
    var allocator = memory.getAllocator(8192);
    var writer = console.getWriter(allocator);
    
    printBootMessage(writer);
       
    //const gdt = GlobalDescriptorTable.init();
    //gdt.load();
    //interrupts.idt.load();
    eventLoop(writer, allocator);
}

pub fn printBootMessage(writer: Writer) void {
    try std.fmt.format(writer, "Hello World!\n\n\r", .{});
    try std.fmt.format(writer, "Options:\r\n", .{});
    try std.fmt.format(writer, "    Press 'r' to reboot\r\n", .{});
    try std.fmt.format(writer, "    Press 's' to shutdown\r\n", .{}); 
}

pub fn eventLoop(writer: Writer, allocator: *Allocator) noreturn {
    while (true) {
        try console.writeAtPosition(writer, 40, 0, "{}", 
            .{uefi.system_table.runtime_services.*.getTime()});
        
        const Reset = @import("efi/boot_manager/reset.zig").Reset;
        const reset = Reset.init(std.os.uefi.system_table.con_in.?.getKey());
        
        if(reset.shouldReset){
            memory.deleteAllocator(allocator);
            reset.reset();
        }
    }
}