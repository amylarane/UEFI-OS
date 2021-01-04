const std = @import("std");

const Builder = std.build.Builder;
const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("bootx64", "src/hello.zig");

    exe.setTarget(CrossTarget{
        .cpu_arch = Target.Cpu.Arch.x86_64,
        .os_tag = Target.Os.Tag.uefi,
        .abi = Target.Abi.msvc,
    });

    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir("efi/boot");
    b.default_step.dependOn(&exe.step);
        
    const cmd = b.addSystemCommand(&[_][]const u8{"boot-os.bat"});
    cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the os");
    run_step.dependOn(&cmd.step);
}
