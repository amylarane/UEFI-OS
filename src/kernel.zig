const std = @import("std");
const uefi = std.os.uefi;
const Time = uefi.Time;
const Allocator = std.mem.Allocator;
const io = std.io;
const Writer = std.io.Writer;

var allocator: *Allocator = undefined;

pub fn main() void {
    const reset = uefi.system_table.runtime_services.resetSystem;
    
    
    setup_screen();
    
    var buffer = getBuffer(8192);    
    allocator = &std.heap.FixedBufferAllocator.init(buffer).allocator;    
    const writer = Writer(*Allocator, error{}, write) {.context = allocator };
    
    try std.fmt.format(writer, "Hello World!\r\n\r\n", .{});
    try std.fmt.format(writer, "Options:\r\n", .{});
    try std.fmt.format(writer, "    Press 'r' to reboot\r\n", .{});
    try std.fmt.format(writer, "    Press 's' to shutdown\r\n", .{});
    
    while (true) {                
        switch(getKey().unicode_char){
            's' => reset(.ResetShutdown, .Success, 0, null),
            'r' => reset(.ResetWarm, .Success, 0, null),
            'R' => reset(.ResetCold, .Success, 0, null),
            else => {}
        } 

        var x: usize = undefined;
        var y: usize = undefined;
        
        getPosition(&x, &y);        
        setPosition(40, 0);
        const t = getTime();
        try std.fmt.format(writer, "{d:0>2}:{d:0>2}:{d:0>2}",
            .{t.hour,t.minute,t.second});
        setPosition(x,y);
    }
}

pub fn getTime() Time {
    const time = uefi.system_table.runtime_services.getTime;
    var t: Time = undefined; 
    _ = time(&t, null);
    return t;
}

pub fn getBuffer(size: usize) []u8 {
    const allocatePool = uefi.system_table.boot_services.?.memory.allocatePool;

    var buffer: []u8 = undefined;    
    _ = allocatePool(.LoaderData, size, &buffer);
    return buffer;
}


pub fn getKey() uefi.protocols.InputKey {
    var key: uefi.protocols.InputKey = undefined;
    
    _ = uefi.system_table.con_in.?.readKeyStroke(&key);
    return key;
}

pub fn setup_screen() void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.reset(false);
    _ = con_out.clearScreen();
}

pub fn write(alloc: *Allocator, bytes: []const u8) !u64 {
    var str16 = std.unicode.utf8ToUtf16LeWithNull(alloc, bytes);
    
    if(str16) |s| {
        const con_out = uefi.system_table.con_out.?;
        
        _ = con_out.outputString(s);
        _ = alloc.realloc(s, 0) catch 0;
    } else |err| {}
    return bytes.len;
}

pub fn getPosition(x: *usize, y: *usize) void{
    const mode = uefi.system_table.con_out.?.mode.*;
    x.* = @intCast(usize, mode.cursor_column);
    y.* = @intCast(usize, mode.cursor_row);
}

pub fn setPosition(x: usize, y: usize) void {
    const setPos = uefi.system_table.con_out.?.setCursorPosition;
    _ = setPos(x,y);
}

