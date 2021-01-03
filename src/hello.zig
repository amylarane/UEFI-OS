const std = @import("std");

const uefi = std.os.uefi;
const toUTF16 = std.unicode.utf8ToUtf16LeStringLiteral;

pub fn main() void {
    const con_out = uefi.system_table.con_out.?;
    const boot_services = uefi.system_table.boot_services.?;

    _ = con_out.reset(false);
    _ = con_out.outputString(toUTF16("Hello, World!"));

    _ = boot_services.exitBootServices(uefi.handle, 0);

    while (true) {}
}
