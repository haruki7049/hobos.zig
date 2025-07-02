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

    if (matches.getSingleValue("ISO_PATH")) |iso_path| {
        const argv = [_][]const u8{
            "qemu-system-x86_64",
            "-machine",
            "pc-i440fx-10.0",
            "-cdrom",
            iso_path,
            "-debugcon",
            "stdio",
            "-vga",
            "std",
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
        const iso_path = "./zig-out/lib/hobos.iso";

        std.debug.print("Runner executed with default value, '{s}'\n", .{iso_path});

        const argv = [_][]const u8{
            "qemu-system-x86_64",
            "-machine",
            "pc-i440fx-10.0",
            "-cdrom",
            iso_path,
            "-debugcon",
            "stdio",
            "-vga",
            "std",
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
