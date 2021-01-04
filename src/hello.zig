const std = @import("std");
const uefi = std.os.uefi;

pub fn main() void {
    const runtime_services = uefi.system_table.runtime_services;
    const vendor = uefi.system_table.firmware_vendor;

    setup_screen();
    
    print(5,5, "Hello World!");
    print16(5,6, vendor);    

    while (true) {                
        switch(getKey().unicode_char){
            'r' => runtime_services.resetSystem(.ResetShutdown, .Success, 0, null),
            'R' => runtime_services.resetSystem(.ResetWarm, .Success, 0, null),
            else => {}
        }
    }
}

pub fn getKey() uefi.protocols.InputKey {
    const stdin = uefi.system_table.con_in.?;
    var key: uefi.protocols.InputKey = undefined;
    _ = stdin.readKeyStroke(&key);
    return key;
}

pub fn setup_screen() void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.reset(false);
    _ = con_out.clearScreen();
}

pub fn print(x: usize, y: usize, comptime str: []const u8) void{
    print16(x,y, std.unicode.utf8ToUtf16LeStringLiteral(str));
}

pub fn print16(x:usize, y:usize, str: [*:0]const u16) void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.setCursorPosition(x,y);
    _ = con_out.outputString(str);
}
