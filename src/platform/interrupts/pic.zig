const Port = @import("port.zig").Port;

pub const Pic = struct {
    offset: u8,
    command: Port,
    data: Port,
    
    pub fn handles_interrupt(self: Pic, id: u8) bool {
        return self.offset <= id and id < self.offset + 8;
    }
    
    pub fn end_of_interrupt(self: Pic) void {
        self.command.write(0x20);
    }
};

pub const ChainedPics = struct {
    pics: [2]Pic,
    
    pub fn init(offset1: u8, offset2: u8) ChainedPics {
        return ChainedPics {
            .pics = [2]Pic{
                Pic {
                    .offset = offset1,
                    .command = Port.init(.MasterCommand),
                    .data = Port.init(.MasterData),
                },
                Pic {
                    .offset = offset2,
                    .command = Port.init(.SlaveCommand),
                    .data = Port.init(.SlaveData),
                },
            },
        };
    }
    
    pub fn initialize(self: ChainedPics) void {
        const CMD_INIT: u8 = 0x11;
        const MODE_8086: u8 = 0x01;
        
        self.pics[0].command.write(CMD_INIT);
        self.pics[1].command.write(CMD_INIT);
        
        self.pics[0].data.write(self.pics[0].offset);
        self.pics[1].data.write(self.pics[1].offset);
        
        self.pics[0].data.write(4);
        self.pics[1].data.write(2);
        
        self.pics[0].data.write(MODE_8086);
        self.pics[1].data.write(MODE_8086);
        
        self.pics[0].data.write(0xFF);
        self.pics[1].data.write(0xFF);
    }
    
    pub fn handles_interrupt(self: ChainedPics, id: u8) bool {
        return self.pics[0].handles_interrupt(id) or
            self.pics[1].handles_interrupt(id);
    }
    
    pub fn notify_end_of_interrupt(self: ChainedPics, id: u8) void {
        if(self.handles_interrupt(id)) {
            if(self.pics[1].handles_interrupt(id)){
                self.pics[1].end_of_interrupt();
            }
            self.pics[0].end_of_interrupt();
        }
    }
};