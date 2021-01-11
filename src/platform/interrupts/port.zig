pub const Port = struct {
    port_num: PortNum,
    
    pub fn init(num: PortNum) Port {
        return Port {
            .port_num = num
        };
    }
    
    pub fn write(self: Port, value: u8) void {
        outb(@enumToInt(self.port_num), value);
    }
    
    pub fn read(self: Port) u8 {
        return inb(@enumToInt(self.port_num));
    }
};

pub const PortNum = enum(u16) {
    MasterCommand = 0x0020,
    MasterData = 0x0021,
    
    SlaveCommand = 0x00A0,
    SlaveData = 0x00A1,
};

inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "N{dx}" (port)
    );
}

pub inline fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8)
        : [port] "N{dx}" (port)
    );
}