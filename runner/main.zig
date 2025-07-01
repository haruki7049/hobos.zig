const std = @import("std");
const print = std.debug.print;
const Child = std.process.Child;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var args: std.process.ArgIterator = std.process.args();
    const path: []const u8 = args.next() orelse return error.MissingArgument;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const allocator = gpa.allocator();

    const argv = [_][]const u8{ "qemu-system-riscv32", "-machine", "virt", "-bios", "default", "-serial", "mon:stdio", "-kernel", path };

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

    try child.spawn();
}
