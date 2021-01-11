pub const GlobalDescriptorTable = packed struct {
    table: [8]u64,
    next_free: usize,
    
    pub fn init() GlobalDescriptorTable {
        return GlobalDescriptorTable {
            .table = [_]u64{0} ** 8,
            .next_free = 1,
        };
    }
    
    pub fn push(self: GlobalDescriptorTable, value: u64) usize {
        if(self.next_free < self.table.len){
            const index = self.next_free;
            self.table[index] = value;
            self.next_free += 1;
            return index;
        }
        return 0;
    }
    
    pub fn load(self: GlobalDescriptorTable) void{
        const ptr = DescriptorTablePointer {
            .base = @ptrToInt(&(self.table[0])),
            .limit = @intCast(u16, (self.table.len * @sizeOf(u64) - 1)),
        };
        
        const gdtr = @ptrToInt(&ptr);        
        asm volatile ("lgdt (%[gdtr])"
            :
            : [gdtr] "r" (gdtr)
        );
    }
};

pub const DescriptorTablePointer = packed struct {
    limit: u16,
    base: u64,
};

pub const DescriptorFlags = struct {
    pub const Writable: u64 = 1 << 41;
    pub const Conforming: u64 = 1 << 42;
    pub const Executable: u64 = 1 << 43;
    pub const UserSegment: u64 = 1 << 44;
    pub const Present: u64 = 1 << 47;
    pub const LongMode: u64 = 1 << 53;
    pub const DPLRing3: u64 = 3 << 45;
};