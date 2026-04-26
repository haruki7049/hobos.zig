const std = @import("std");
const Query = std.Target.Query;

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});

    // Kernel declaration
    const query = try Query.parse(.{
        .arch_os_abi = "x86_64-uefi",
    });
    const kernel = b.addExecutable(.{
        .name = "hobos.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.resolveTargetQuery(query),
            .optimize = optimize,
        }),
    });

    // Install kernel
    const kernel_install = b.addInstallFileWithDir(kernel.getEmittedBin(), .lib, "hobos.elf");
    kernel_install.step.dependOn(&kernel.step);
    b.getInstallStep().dependOn(&kernel_install.step);

    // Docs
    const docs_step = b.step("docs", "Emit docs");
    const docs_install = b.addInstallDirectory(.{
        .source_dir = kernel.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "share/hobos.zig/docs",
    });
    docs_step.dependOn(&docs_install.step);
}
