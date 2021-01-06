const std = @import("std");
const uefi = std.os.uefi;
const Time = uefi.Time;


pub fn main() void {
    const reset = uefi.system_table.runtime_services.resetSystem;
    const time = uefi.system_table.runtime_services.getTime;

    setup_screen();
    
    print(5,3, "Hello World!"); 
    print(5,4, "Vendor:");
    print16(13,4, uefi.system_table.firmware_vendor);
    print(5,5, "Press 's' to shutdown");
    print(5,6, "Press 'r' to warm reboot");
    print(5,7, "Press 'R' to cold reboot");

    while (true) {                
        switch(getKey().unicode_char){
            's' => reset(.ResetShutdown, .Success, 0, null),
            'r' => reset(.ResetWarm, .Success, 0, null),
            'R' => reset(.ResetCold, .Success, 0, null),
            else => {}
        }
        
        var t: Time = undefined;    
        _ = time(&t, null);    
        var tstring: [*:0]const u16 = &[3:0]u16{ 48 + t.hour, 48+t.minute, 48+t.second };
    
        print16(0,1, tstring);
    }
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

pub fn print(x: usize, y: usize, str: []const u8) void{
    var buffer: [256]u8 = undefined;
    var allocator = &std.heap.FixedBufferAllocator.init(&buffer).allocator;
    var str16 = std.unicode.utf8ToUtf16LeWithNull(allocator, str);
    
    if(str16) |s| {
        print16(x,y,s);
    } else |err| {
        var basic = &[1:0]u16{108};
        print16(x,y, basic);
    }    
}

pub fn print16(x: usize, y: usize, str: [*:0]const u16) void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.setCursorPosition(x,y);
    _ = con_out.outputString(str);
}
