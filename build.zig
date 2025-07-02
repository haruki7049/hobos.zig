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

    // ISO Installation
    const iso_dir = b.fmt("{s}/iso_root", .{b.cache_root.path.?});
    const boot_dir = b.fmt("{s}/iso_root/boot", .{b.cache_root.path.?});
    const grub_dir = b.fmt("{s}/iso_root/boot/grub", .{b.cache_root.path.?});
    const kernel_path = b.getInstallPath(.lib, kernel.out_filename);
    const iso_path = b.fmt("{s}/hobos.iso", .{b.lib_dir});

    const iso_cmd_str: []const []const u8 = &[_][]const u8{
        "/bin/sh",
        "-c",
        b.fmt("mkdir -p {s} && cp {s} {s} && cp grub.cfg {s} && grub-mkrescue -o {s} {s}", .{
            grub_dir,
            kernel_path,
            boot_dir,
            grub_dir,
            iso_path,
            iso_dir,
        }),
    };

    const iso_cmd = b.addSystemCommand(iso_cmd_str);
    iso_cmd.step.dependOn(&kernel.step);

    const iso_step = b.step("iso", "Build an ISO image");
    iso_step.dependOn(&iso_cmd.step);
    b.default_step.dependOn(iso_step);

    // Runner declaration
    const yazap = b.dependency("yazap", .{});
    const runner_mod = b.createModule(.{
        .root_source_file = b.path("runner/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    runner_mod.addImport("yazap", yazap.module("yazap"));
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

    // Docs
    const docs_step = b.step("docs", "Emit docs");
    const docs_install = b.addInstallDirectory(.{
        .source_dir = kernel.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "share/lv2.zig/docs",
    });
    docs_step.dependOn(&docs_install.step);
}
