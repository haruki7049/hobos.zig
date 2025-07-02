const std = @import("std");
const yazap = @import("yazap");

const App = yazap.App;
const Arg = yazap.Arg;

const allocator = std.heap.page_allocator;
const Child = std.process.Child;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var app = App.init(allocator, "hobos.zig runner", null);
    defer app.deinit();

    const runner = app.rootCommand();

    try runner.addArg(Arg.positional("KERNEL_PATH", null, null));

    const matches = try app.parseProcess();

    if (matches.getSingleValue("KERNEL_PATH")) |kernel_path| {
        const argv = [_][]const u8{
            "qemu-system-riscv32",
            "-machine",
            "virt",
            "-bios",
            "default",
            "-serial",
            "mon:stdio",
            "-kernel",
            kernel_path,
        };

        // By default, child will inherit stdout & stderr from its parents,
        // this usually means that child's output will be printed to terminal.
        // Here we change them to pipe and collect into `ArrayList`.
        var child = Child.init(&argv, allocator);
        child.stdout_behavior = .Inherit;
        child.stderr_behavior = .Inherit;

        var stdout: std.ArrayListUnmanaged(u8) = .empty;
        defer stdout.deinit(allocator);
        var stderr: std.ArrayListUnmanaged(u8) = .empty;
        defer stderr.deinit(allocator);

        const term = try child.spawnAndWait();

        std.process.exit(term.Exited);
    } else {
        std.debug.print("Runner executed with default value, './zig-out/lib/hobos.elf'\n", .{});

        const kernel_path = "./zig-out/lib/hobos.elf";

        const argv = [_][]const u8{
            "qemu-system-riscv32",
            "-machine",
            "virt",
            "-bios",
            "default",
            "-serial",
            "mon:stdio",
            "-kernel",
            kernel_path,
        };

        // By default, child will inherit stdout & stderr from its parents,
        // this usually means that child's output will be printed to terminal.
        // Here we change them to pipe and collect into `ArrayList`.
        var child = Child.init(&argv, allocator);
        child.stdout_behavior = .Inherit;
        child.stderr_behavior = .Inherit;

        var stdout: std.ArrayListUnmanaged(u8) = .empty;
        defer stdout.deinit(allocator);
        var stderr: std.ArrayListUnmanaged(u8) = .empty;
        defer stderr.deinit(allocator);

        const term = try child.spawnAndWait();

        std.process.exit(term.Exited);
    }
}
