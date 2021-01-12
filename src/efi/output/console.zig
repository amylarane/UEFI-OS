const std = @import("std");
const uefi = std.os.uefi;

const Allocator = std.mem.Allocator;

pub fn setup_screen() void {
    const con_out = uefi.system_table.con_out.?;
    _ = con_out.reset(false);
    _ = con_out.clearScreen();
    _ = con_out.enableCursor(false);
}

pub fn write(alloc: *Allocator, bytes: []const u8) !u64 {
    if(std.unicode.utf8ToUtf16LeWithNull(alloc, bytes)) |s| {
        _ = uefi.system_table.con_out.?.outputString(s);
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



pub const Writer = std.io.Writer(*Allocator, error{}, write);

pub fn getWriter(alloc: *Allocator) Writer {
    return Writer {.context = alloc };
}

pub fn writeAtPosition(writer: Writer, x: usize, y: usize, comptime fmt: [] const u8, vars: anytype) !void{
    var tempX: usize = undefined;
    var tempY: usize = undefined;
    getPosition(&tempX, &tempY);        
    setPosition(x, y);
    
    try std.fmt.format(writer, fmt, vars);
    
    setPosition(tempX, tempY);
}