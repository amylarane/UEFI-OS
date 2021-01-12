const std = @import("std");
const uefi = std.os.uefi;
const Allocator = std.mem.Allocator;

pub fn getBuffer(size: usize) []u8 {
    const allocatePool = uefi.system_table.boot_services.?.memory.allocatePool;

    var buffer: []u8 = undefined;    
    _ = allocatePool(.LoaderData, size, &buffer);
    return buffer;
}

pub fn deleteBuffer(buffer: []u8) void{
    const freePool = uefi.system_table.boot_services.?.memory.freePool;
    _ = freePool(buffer);
}

pub fn getAllocator(size: usize) *Allocator {  
    return &std.heap.FixedBufferAllocator.init(getBuffer(size)).allocator;
}

pub fn deleteAllocator(allocator: *Allocator) void {
    const FixedAllocator = std.heap.FixedBufferAllocator;
    var fixBuf = @fieldParentPtr(FixedAllocator, "allocator", allocator);
    deleteBuffer(fixBuf.buffer);
}