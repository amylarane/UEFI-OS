const std = @import("std");
const uefi = std.os.uefi;

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