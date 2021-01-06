const std = @import("std");
const builtin = @import("builtin");

const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("bootx64", "src/kernel.zig");

    exe.setTarget(CrossTarget{
        .cpu_arch = Target.Cpu.Arch.x86_64,
        .os_tag = Target.Os.Tag.uefi,
        .abi = Target.Abi.msvc,
    });

    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("efi/boot");
    exe.overrideZigLibDir("std/lib/zig");
    b.default_step.dependOn(&exe.step);
    
    const run_cmd = b.addSystemCommand(if(builtin.os.tag == .windows)
        &[_][]const u8{"boot-os.bat"}
    else
        &[_][]const u8{"boot-os.sh"});
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the os");
    run_step.dependOn(&run_cmd.step);
}
