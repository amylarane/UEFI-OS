const std = @import("std");
const uefi = std.os.uefi;
const Time = uefi.Time;
const Allocator = std.mem.Allocator;

pub fn main() void {
    const reset = uefi.system_table.runtime_services.resetSystem;
    
    
    setup_screen();
    
    var buffer = getBuffer(8192);    
    var allocator = &std.heap.FixedBufferAllocator.init(buffer).allocator;
    
    
    print(allocator, 5,3, "Hello World!"); 
    
    print(allocator,5,4, "Vendor:");
    print16(13,4, uefi.system_table.firmware_vendor);
    
    print(allocator,5,5, "Press 's' to shutdown");
    print(allocator,5,6, "Press 'r' to warm reboot");
    print(allocator,5,7, "Press 'R' to cold reboot");
    
    const MemoryDescriptor = uefi.tables.MemoryDescriptor;
    var map: [128]MemoryDescriptor = undefined;
    var size: usize = @sizeOf(MemoryDescriptor) * 128;
    var descSize: usize = undefined;
    var mapKey: usize = undefined;
    var descVersion: u32 = undefined;
    
    var status = uefi.system_table.boot_services.?.memory.getMemoryMap(
        &size,
        &map,
        &mapKey,
        &descSize,
        &descVersion);
        
    print(allocator,0,10, switch(status) {
        .Success => "Map Load Success",
        .BufferTooSmall => "Buffer size error",
        .InvalidParameter => "Something wrong",
        else => "Other Error",
    });
    
    print(allocator,0, 11, "Map Size:");
    printNum(allocator,10, 11, size);

    print(allocator,5, 1, ":");
    print(allocator,2, 1, ":");
  
    
    while (true) {                
        switch(getKey().unicode_char){
            's' => reset(.ResetShutdown, .Success, 0, null),
            'r' => reset(.ResetWarm, .Success, 0, null),
            'R' => reset(.ResetCold, .Success, 0, null),
            else => {}
        }       
   
            
        const t = getTime();
        printNum(allocator,6, 1, t.second);        
        printNum(allocator,3, 1, t.minute);        
        printNum(allocator,0, 1, t.hour);
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

pub fn print(allocator: *Allocator, x: usize, y: usize, str: []const u8) void{
    var str16 = std.unicode.utf8ToUtf16LeWithNull(allocator, str);
    
    if(str16) |s| {
        print16(x,y,s);
        _ = allocator.realloc(s, 0) catch 0;
    } else |err| {}
}

pub fn printNum(allocator: *Allocator, x: usize, y:usize, num: usize) void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.setCursorPosition(x,y);
    
    var vNum = num;
    if(vNum == 0){
        print(allocator, x,y, "00");
    } else if(vNum < 10){
        const intPart: u16 = @intCast(u16, vNum);
        var tempString: [*:0]const u16 = &[2:0]u16{intPart + '0', '0'};
        _ = con_out.outputString(tempString);       
    } else {
        
        while(vNum > 0){
            const intPart: u16 = @intCast(u16, vNum % 10);
            vNum = vNum / 10;
            var tempString: [*:0]const u16 = &[1:0]u16{intPart + '0'};
            _ = con_out.outputString(tempString);        
        }
    }
}

pub fn print16(x: usize, y: usize, str: [*:0]const u16) void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.setCursorPosition(x,y);
    _ = con_out.outputString(str);
}
