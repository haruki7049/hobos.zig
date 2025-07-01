const std = @import("std");
const Query = std.Target.Query;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Kernel declaration
    const query = try Query.parse(.{
        .arch_os_abi = "riscv32-freestanding",
    });
    const kernel_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = b.resolveTargetQuery(query),
        .optimize = optimize,
    });
    const kernel = b.addExecutable(.{
        .name = "hobos.elf",
        .root_module = kernel_mod,
    });
    kernel.setLinkerScript(b.path("src/kernel.ld"));

    // Install kernel
    const kernel_install = b.addInstallFileWithDir(kernel.getEmittedBin(), .lib, "hobos.elf");
    kernel_install.step.dependOn(&kernel.step);
    b.getInstallStep().dependOn(&kernel_install.step);

    // Runner declaration
    const runner_mod = b.createModule(.{
        .root_source_file = b.path("runner/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const runner = b.addExecutable(.{
        .name = "runner",
        .root_module = runner_mod,
    });

    // Install runner
    b.installArtifact(runner);

    // Append runner's CLI arguments
    const run_cmd = b.addRunArtifact(runner);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Run step
    const run_step = b.step("run", "Run hobos.zig by runner & Qemu");
    run_step.dependOn(&run_cmd.step);

    // Kernel unit tests
    const kernel_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_kernel_unit_tests = b.addRunArtifact(kernel_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_kernel_unit_tests.step);
}
