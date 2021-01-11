const Pics = @import("pic.zig").ChainedPics;

pub var idt_table: [256]IDTEntry = undefined;

pub const idt = IDTRec {
    .limit = @as(u16, @sizeOf(@TypeOf(idt_table))),
    .base = &idt_table,
};
 
pub const IDTEntry = packed struct {
    offset_1: u16 = 0,
    selector: u16 = 0,
    ist: u8 = 0,
    type_attr: TypeAttr,
    offset_2: u16 = 0,
    offset_3: u32 = 0,
    zero: u32 = 0,
};

pub const IDTGateType = enum(u4){
    None = 0,
    TaskGate32 = 5,
    InterruptGate16 = 6,
    InterruptGate32 = 14,
    TrapGate16 = 7,
    TrapGate32 = 15,
};

pub const TypeAttr = packed struct {
    present: bool = false,
    descriptor_privilege_level: u2 = 0,
    storage_segment: bool = false,
    gate_type: IDTGateType = None,
};

pub const IDTRec = packed struct {
    limit: u16,
    base: *[256]IDTEntry,
    
    pub fn load(self: IDTRec) void {
        asm volatile ("cli");
        remapPIC();
        const idtr = @ptrToInt(&self);
        asm volatile ("lidt (%[idtr])"
            :
            : [idtr] "r" (idtr)
        );
        //asm volatile("sti");
    }
};

pub fn remapPIC() void {
    const pics = Pics.init(32, 40);
    pics.initialize();
}
