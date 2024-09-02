const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // EXE DECLARETION
    const kernel = b.addExecutable(.{
        .name = "hobos.elf",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    kernel.setLinkerScript(.{
        .src_path = .{
            .owner = b,
            .sub_path = "src/kernel.ld",
        },
    });
    b.installArtifact(kernel);

    // UNIT TESTS
    const kernel_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_kernel_unit_tests = b.addRunArtifact(kernel_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_kernel_unit_tests.step);
}
