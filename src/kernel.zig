const std = @import("std");
const uefi = std.os.uefi;

const console = @import("efi/output/console.zig");
const memory = @import("efi/memory.zig");

pub fn main() void {    
    console.setup_screen();
    
    var buffer = memory.getBuffer(8192);    
    var allocator = &std.heap.FixedBufferAllocator.init(buffer).allocator;    
    const writer = console.getWriter(allocator);
    
    try std.fmt.format(writer, "Hello World!\r\n\r\n", .{});
    try std.fmt.format(writer, "Options:\r\n", .{});
    try std.fmt.format(writer, "    Press 'r' to reboot\r\n", .{});
    try std.fmt.format(writer, "    Press 's' to shutdown\r\n", .{});
    
    while (true) {
        const time = uefi.system_table.runtime_services.*.getTime();
        try console.writeAtPosition(writer,
            40, 0,
            "{d:0>2}:{d:0>2}:{d:0>2}",
            .{time.hour,time.minute,time.second}
        );
        
        const reset = Reset.init(uefi.system_table.con_in.?.getKey());
        if(reset.shouldReset){
            memory.deleteBuffer(buffer);
            reset.reset();
        }
    }
}

pub const Reset = struct {
    const ResetType = uefi.tables.ResetType;
    shouldReset: bool,
    rtype: ResetType,
    
    pub fn init(char: u16) Reset{
        return Reset {
            .shouldReset = (char == 's' or char == 'r'),
            .rtype = switch(char){
                's' => .ResetShutdown,
                else => .ResetWarm,
            },
        };
    }
    
    pub fn reset(self: Reset) void{
        if(self.shouldReset){
            uefi.system_table.runtime_services.
                resetSystem(self.rtype, .Success, 0, null);
        }
    }
};

