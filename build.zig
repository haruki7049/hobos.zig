const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .riscv32,
            .os_tag = .freestanding,
        },
    });
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .Debug,
    });

    // EXE DECLARETION
    const kernel = b.addExecutable(.{
        .name = "hobos.elf",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    kernel.setLinkerScript(.{
        .src_path = .{
            .owner = b,
            .sub_path = "src/kernel.ld",
        },
    });
    const kernel_install = b.addInstallFileWithDir(kernel.getEmittedBin(), .lib, "hobos.elf");
    kernel_install.step.dependOn(&kernel.step);
    b.getInstallStep().dependOn(&kernel_install.step);

    // UNIT TESTS
    const kernel_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_kernel_unit_tests = b.addRunArtifact(kernel_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_kernel_unit_tests.step);
}
